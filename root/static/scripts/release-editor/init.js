/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import ko from 'knockout';

import {
  artistCreditsAreEqual,
  hasVariousArtists,
  reduceArtistCredit,
  reduceArtistCreditNames,
} from '../common/immutable-entities.js';
import MB from '../common/MB.js';
import {getSourceEntityData} from '../common/utility/catalyst.js';
import clean from '../common/utility/clean.js';
import {
  cloneArrayDeep,
  cloneObjectDeep,
} from '../common/utility/cloneDeep.mjs';
import request from '../common/utility/request.js';
import * as externalLinks from '../edit/externalLinks.js';
import * as validation from '../edit/validation.js';

import fields from './fields.js';
import recordingAssociation from './recordingAssociation.js';
import utils from './utils.js';
import releaseEditor from './viewModel.js';

Object.assign(releaseEditor, {
  activeTabID: ko.observable('#information'),
  activeTabIndex: ko.observable(0),
  loadError: ko.observable(''),
  loadErrorMessage: function () {
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
  MB.Control.RangeSelect(
    '#track-recording-assignation input.' +
    'update-recording-title[type="checkbox"]',
  );

  MB.Control.RangeSelect(
    '#track-recording-assignation input.' +
    'update-recording-artist[type="checkbox"]',
  );

  /*
   * Allow pressing enter to advance to the next tab. The listener is added
   * to the document and not #release-editor so that other events can call
   * preventDefault if necessary.
   */
  $(document).on(
    'keydown', '#release-editor :input:not(:button, textarea)',
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

    beforeActivate: function (event, ui) {
      /*
       * Workaround for buggy dictation software which may not trigger
       * change events after setting input values.
       */
      if (ui.oldPanel[0].id === 'tracklist') {
        $('.medium.tbl input:enabled:visible', ui.oldPanel).change();
      }
    },

    activate: function (event, ui) {
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

      $('#artist-credit-bubble').hide();
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
        const savedReleaseACLength = savedReleaseAC.names.length;
        const savedReleaseACReduced = reduceArtistCredit(savedReleaseAC);

        for (const medium of release.mediums()) {
          for (const track of medium.tracks()) {
            const trackAC = track.artistCredit();
            if (reduceArtistCredit(trackAC) === savedReleaseACReduced) {
              /*
               * If the track credits exactly match the old release credits,
               * update them to use the new release credits.
               */
              track.artistCredit(releaseAC);
              track.artistCreditEditorInst?.current?.setState({
                artistCredit: track.artistCredit.peek(),
              });
            } else if (
              savedReleaseACLength > 0 &&
              releaseAC.names.length > 0 &&
              trackAC.names.length > savedReleaseACLength
            ) {
              /*
               * If the track credits contain more artists than the old
               * release credits, also check if the first N (where N is the
               * length of the release credits) track artists match the
               * release artists. This handles renaming primary artists on
               * tracks that also include featured artists (MBS-13273).
               */
              const trackPrefix = reduceArtistCreditNames(
                trackAC.names.slice(0, savedReleaseACLength), true,
              );
              if (trackPrefix === savedReleaseACReduced) {
                /*
                 * Replace the old release artist(s) with the new one(s) and
                 * restore the old join phrase following the release artist.
                 */
                const names = cloneArrayDeep(releaseAC.names)
                  .concat(trackAC.names.slice(savedReleaseACLength));
                names[releaseAC.names.length - 1].joinPhrase =
                  trackAC.names[savedReleaseACLength - 1].joinPhrase;
                track.artistCredit({names});
                track.artistCreditEditorInst?.current?.setState({
                  artistCredit: track.artistCredit.peek(),
                });
              }
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
        ? hyphenateTitle(name, l('Add Release'))
        : l('Add Release');
    } else {
      document.title = name
        ? hyphenateTitle(name, l('Edit Release'))
        : l('Edit Release');
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

  /*
   * Make sure the user actually wants to close the page/tab if they've made
   * any changes.
   */
  var hasEdits = ko.computed(function () {
    return releaseEditor.allEdits().length > 0;
  });

  window.addEventListener('beforeunload', event => {
    if (hasEdits() && !this.rootField.redirecting) {
      event.returnValue = l(
        'All of your changes will be lost if you leave this page.',
      );
      return event.returnValue;
    }

    return true;
  });

  // Intialize release data/view model.

  this.rootField.missingEditNote = function () {
    return self.action === 'add' && !self.rootField.editNote();
  };

  // Keep in sync with is_valid_edit_note in Server::Validation
  this.rootField.invalidEditNote = function () {
    return self.action === 'add' && (
      empty(self.rootField.editNote()) ||
      /^[\p{White_Space}\p{Punctuation}]+$/u.test(self.rootField.editNote()) ||
      /^\p{ASCII}$/u.test(self.rootField.editNote())
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
      } catch (e) {}

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
    mountPoint: mountPoint,
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
