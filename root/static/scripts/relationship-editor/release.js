/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import ko from 'knockout';

import MB from '../common/MB';
import {uniqBy} from '../common/utility/arrays';
import request from '../common/utility/request';

import {ViewModel} from './common/viewModel';

import './common/entity';

const RE = MB.relationshipEditor = MB.relationshipEditor || {};

var UI = RE.UI = RE.UI || {};


export class ReleaseViewModel extends ViewModel {
  constructor(options) {
    super(options);

    MB.releaseRelationshipEditor = this;

    this.editNote = ko.observable('');
    this.makeVotable = ko.observable(false);

    this.submissionLoading = ko.observable(false);
    this.submissionError = ko.observable('');

    var self = this;

    this.checkboxes = {
      recordingCount: ko.observable(0),
      workCount: ko.observable(0),

      recordingMessage: function () {
        var n = this.recordingCount();
        return '(' + texp.ln(
          '{n} recording selected',
          '{n} recordings selected',
          n,
          {n: n},
        ) + ')';
      },

      workMessage: function () {
        var n = this.workCount();
        return '(' + texp.ln(
          '{n} work selected',
          '{n} works selected',
          n,
          {n: n},
        ) + ')';
      },
    };

    this.source = MB.entity(options.sourceData);
    this.source.parseRelationships(options.sourceData.relationships);

    this.source.releaseGroup.parseRelationships(
      options.sourceData.releaseGroup.relationships,
    );

    this.source.mediums = ko.observableArray([]);
    this.loadingRelease = ko.observable(false);

    ko.applyBindings(this, document.getElementById('content'));

    this.loadRelease();

    window.addEventListener('beforeunload', function (event) {
      if (self.redirecting) {
        return undefined;
      }
      var $changes = $('.link-phrase')
        .filter('.rel-edit:eq(0), .rel-add:eq(0), .rel-remove:eq(0)');

      if ($changes.length) {
        event.returnValue = l(
          'All of your changes will be lost if you leave this page.',
        );
        return event.returnValue;
      }

      return undefined;
    });
  }

  loadRelease() {
    const self = this;
    const url = '/ws/js/release/' + this.source.gid + '?inc=rels+recordings';

    this.loadingRelease(true);

    request({url}, this)
      .done(this.releaseLoaded)
      .always(function () {
        self.loadingRelease(false);
      });
  }

  getEdits(addChanged) {
    var release = this.source;

    for (const medium of release.mediums()) {
      for (const track of medium.tracks) {
        const recording = track.recording;

        for (const r of recording.relationships()) {
          addChanged(r, recording);

          if (r.entityTypes === 'recording-work') {
            const work = r.entities()[1];

            for (const r of work.relationships()) {
              addChanged(r, work);
            }
          }
        }
      }
    }

    for (const r of release.relationships()) {
      addChanged(r, release);
    }

    var rg = release.releaseGroup;
    for (const r of rg.relationships()) {
      addChanged(r, rg);
    }
  }

  submit(data, event) {
    event.preventDefault();

    var self = this;
    var edits = [];
    var alreadyAdded = {};

    this.submissionLoading(true);

    function addChanged(relationship) {
      if (alreadyAdded[relationship.uniqueID]) {
        return;
      }
      if (self !== relationship.parent) {
        return;
      }
      alreadyAdded[relationship.uniqueID] = true;

      var editData = relationship.editData();

      if (relationship.added()) {
        edits.push(MB.edit.relationshipCreate(editData));
      } else if (relationship.edited()) {
        edits.push(MB.edit.relationshipEdit(
          editData,
          relationship.original,
          relationship,
        ));
      } else if (relationship.removed()) {
        edits.push(MB.edit.relationshipDelete(editData));
      }
    }

    this.getEdits(addChanged);

    if (edits.length == 0) {
      this.submissionLoading(false);
      this.submissionError(l('You haven’t made any changes!'));
      return;
    }

    var data = {
      editNote: this.editNote(),
      makeVotable: this.makeVotable(),
      edits: edits,
    };

    this._createEdit(data, this)
      .always(function () {
        this.submissionLoading(false);
      })
      .done(this.submissionDone)
      .fail(function (jqXHR) {
        try {
          const {error} = JSON.parse(jqXHR.responseText);
          const message = error && typeof error === 'object'
            ? error.message
            : error;
          this.submissionError(message);
        } catch (e) {
          this.submissionError(jqXHR.responseText);
        }
      });
  }

  submissionDone() {
    this.redirecting = true;
    window.location.replace('/release/' + this.source.gid);
  }

  releaseLoaded(data) {
    var release = this.source;
    let trackCount = 0;

    if (data.mediums) {
      release.mediums(data.mediums.map(function (mediumData) {
        if (mediumData.tracks) {
          for (const trackData of mediumData.tracks) {
            MB.entity(trackData.recording).parseRelationships(
              trackData.recording.relationships,
            );
          }
        }
        return new MB.entity.Medium(mediumData, release);
      }));

      trackCount = release.mediums().reduce((memo, medium) => {
        return memo + medium.tracks.length;
      }, 0);
    }

    initCheckboxes(this.checkboxes, trackCount);
  }

  openAddDialog(source, event) {
    new UI.AddDialog({
      source: source,
      target: new MB.entity.Artist({}),
      viewModel: this,
    }).open(event.target);
  }

  openEditDialog(relationship, event) {
    if (!relationship.removed()) {
      new UI.EditDialog({
        relationship: relationship,
        source: ko.contextFor(event.target).$parent,
        viewModel: this,
      }).open(event.target);
    }
  }

  openBatchRecordingsDialog() {
    var sources = UI.checkedRecordings();

    if (sources.length > 0) {
      new UI.BatchRelationshipDialog({sources: sources, viewModel: this})
        .open();
    }
  }

  openBatchWorksDialog() {
    var sources = UI.checkedWorks();

    if (sources.length > 0) {
      new UI.BatchRelationshipDialog({sources: sources, viewModel: this})
        .open();
    }
  }

  openBatchCreateWorksDialog() {
    var sources = UI.checkedRecordings().filter(function (recording) {
      return recording.performances().length === 0;
    });

    if (sources.length > 0) {
      new UI.BatchCreateWorksDialog({sources: sources, viewModel: this})
        .open();
    }
  }

  openRelateToWorkDialog(track) {
    var source = track.recording;
    var target = new MB.entity.Work({ name: source.name });

    new UI.AddDialog({
      source: source,
      target: target,
      viewModel: this,
    }).open();
  }

  removeRelationship(relationship, event) {
    super.removeRelationship(relationship, event);

    if (relationship.added()) {
      $(event.target)
        .parent()
        .children('input[type=checkbox]:checked')
        .prop('checked', false)
        .click();
    }
  }

  _sortedRelationships(relationships, source) {
    return relationships
      .filter(function (relationship) {
        return relationship.entityTypes !== 'recording-work';
      })
      .sortBy(function (relationship) {
        return relationship.lowerCaseTargetName(source);
      })
      .sortBy('linkOrder')
      .sortBy(function (relationship) {
        return relationship.lowerCasePhrase(source);
      });
  }

  _createEdit() {
    return MB.edit.create.apply(MB.edit, arguments);
  }
}

RE.ReleaseViewModel = ReleaseViewModel;

var recordingCheckboxes = 'td.recording > input[type=checkbox]';
var workCheckboxes = 'td.works > div.ar > input[type=checkbox]';


UI.checkedRecordings = function () {
  return $.map($(recordingCheckboxes + ':checked', '#tracklist'), ko.dataFor);
};


UI.checkedWorks = function () {
  return $.map($(workCheckboxes + ':checked', '#tracklist'), ko.dataFor);
};


function initCheckboxes(checkboxes) {
  var mediumRecordingSelector = 'input.medium-recordings';
  var mediumWorkSelector = 'input.medium-works';
  var $tracklist = $('#tracklist tbody');

  function count($inputs) {
    return uniqBy(Array.from($inputs), ko.dataFor).length;
  }

  function medium(mediumSelector, selector, counter) {
    $tracklist.on('change', mediumSelector, function () {
      const checked = this.checked;
      const $changed = $(this)
        .parents('tr.subh')
        .nextUntil('tr.subh')
        .find(selector)
        .filter(checked ? ':not(:checked)' : ':checked')
        .prop('checked', checked);
      counter(counter() + count($changed) * (checked ? 1 : -1));
    });
  }

  function _release(mediumSelector, cls) {
    $('<input type="checkbox"/>&#160;')
      .change(function () {
        $tracklist.find(mediumSelector)
          .prop('checked', this.checked).change();
      })
      .prependTo('#tracklist th.' + cls);
  }

  function range(selector, counter) {
    var lastClicked = null;

    $tracklist.on('click', selector, function (event) {
      const checked = this.checked;
      const $inputs = $(selector, $tracklist);
      if (event.shiftKey && lastClicked && lastClicked != this) {
        const first = $inputs.index(lastClicked);
        const last = $inputs.index(this);

        (first > last
          ? $inputs.slice(last, first + 1)
          : $inputs.slice(first, last + 1))
          .prop('checked', checked);
      }
      counter(count($inputs.filter(':checked')));
      lastClicked = this;
    });
  }

  medium(
    mediumRecordingSelector,
    recordingCheckboxes,
    checkboxes.recordingCount,
  );
  medium(mediumWorkSelector, workCheckboxes, checkboxes.workCount);

  _release(mediumRecordingSelector, 'recordings');
  _release(mediumWorkSelector, 'works');

  range(recordingCheckboxes, checkboxes.recordingCount);
  range(workCheckboxes, checkboxes.workCount);
}
