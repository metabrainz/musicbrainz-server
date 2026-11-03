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
  getArtistCreditNames,
} from '../edit/components/ArtistCreditEditor/utilities.js';

import {
  genericRecording,
} from './utility/constants.js';

test('MBS-13538: Removing all rows in the AC editor makes it disappear', function (t) {
  t.plan(2);
  const state = createInitialState({
    entity: genericRecording,
    htmlId: String(genericRecording.id),
  });
  t.equals(
    getArtistCreditNames(state).length,
    1,
    'artist credit has 1 row',
  );
  t.doesNotThrow(() => {
    reducer(
      reducer(state, {
        nameFieldId: getArtistCreditNames(state)[0].id,
        type: 'remove-name',
      }),
      {type: 'close-dialog'},
    );
  }, undefined, 'remove-name on only row does not throw an exception');
});
