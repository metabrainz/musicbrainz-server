/*
 * @flow strict-local
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import {
  createInitialState,
  reducer,
} from '../edit/components/ArtistCreditEditor.js';

import {
  genericRecording,
} from './utility/constants.js';

test('MBS-13538: Removing all rows in the AC editor makes it disappear', function (t) {
  t.plan(2);
  const state = createInitialState({
    entity: genericRecording,
    id: '',
  });
  t.equals(state.names.length, 1, 'artist credit has 1 row');
  t.doesNotThrow(() => {
    reducer(
      reducer(state, {index: 0, type: 'remove-name'}),
      {type: 'close-dialog'},
    );
  }, undefined, 'remove-name on only row does not throw an exception');
});
