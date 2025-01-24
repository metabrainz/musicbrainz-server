/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import ko from 'knockout';
import mutate from 'mutate-cow';
import {createRoot} from 'react-dom/client';

import '../../lib/jquery.ui/ui/jquery-ui.custom.js';
import '../../lib/knockout/knockout-delegatedEvents.js';

import {
  artistCreditsAreEqual,
  hasVariousArtists,
} from '../common/immutable-entities.js';
import MB from '../common/MB.js';
import {
  initializeRangeSelect,
} from '../common/MB/Control/SelectAll.js';
import {
  getCatalystContext,
  getSourceEntityData,
} from '../common/utility/catalyst.js';
import clean from '../common/utility/clean.js';
import {cloneObjectDeep} from '../common/utility/cloneDeep.mjs';
import {debounceComputed} from '../common/utility/debounce.js';
import {isBeginner} from '../common/utility/privileges.js';
import request from '../common/utility/request.js';
import * as externalLinks from '../edit/externalLinks.js';
import {createField} from '../edit/utility/createField.js';
import getUpdatedTrackArtists from
  '../edit/utility/getUpdatedTrackArtists.js';
import * as validation from '../edit/validation.js';

import EditNoteTab from './components/EditNoteTab.js';
import fields from './fields.js';
import recordingAssociation from './recordingAssociation.js';
import utils from './utils.js';
import releaseEditor from './viewModel.js';

Object.assign(releaseEditor, {
  activeTabID: ko.observable('#information'),
  activeTabIndex: ko.observable(0),
  loadError: ko.observable(''),
  loadErrorMessage() {
    return texp.l(
      'Error loading release: {error}',
      {error: releaseEditor.loadError()},
    );
  },
  externalLinksEditData: ko.observable({}),
  hasInvalidLinks: validation.errorField(ko.observable(false)),
});

releaseEditor.init = function (options) {
  var self = this;

  $.extend(this, {
    action: options.action,
    isBeginner: isBeginner(getCatalystContext().user),
    redirectURI: options.redirectURI,
    returnTo: options.returnTo,
  });

  /*
   * Setup guess case buttons for the title field. Do this every time the
   * release changes, since the old fields get removed and the events no
   * longer exist.
   */
  utils.withRelease(function () {
    setTimeout(function () {
      MB.Control.initializeGuessCase('release');
    }, 1);
  });

  /*
   * Allow using range-select (shift-click) on the change recording artist
   * and change recording title checkboxes in the Recordings page.
   */
  initializeRangeSelect(
    '#track-recording-assignation input.' +
    'update-recording-title[type="checkbox"]',
  );

  initializeRangeSelect(
    '#track-recording-assignation input.' +
    'update-recording-artist[type="checkbox"]',
  );

  /*
   * Allow pressing enter to advance to the next tab. The listener is added
   * to the document and not #release-editor so that other events can call
   * preventDefault if necessary.
   */
  $(document).on(
    'keydown',
    '#release-editor :input:not(:button, textarea)',
    function (event) {
      if (event.which === 13 && !event.isDefaultPrevented()) {
        /*
         * The setTimeout is entirely for <select> elements in Firefox,
         * which don't have their change events triggered until after
         * enter is hit. Additionally, if we switch tabs before the
         * change event is handled, it doesn't seem to even register
         * (probably because the <select> is hidden by then).
         */
        setTimeout(function () {
          self.activeTabID() === '#edit-note'
            ? self.submitEdits()
            : self.nextTab();
        }, 1);
      }
    },
  );

  var $pageContent = $('#release-editor').tabs({

    beforeActivate(event, ui) {
      /*
       * Workaround for buggy dictation software which may not trigger
       * change events after setting input values.
       */
      if (ui.oldPanel[0].id === 'tracklist') {
        $('.medium.tbl input:enabled:visible', ui.oldPanel).change();
      }
    },

    activate(event, ui) {
      var panel = ui.newPanel;

      self.activeTabID(panel.selector)
        .activeTabIndex(self.uiTabs.panels.index(panel));

      /*
       * jQuery UI's position() function doesn't work on hidden
       * elements. So if any bubble was open in the tab we just
       * switched to, we have to trigger its position to update,
       * now that it's visible.
       */

      var $bubble = panel.find('div.bubble:visible:eq(0)');
      if ($bubble.length) {
        const bubbleDoc = $bubble[0].bubbleDoc;
        bubbleDoc.redraw(true /* stealFocus */);
      }
    },
  });

  this.uiTabs = $pageContent.data('ui-tabs');
  this.tabCount = this.uiTabs.panels.length;

  if (this.action === 'add') {
    $pageContent.tabs('disable', 1);

    this.findReleaseDuplicates();
  }

  // Initiate tooltip widget (current just used by the recordings tab).

  $pageContent.find('.ui-tabs-nav a').tooltip();

  /*
   * Enable or disable the recordings tab depending on whether there are
   * tracks or if the tracks have errors.
   */

  utils.withRelease(function (release) {
    var addingRelease = self.action === 'add';
    var tabEnabled = addingRelease ? release.hasTracks() : true;

    if (tabEnabled) {
      /*
       * If we're editing a release and the mediums aren't loaded
       * (because there are many discs), we should still allow the
       * user to edit the recordings if that's all they want to do.
       */
      tabEnabled = release.hasTrackArtists() && release.hasTrackTitles();
    }

    var tabNumber = addingRelease ? 3 : 2;
    self.uiTabs[tabEnabled ? 'enable' : 'disable'](tabNumber);

    // When the tab is enabled, the tooltip is *disabled*

    var tooltipEnabled = !tabEnabled;
    var $tab = self.uiTabs.tabs.eq(tabNumber).find('a');

    /*
     * XXX Don't disable the tooltip twice.
     * http://bugs.jqueryui.com/ticket/9719
     */

    if ($tab.tooltip('option', 'disabled') === tooltipEnabled) {
      $tab.tooltip(tooltipEnabled ? 'enable' : 'disable');
    }
  });

  // Change the track artists to match the release artist if it was changed.

  utils.withRelease(function (release) {
    const tabID = self.activeTabID();
    const releaseAC = cloneObjectDeep(release.artistCredit());
    const savedReleaseAC = release.artistCredit.saved;
    const releaseACChanged =
      !artistCreditsAreEqual(releaseAC, savedReleaseAC);

    if (tabID === '#tracklist' && releaseACChanged) {
      if (!hasVariousArtists(releaseAC)) {
        for (const medium of release.mediums()) {
          for (const track of medium.tracks()) {
            const trackAC = track.artistCredit();
            const names = getUpdatedTrackArtists(
              trackAC.names,
              savedReleaseAC.names,
              releaseAC.names,
            );
            if (names !== trackAC.names) {
              track.artistCredit({names});
            }
          }
        }
      }
      release.artistCredit.saved = releaseAC;
    }
  });

  // Update the document title to match the release title

  utils.withRelease(function (release) {
    var name = clean(release.name());

    if (self.action === 'add') {
      document.title = name
        ? hyphenateTitle(name, lp('Add release', 'header'))
        : lp('Add release', 'header');
    } else {
      document.title = name
        ? hyphenateTitle(name, lp('Edit release', 'header'))
        : lp('Edit release', 'header');
    }
  });

  /*
   * Handle showing/hiding the AddMedium dialog when the user switches to/from
   * the tracklist tab.
   */

  utils.withRelease(function (release) {
    self.autoOpenTheAddMediumDialog(release);
  });

  // Keep track of recordings associated with the current release group.
  let releaseGroupTimer;

  utils.withRelease(r => r.releaseGroup()).subscribe(function (releaseGroup) {
    if (releaseGroupTimer) {
      clearTimeout(releaseGroupTimer);
    }

    function getRecordings() {
      recordingAssociation.getReleaseGroupRecordings(releaseGroup, 0, []);
    }

    /*
     * Refresh our list of recordings every 10 minutes, in case the user
     * leaves the tab open and comes back later, potentially leaving us
     * with stale data.
     */
    releaseGroupTimer = setTimeout(getRecordings, 10 * 60 * 1000);

    getRecordings();
  });

  // Check for similarly-named release groups when the release changes.
  debounceComputed(utils.withRelease(
    () => this.loadDuplicateReleaseGroups(),
  ));

  // When the release group changes, update the radio buttons.
  debounceComputed(
    utils.withRelease(r => r.releaseGroup()), 100,
  ).subscribe((releaseGroup) => {
    const gid = releaseGroup?.gid ?? '';
    const idx = this.duplicateReleaseGroups().findIndex(
      (rg) => rg.gid === gid,
    );
    const inputs = $('.duplicate-release-groups-list input[type="radio"]');
    if (idx >= 0) {
      // The chosen RG is listed, so check its input.
      inputs.eq(idx).prop('checked', true);
    } else if (gid === '') {
      // No RG is chosen, so check "Add a new release group".
      inputs.last().prop('checked', true);
    } else {
      // The chosen RG isn't listed, so uncheck the checked input.
      inputs.filter(':checked').prop('checked', false);
    }
  });

  /*
   * Make sure the user actually wants to close the page/tab if they've made
   * any changes.
   */
  var hasEdits = ko.computed(function () {
    return releaseEditor.allEdits().length > 0;
  });

  window.addEventListener('beforeunload', event => {
    if (hasEdits() && !this.rootField.redirecting) {
      if (MUSICBRAINZ_RUNNING_TESTS) {
        sessionStorage.setItem('didShowBeforeUnloadAlert', 'true');
      }
      event.returnValue = l(
        'All of your changes will be lost if you leave this page.',
      );
      return event.returnValue;
    }

    return true;
  });

  // Intialize release data/view model.

  this.rootField.missingEditNote = function () {
    return self.action === 'add' && empty(self.rootField.editNote());
  };

  // Keep in sync with is_valid_edit_note in Server::Validation
  this.rootField.invalidEditNote = function () {
    const editNote = self.rootField.editNote();
    if (empty(editNote)) {
      // This is missing, not invalid
      return false;
    }

    /*
     * We don't want line format characters and other invisible characters
     * to stop an edit note from being "empty"
     */
    const editNoteNoInvisibleChars = editNote.replace(
      /[\u200b\u00AD\u3164\uFFA0\u115F\u1160\u2800\p{Cc}\p{Cf}\p{Mn}]/ug,
      '',
    );
    return (
      // If it's empty now but not earlier, it was all invisible characters
      empty(editNoteNoInvisibleChars) ||
      /^[\p{White_Space}\p{Punctuation}]+$/u.test(editNoteNoInvisibleChars) ||
      /^\p{ASCII}$/u.test(editNoteNoInvisibleChars)
    );
  };

  this.seed(options.seed);

  if (this.action === 'edit') {
    this.releaseLoaded(getSourceEntityData());
  } else {
    releaseEditor.createExternalLinksEditor(
      {entityType: 'release'},
      $('#external-links-editor-container')[0],
    );
  }

  this.getEditPreviews();

  // Apply root bindings to the page.

  ko.applyBindings(this, $pageContent[0]);

  // Keep the React EditNoteTab component in sync.

  const editNoteTabContainer = document.getElementById('edit-note');
  const editNoteTabRoot = createRoot(editNoteTabContainer);
  let releaseEditorForm = {
    field: {
      edit_note: createField('edit_note', ''),
      make_votable: createField('make_votable', false),
    },
    has_errors: false,
    name: 'release-editor',
    type: 'form',
  };
  const handleEditNoteChange = (event) => {
    self.rootField.editNote(event.target.value);
  };
  const handleMakeVotableChange = (event) => {
    self.rootField.makeVotable(event.target.checked);
  };

  ko.computed(() => {
    const rootField = self.rootField;
    releaseEditorForm = mutate(releaseEditorForm)
      .update('field', (fieldCtx) => {
        fieldCtx
          .set('edit_note', 'value', rootField.editNote())
          .set('make_votable', 'value', rootField.makeVotable());
      })
      .final();
    editNoteTabRoot.render(
      <EditNoteTab
        editPreviews={releaseEditor.editPreviews()}
        editsExist={releaseEditor.allEdits().length > 0}
        errorsExist={validation.errorsExist()}
        form={releaseEditorForm}
        invalidEditNote={rootField.invalidEditNote()}
        loadingEditPreviews={releaseEditor.loadingEditPreviews()}
        missingEditNote={rootField.missingEditNote()}
        // eslint-disable-next-line react/jsx-no-bind
        onEditNoteChange={handleEditNoteChange}
        // eslint-disable-next-line react/jsx-no-bind
        onMakeVotableChange={handleMakeVotableChange}
        submissionError={releaseEditor.submissionError()}
        submissionInProgress={releaseEditor.submissionInProgress()}
      />,
    );
  });

  // Fancy!

  $(function () {
    $pageContent.fadeIn('fast', function () {
      $('#name').focus();
    });
  });
};

releaseEditor.loadRelease = function (gid, callback) {
  var args = {
    url: '/ws/js/release/' + gid,
    data: {inc: 'rels'},
  };

  return request(args, this)
    .done(callback || this.releaseLoaded)
    .fail(function (jqXHR, status, error) {
      error = jqXHR.status + ' (' + error + ')';

      // If there wasn't an ISE, the response should parse as JSON.
      try {
        error += ': ' + JSON.parse(jqXHR.responseText).error;
      } catch (ignoredError) {}

      this.loadError(error);
    });
};

releaseEditor.releaseLoaded = function (data) {
  this.loadError('');

  var seed = this.seededReleaseData;

  // Setup the external links editor
  setTimeout(function () {
    releaseEditor.createExternalLinksEditor(
      data,
      $('#external-links-editor-container')[0],
    );
  }, 1);

  var release = new fields.Release(data);

  if (seed) {
    this.seedRelease(release, seed);
  }

  if (!seed || !seed.mediums) {
    release.loadMedia();
  }

  this.rootField.release(release);
};

releaseEditor.createExternalLinksEditor = function (data, mountPoint) {
  if (!mountPoint) {
    // XXX undefined in some tape tests
    return null;
  }

  var seed = this.seededReleaseData;
  delete this.seededReleaseData;

  if (seed && seed.relationships) {
    data.relationships = (data.relationships || [])
      .concat(seed.relationships);
  }

  this.externalLinks = externalLinks.createExternalLinksEditor({
    sourceData: data,
    mountPoint,
    errorObservable: this.hasInvalidLinks,
  });

  return this.externalLinks;
};

releaseEditor.autoOpenTheAddMediumDialog = function (release) {
  var addMediumUI = $(this.addMediumDialog.element).data('ui-dialog');
  var trackParserUI = $(this.trackParserDialog.element).data('ui-dialog');

  // Show the dialog if there's no non-empty disc.
  if (this.activeTabID() === '#tracklist') {
    var dialogIsOpen = (addMediumUI && addMediumUI.isOpen()) ||
        (trackParserUI && trackParserUI.isOpen());

    if (!dialogIsOpen && release.hasOneEmptyMedium() &&
                            !release.mediums()[0].loading()) {
      if (release.mediums()[0].tracksWereUnknownToUser) {
        // If we had a medium without tracklist, edit that tracklist
        this.trackParserDialog.open(release.mediums()[0]);
      } else {
        // Otherwise, prepare to add a new medium
        this.addMediumDialog.open();
      }
    }
  } else if (addMediumUI) {
    addMediumUI.close();
  }
};

releaseEditor.allowsSubmission = function () {
  return (
    !this.submissionInProgress() &&
    !validation.errorsExist() &&
    (this.action === 'edit' || !(
      this.rootField.missingEditNote() || this.rootField.invalidEditNote()
    )) &&
    this.allEdits().length > 0
  );
};

MB._releaseEditor = releaseEditor;

$(MB.confirmNavigationFallback);
