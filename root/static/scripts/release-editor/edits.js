/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import he from 'he';
import $ from 'jquery';
import ko from 'knockout';

import {VIDEO_ATTRIBUTE_GID} from '../common/constants.js';
import {reduceArtistCredit} from '../common/immutable-entities.js';
import MB from '../common/MB.js';
import {compactMap, keyBy, last} from '../common/utility/arrays.js';
import clean from '../common/utility/clean.js';
import {cloneObjectDeep} from '../common/utility/cloneDeep.mjs';
import {debounceComputed} from '../common/utility/debounce.js';
import deepEqual from '../common/utility/deepEqual.js';
import isBlank from '../common/utility/isBlank.js';
import isPositiveInteger from '../edit/utility/isPositiveInteger.js';
import * as validation from '../edit/validation.js';

import releaseEditor from './viewModel.js';
import utils from './utils.js';

import './init.js';

const WS_EDIT_RESPONSE_OK = 1;

var releaseEditData = utils.withRelease(MB.edit.fields.release);

var newReleaseLabels = utils.withRelease(function (release) {
  return release.labels().filter(function (releaseLabel) {
    var label = releaseLabel.label();
    return (label && label.id) || clean(releaseLabel.catalogNumber());
  });
}, []);

const getReleaseLabel = x => String(x.release_label ?? '');

releaseEditor.edits = {

  releaseGroup: function (release) {
    var releaseGroup = release.releaseGroup();
    var releaseName = clean(release.name());
    var releaseAC = release.artistCredit();
    var origData = MB.edit.fields.releaseGroup(releaseGroup);
    var editData = cloneObjectDeep(origData);

    if (releaseGroup.gid) {
      var dataChanged = false;

      if (releaseEditor.copyTitleToReleaseGroup() &&
          releaseGroup.canTakeName(releaseName)) {
        editData.name = releaseName;
        dataChanged = true;
      }

      if (releaseEditor.copyArtistToReleaseGroup() &&
          releaseGroup.canTakeArtist(releaseAC)) {
        editData.artist_credit = MB.edit.fields.artistCredit(releaseAC);
        dataChanged = true;
      }

      if (dataChanged) {
        return [MB.edit.releaseGroupEdit(editData, origData)];
      }
    } else if (releaseEditor.action === 'add') {
      editData.name = clean(releaseGroup.name) || releaseName;
      editData.artist_credit = MB.edit.fields.artistCredit(releaseAC);
      return [MB.edit.releaseGroupCreate(editData)];
    }

    return [];
  },

  release: function (release) {
    if (!release.name() && !reduceArtistCredit(release.artistCredit())) {
      return [];
    }

    var newData = releaseEditData();
    var oldData = release.original();
    var edits = [];

    if (!release.gid()) {
      edits.push(MB.edit.releaseCreate(newData));
    } else if (!deepEqual(newData, oldData)) {
      newData = {...newData, to_edit: release.gid()};
      edits.push(MB.edit.releaseEdit(newData, oldData));
    }
    return edits;
  },

  annotation: function (release) {
    var editData = MB.edit.fields.annotation(release);
    var edits = [];

    if (editData.text !== release.annotation.original()) {
      edits.push(MB.edit.releaseAddAnnotation(editData));
    }
    return edits;
  },

  releaseLabel: function (release) {
    var newLabels = newReleaseLabels().map(MB.edit.fields.releaseLabel);
    var oldLabels = release.labels.original();

    var newLabelsByID = keyBy(newLabels, getReleaseLabel);
    var oldLabelsByID = keyBy(oldLabels, getReleaseLabel);

    var edits = [];

    for (let newLabel of newLabels) {
      const id = getReleaseLabel(newLabel);

      if (id) {
        const oldLabel = oldLabelsByID.get(id);

        if (oldLabel && !deepEqual(newLabel, oldLabel)) {
          // Edit ReleaseLabel
          edits.push(MB.edit.releaseEditReleaseLabel(newLabel));
        }
      } else {
        // Add ReleaseLabel
        newLabel = {...newLabel};

        if (newLabel.label || newLabel.catalog_number) {
          newLabel.release = release.gid() || null;
          edits.push(MB.edit.releaseAddReleaseLabel(newLabel));
        }
      }
    }

    for (let oldLabel of oldLabels) {
      const id = getReleaseLabel(oldLabel);
      const newLabel = newLabelsByID.get(id);

      if (!newLabel || !(newLabel.label || newLabel.catalog_number)) {
        // Delete ReleaseLabel
        oldLabel = {...oldLabel};
        delete oldLabel.label;
        delete oldLabel.catalog_number;
        edits.push(MB.edit.releaseDeleteReleaseLabel(oldLabel));
      }
    }

    return edits;
  },

  medium: function (release) {
    var edits = [];

    /*
     * oldPositions are the original positions for all the original
     * mediums (as they exist in the database). newPositions are all
     * the new positions for the new mediums (as they exist on the
     * page). tmpPositions stores any positions we use to avoid
     * conflicts between oldPositions/newPositions.
     */

    var oldPositions = release.mediums.original().map(function (m) {
      return m.original().position;
    });

    var newMediums = release.mediums();
    var newPositions = newMediums.map(x => x.position());
    var tmpPositions = [];

    for (const medium of newMediums) {
      let newMediumData = MB.edit.fields.medium(medium);
      const oldMediumData = medium.original();

      medium.tracks().forEach(function (track, i) {
        var trackData = newMediumData.tracklist[i];

        if (track.hasExistingRecording()) {
          var newRecording = MB.edit.fields.recording(track.recording());

          var oldRecording = track.recording.savedEditData;

          if (oldRecording) {
            if (track.updateRecordingTitle() && !isBlank(trackData.name)) {
              newRecording.name = trackData.name;
            }

            if (track.updateRecordingArtist()) {
              newRecording.artist_credit = trackData.artist_credit;
            }

            if (!deepEqual(newRecording, oldRecording)) {
              edits.push(MB.edit.recordingEdit(newRecording, oldRecording));
            }
          }
        }
      });

      // The medium already exists
      newMediumData = cloneObjectDeep(newMediumData);

      if (medium.id) {
        const newWithoutPosition = {...newMediumData};
        delete newWithoutPosition.position;
        const oldWithoutPosition = {...oldMediumData};
        delete oldWithoutPosition.position;

        if (!deepEqual(newWithoutPosition, oldWithoutPosition)) {
          newWithoutPosition.to_edit = medium.id;
          newWithoutPosition.delete_tracklist = medium.tracksUnknownToUser()
            ? 1
            : 0;
          edits.push(
            MB.edit.mediumEdit(newWithoutPosition, oldWithoutPosition),
          );
        }
      } else {
        /*
         * With regards to the medium position, make sure that:
         *
         *  (1) The position doesn't conflict with an existing
         *      medium as present in the database. If it does,
         *      pick a position that doesn't and enter a reorder
         *      edit.
         *
         *  (2) The position doesn't conflict with the new
         *      position of any moved medium, unless they swap.
         */

        var newPosition = newMediumData.position;

        if (oldPositions.includes(newPosition)) {
          var lastAttempt = (last(tmpPositions) + 1) || 1;
          var attempt;

          while ((attempt = lastAttempt++)) {
            if (oldPositions.includes(attempt) ||
                tmpPositions.includes(attempt)) {
              // This position is taken.
              continue;
            }

            if (newPositions.includes(attempt)) {
              /*
               * Another medium is being moved to the
               * position we want. Avoid this *unless* we're
               * swapping with that medium.
               */

              var possibleSwap = newMediums.find(
                function (other) {
                  return other.position() === attempt;
                },
              );

              if (possibleSwap.original().position === newPosition) {
                break;
              }

              continue;
            }

            break;
          }

          tmpPositions.push(attempt);
          newMediumData.position = attempt;
          medium.tmpPosition = attempt;
        } else {
          // The medium may have been moved again.
          delete medium.tmpPosition;
        }

        newMediumData.release = release.gid();
        edits.push(MB.edit.mediumCreate(newMediumData));
      }
    }

    for (const m of release.mediums.original()) {
      if (m.id && m.removed) {
        edits.push(MB.edit.mediumDelete({medium: m.id}));
      }
    }

    return edits;
  },

  mediumReorder: function (release) {
    var edits = [];
    var newOrder = [];
    var removedMediums = {};

    for (const medium of release.mediums.original()) {
      if (medium.id && medium.removed) {
        removedMediums[medium.original().position] = medium;
      }
    }

    for (const medium of release.mediums()) {
      const newPosition = medium.position();

      const oldPosition = medium.tmpPosition || (
        medium.id ? medium.original().position : newPosition
      );

      if (oldPosition !== newPosition) {
        /*
         * A removed medium is already in the position we want, so
         * make sure we swap with it to avoid conflicts.
         */
        let removedMedium;
        if ((removedMedium = removedMediums[newPosition])) {
          newOrder.push({
            medium_id:  removedMedium.id,
            old:      newPosition,
            new:      oldPosition,
          });
        }

        newOrder.push({
          medium_id:  medium.id,
          old:      oldPosition,
          new:      newPosition,
        });
      }
    }

    if (newOrder.length) {
      edits.push(
        MB.edit.releaseReorderMediums({
          release: release.gid(),
          medium_positions: newOrder,
        }),
      );
    }

    return edits;
  },

  discID: function (release) {
    var edits = [];

    for (const medium of release.mediums()) {
      const toc = medium.toc();

      if (toc && medium.canHaveDiscID()) {
        edits.push(
          MB.edit.mediumAddDiscID({
            medium_id:          medium.id,
            medium_position:    medium.position(),
            release:            release.gid(),
            release_name:       release.name(),
            cdtoc:              toc,
          }),
        );
      }
    }

    return edits;
  },

  externalLinks: function (release) {
    var edits = [];

    function hasVideo(relationship) {
      const attributes = relationship.attributes;
      return (attributes &&
              attributes.some(attr => attr.type.gid === VIDEO_ATTRIBUTE_GID));
    }

    if (releaseEditor.hasInvalidLinks()) {
      return edits;
    }

    var {
      oldLinks,
      newLinks,
      allLinks,
    } = releaseEditor.externalLinksEditData();

    if (!allLinks) {
      return edits;
    }

    for (const link of allLinks.values()) {
      if (!link.type || !link.url) {
        continue;
      }

      const newData = MB.edit.fields.externalLinkRelationship(link, release);
      const relationshipId = link.relationship;
      const relationshipIdString = String(relationshipId);

      if (isPositiveInteger(link.relationship)) {
        if (!newLinks.has(relationshipIdString)) {
          edits.push(MB.edit.relationshipDelete(newData));
        } else if (oldLinks.has(relationshipIdString)) {
          const original = MB.edit.fields.externalLinkRelationship(
            oldLinks.get(relationshipIdString),
            release,
          );

          if (!deepEqual(newData, original)) {
            const editData = MB.edit.relationshipEdit(newData, original);

            if (hasVideo(original) && !hasVideo(newData)) {
              editData.attributes = [{
                removed: true,
                type: {gid: VIDEO_ATTRIBUTE_GID},
              }];
            }

            edits.push(editData);
          }
        }
      } else if (newLinks.has(relationshipIdString)) {
        edits.push(MB.edit.relationshipCreate(newData));
      }
    }

    return edits;
  },
};


var _allEdits = [
  'releaseGroup',
  'release',
  'releaseLabel',
  'medium',
  'mediumReorder',
  'discID',
  'annotation',
  'externalLinks',
].map(function (name) {
  return utils.withRelease(
    releaseEditor.edits[name].bind(releaseEditor.edits),
    [],
  );
});


releaseEditor.allEdits = ko.computed(function () {
  return _allEdits.flatMap(ko.unwrap);
});

releaseEditor.editPreviews = ko.observableArray([]);
releaseEditor.loadingEditPreviews = ko.observable(false);


releaseEditor.getEditPreviews = function () {
  const previews = {};
  let previewRequest = null;

  function refreshPreviews(edits) {
    releaseEditor.editPreviews(compactMap(edits, getPreview));
  }

  function getPreview(edit) {
    return previews[edit.hash];
  }

  function addPreview(edit, preview) {
    const editHash = edit.hash;
    if (preview) {
      preview.editHash = editHash;
      previews[editHash] = preview;
    }
  }

  function isNewEdit(edit) {
    return previews[edit.hash] === undefined;
  }

  debounceComputed(function () {
    var edits = releaseEditor.allEdits();

    if (validation.errorsExist()) {
      refreshPreviews([]);
      return;
    }

    var addedEdits = edits.filter(isNewEdit);

    if (addedEdits.length === 0) {
      refreshPreviews(edits);
      return;
    }

    releaseEditor.loadingEditPreviews(true);

    if (previewRequest) {
      previewRequest.abort();
    }

    previewRequest = MB.edit.preview({edits: addedEdits})
      .done(function (data) {
        const newPreviews = data.previews;
        for (let i = 0; i < addedEdits.length; i++) {
          addPreview(addedEdits[i], newPreviews[i]);
        }

        // Make sure edits haven't changed while request was pending
        if (edits === releaseEditor.allEdits()) {
          // and that errors haven't occurred.
          if (validation.errorsExist()) {
            edits = [];
          }
          refreshPreviews(edits);
        }
      })
      .always(function () {
        releaseEditor.loadingEditPreviews(false);
        previewRequest = null;
      });
  }, 100);
};


releaseEditor.submissionInProgress = ko.observable(false);
releaseEditor.submissionError = ko.observable();


function chainEditSubmissions(release, submissions) {
  var root = releaseEditor.rootField;

  var args = {
    makeVotable: root.makeVotable(),
    editNote: root.editNote(),
  };

  function nextSubmission(index) {
    var current = submissions[index++];

    if (!current) {
      // We're done!

      // Don't ask for confirmation before redirecting.
      root.redirecting = true;

      if (releaseEditor.redirectURI) {
        var a = document.createElement('a');
        a.href = releaseEditor.redirectURI;

        a.search += /^\?/.test(a.search) ? '&' : '?';
        a.search += 'release_mbid=' + release.gid();

        window.location.href = a.href;
      } else {
        window.location.pathname = '/release/' + release.gid();
      }
      return;
    }

    const edits = current.edits(release);
    let submitted = null;

    if (edits.length) {
      submitted = MB.edit.create($.extend({edits: edits}, args));
    }

    const submissionDone = function (data) {
      if (data && current.callback) {
        current.callback(
          release,
          data.edits.filter(
            x => x.response === WS_EDIT_RESPONSE_OK,
          ),
        );
      }

      setTimeout(() => nextSubmission(index), 1);
    };

    $.when(submitted)
      .done(submissionDone)
      .fail(submissionErrorOccurred);
  }
  nextSubmission(0);
}


function submissionErrorOccurred(data) {
  var error;

  try {
    error = JSON.parse(data.responseText).error;

    if (error && typeof error === 'object') {
      if (error.message) {
        error = error.message;
      } else {
        error = he.escape(data.statusText + ': ' + data.status);
      }
    }
  } catch (e) {
    error = he.escape(data.statusText + ': ' + data.status);
  }

  releaseEditor.submissionError(error);
  releaseEditor.submissionInProgress(false);
}


releaseEditor.orderedEditSubmissions = [
  {
    edits: releaseEditor.edits.releaseGroup,

    callback: function (release, edits) {
      var edit = edits[0];

      /*
       * edit can be undef if the only change is RG rename
       * and the RG has already been renamed to the same name in the meantime
       */
      if (edit?.edit_type == MB.edit.TYPES.EDIT_RELEASEGROUP_CREATE) {
        release.releaseGroup(
          new releaseEditor.fields.ReleaseGroup(edits[0].entity),
        );
      }
    },
  },
  {
    edits: releaseEditor.edits.release,

    callback: function (release, edits) {
      var entity = edits[0].entity;

      if (entity) {
        release.gid(entity.gid);
      }

      release.original(MB.edit.fields.release(release));
    },
  },
  {
    edits: releaseEditor.edits.releaseLabel,

    callback: function (release, edits) {
      release.labels.original(
        newReleaseLabels().map(function (label) {
          const labelId = label.label().id || null;
          const catalogNumber = label.catalogNumber() || null;

          var newData = edits.find(({entity}) => (
            entity &&
            entity.labelID === labelId &&
            entity.catalogNumber === catalogNumber
          ));

          if (newData) {
            label.id = newData.entity.id;
          }
          return MB.edit.fields.releaseLabel(label);
        }),
      );
    },
  },
  {
    edits: releaseEditor.edits.medium,

    callback: function (release, edits) {
      var added = keyBy(
        compactMap(edits, x => x.entity),
        x => String(x.position),
      );

      var newMediums = release.mediums();

      newMediums.filter(m => m.id == null).forEach(function (medium) {
        var addedData = added.get(
          String(medium.tmpPosition || medium.position()),
        );

        if (addedData) {
          medium.id = addedData.id;

          var currentData = MB.edit.fields.medium(medium);

          /*
           * mediumReorder edits haven't been submitted yet, so
           * we must keep the position the medium was added in
           * (i.e. tmpPosition).
           */
          currentData.position = addedData.position;

          medium.original(currentData);
        }
      });

      release.mediums.original(release.existingMediumData());
      release.mediums.notifySubscribers(newMediums);
    },
  },
  {
    edits: releaseEditor.edits.mediumReorder,
  },
  {
    edits: releaseEditor.edits.discID,

    callback: function (release) {
      release.mediums().forEach(m => m.toc(null));
    },
  },
  {
    edits: releaseEditor.edits.annotation,

    callback: function (release) {
      release.annotation.original(release.annotation());
    },
  },
  {
    edits: releaseEditor.edits.externalLinks,
  },
];


releaseEditor.submitEdits = function () {
  if (!releaseEditor.allowsSubmission()) {
    return;
  }

  releaseEditor.submissionInProgress(true);
  var release = releaseEditor.rootField.release();

  chainEditSubmissions(release, releaseEditor.orderedEditSubmissions);
};

export default releaseEditor.edits;
