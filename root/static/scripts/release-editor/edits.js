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

import {VIDEO_ATTRIBUTE_GID} from '../common/constants';
import {reduceArtistCredit} from '../common/immutable-entities';
import MB from '../common/MB';
import {compactMap, keyBy, last} from '../common/utility/arrays';
import clean from '../common/utility/clean';
import {cloneObjectDeep} from '../common/utility/cloneDeep';
import {debounceComputed} from '../common/utility/debounce';
import deepEqual from '../common/utility/deepEqual';
import isBlank from '../common/utility/isBlank';
import isPositiveInteger from '../edit/utility/isPositiveInteger';
import * as validation from '../edit/validation';

import releaseEditor from './viewModel';
import utils from './utils';

import './init';

const WS_EDIT_RESPONSE_OK = 1;

const releaseEditData = utils.withRelease(MB.edit.fields.release);

const newReleaseLabels = utils.withRelease(function (release) {
  return release.labels().filter(function (releaseLabel) {
    const label = releaseLabel.label();
    return (label && label.id) || clean(releaseLabel.catalogNumber());
  });
}, []);

const getReleaseLabel = x => String(x.release_label ?? '');

releaseEditor.edits = {

  releaseGroup: function (release) {
    const releaseGroup = release.releaseGroup();
    const releaseName = clean(release.name());
    const releaseAC = release.artistCredit();
    const origData = MB.edit.fields.releaseGroup(releaseGroup);
    const editData = cloneObjectDeep(origData);

    if (releaseGroup.gid) {
      let dataChanged = false;

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

    let newData = releaseEditData();
    const oldData = release.original();
    const edits = [];

    if (!release.gid()) {
      edits.push(MB.edit.releaseCreate(newData));
    } else if (!deepEqual(newData, oldData)) {
      newData = {...newData, to_edit: release.gid()};
      edits.push(MB.edit.releaseEdit(newData, oldData));
    }
    return edits;
  },

  annotation: function (release) {
    const editData = MB.edit.fields.annotation(release);
    const edits = [];

    if (editData.text !== release.annotation.original()) {
      edits.push(MB.edit.releaseAddAnnotation(editData));
    }
    return edits;
  },

  releaseLabel: function (release) {
    const newLabels = newReleaseLabels().map(MB.edit.fields.releaseLabel);
    const oldLabels = release.labels.original();

    const newLabelsByID = keyBy(newLabels, getReleaseLabel);
    const oldLabelsByID = keyBy(oldLabels, getReleaseLabel);

    const edits = [];

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
    const edits = [];

    /*
     * oldPositions are the original positions for all the original
     * mediums (as they exist in the database). newPositions are all
     * the new positions for the new mediums (as they exist on the
     * page). tmpPositions stores any positions we use to avoid
     * conflicts between oldPositions/newPositions.
     */

    const oldPositions = release.mediums.original().map(function (m) {
      return m.original().position;
    });

    const newMediums = release.mediums();
    const newPositions = newMediums.map(x => x.position());
    const tmpPositions = [];

    for (const medium of newMediums) {
      let newMediumData = MB.edit.fields.medium(medium);
      const oldMediumData = medium.original();

      medium.tracks().forEach(function (track, i) {
        const trackData = newMediumData.tracklist[i];

        if (track.hasExistingRecording()) {
          const newRecording = MB.edit.fields.recording(track.recording());

          const oldRecording = track.recording.savedEditData;

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

        const newPosition = newMediumData.position;

        if (oldPositions.includes(newPosition)) {
          let lastAttempt = (last(tmpPositions) + 1) || 1;
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

              const possibleSwap = newMediums.find(
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
    const edits = [];
    const newOrder = [];
    const removedMediums = {};

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
    const edits = [];

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
    const edits = [];

    function hasVideo(relationship) {
      const attributes = relationship.attributes;
      return (attributes &&
              attributes.some(attr => attr.type.gid === VIDEO_ATTRIBUTE_GID));
    }

    if (releaseEditor.hasInvalidLinks()) {
      return edits;
    }

    const {
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


const _allEdits = [
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
    let edits = releaseEditor.allEdits();

    if (validation.errorsExist()) {
      refreshPreviews([]);
      return;
    }

    const addedEdits = edits.filter(isNewEdit);

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
  const root = releaseEditor.rootField;

  const args = {
    makeVotable: root.makeVotable(),
    editNote: root.editNote(),
  };

  function nextSubmission(index) {
    const current = submissions[index++];

    if (!current) {
      // We're done!

      // Don't ask for confirmation before redirecting.
      root.redirecting = true;

      if (releaseEditor.redirectURI) {
        const a = document.createElement('a');
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
  let error;

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
      const edit = edits[0];

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
      const entity = edits[0].entity;

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

          const newData = edits.find(({entity}) => (
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
      const added = keyBy(
        compactMap(edits, x => x.entity),
        x => String(x.position),
      );

      const newMediums = release.mediums();

      newMediums.filter(m => m.id == null).forEach(function (medium) {
        const addedData = added.get(
          String(medium.tmpPosition || medium.position()),
        );

        if (addedData) {
          medium.id = addedData.id;

          const currentData = MB.edit.fields.medium(medium);

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
  const release = releaseEditor.rootField.release();

  chainEditSubmissions(release, releaseEditor.orderedEditSubmissions);
};

export default releaseEditor.edits;
