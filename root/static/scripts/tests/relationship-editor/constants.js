/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  createArtistObject,
  createEventObject,
  createRecordingObject,
  createReleaseGroupObject,
  createReleaseObject,
} from '../../common/entity2.js';
import {uniqueNegativeId} from '../../common/utility/numbers.js';
import {REL_STATUS_ADD} from '../../relationship-editor/constants.js';
import type {
  RelationshipStateT,
  ReleaseWithMediumsAndReleaseGroupT,
} from '../../relationship-editor/types.js';

export const artist: ArtistT = createArtistObject({
  name: 'Artist',
});

export const event: EventT = createEventObject({
  name: 'Event',
});

export const recording: RecordingT = createRecordingObject({
  name: 'Recording',
});

export const release: ReleaseT = createReleaseObject({
  name: 'Release',
});

const mediumId = uniqueNegativeId();

const track: TrackWithRecordingT = {
  artist: '',
  artistCredit: {
    names: [
      {
        artist,
        joinPhrase: '',
        name: 'Artist',
      },
    ],
  },
  editsPending: false,
  entityType: 'track',
  gid: 'c8f65672-e007-453d-8ecc-4a0bd9cb4dc6',
  id: uniqueNegativeId(),
  isDataTrack: false,
  last_updated: null,
  length: 10000,
  medium_id: mediumId,
  medium: null,
  name: 'Track',
  number: '1',
  position: 1,
  recording,
};

export const releaseWithMediumsAndReleaseGroup:
  ReleaseWithMediumsAndReleaseGroupT = {
    ...release,
    releaseGroup: createReleaseGroupObject(),
    mediums: [
      {
        cdtocs: [],
        editsPending: false,
        entityType: 'medium',
        format_id: null,
        format: null,
        id: mediumId,
        last_updated: null,
        name: '',
        position: 1,
        release_id: release.id,
        track_count: null,
        tracks: [track],
      },
    ],
  };

export const emptyRelationship: RelationshipStateT = {
  _lineage: [],
  _original: null,
  _status: REL_STATUS_ADD,
  attributes: null,
  begin_date: null,
  editsPending: false,
  end_date: null,
  ended: false,
  entity0: artist,
  entity0_credit: '',
  entity1: recording,
  entity1_credit: '',
  id: 0,
  linkOrder: 0,
  linkTypeID: null,
};

export const newArtistRecordingRelationship: RelationshipStateT = {
  ...emptyRelationship,
  id: -1,
  linkTypeID: 154,
};
