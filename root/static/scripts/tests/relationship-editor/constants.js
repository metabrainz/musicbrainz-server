/*
 * @flow
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
  createReleaseObject,
} from '../../common/entity2.js';
import {REL_STATUS_ADD} from '../../relationship-editor/constants.js';
import type {
  RelationshipStateT,
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

export const emptyRelationship: RelationshipStateT = {
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
