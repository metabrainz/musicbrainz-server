/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import {
  createInitialState,
  reducer,
} from '../../relationship-editor/components/RelationshipDialogContent.js';

import {
  artist,
  newArtistRecordingRelationship,
  recording,
} from './constants.js';

const commonInitialState = {
  closeDialog: () => undefined,
  sourceDispatch: () => undefined,
  targetTypeOptions: null,
  targetTypeRef: null,
  title: '',
  user: {
    avatar: '',
    entityType: 'editor',
    has_confirmed_email_address: true,
    id: 0,
    name: '',
    preferences: {
      datetime_format: '',
      timezone: 'UTC',
    },
    privileges: 0,
  },
};

test('action: set-credit', function (t) {
  t.plan(4);

  let initialState = createInitialState({
    ...commonInitialState,
    initialRelationship: newArtistRecordingRelationship,
    source: recording,
  });

  const sourceAction = {
    action: {
      creditedAs: 'newsourcecredit',
      type: 'set-credit',
    },
    type: 'update-source-entity',
  };

  const targetAction = {
    action: {
      action: {
        creditedAs: 'newtargetcredit',
        type: 'set-credit',
      },
      type: 'update-credit',
    },
    type: 'update-target-entity',
  };

  let newState = reducer(initialState, sourceAction);

  t.equals(
    newState.sourceEntity.creditedAs,
    'newsourcecredit',
    'source entity credit is updated (entity1)',
  );

  newState = reducer(newState, {...targetAction, source: recording});

  t.equals(
    newState.targetEntity.creditedAs,
    'newtargetcredit',
    'target entity credit is updated (entity0)',
  );

  initialState = createInitialState({
    ...commonInitialState,
    initialRelationship: newArtistRecordingRelationship,
    source: artist,
  });

  newState = reducer(initialState, sourceAction);
  newState = reducer(newState, {...targetAction, source: artist});

  t.equals(
    newState.sourceEntity.creditedAs,
    'newsourcecredit',
    'source entity credit is updated (entity0)',
  );

  t.equals(
    newState.targetEntity.creditedAs,
    'newtargetcredit',
    'target entity credit is updated (entity1)',
  );
});
