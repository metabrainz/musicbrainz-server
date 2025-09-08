/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import {
  ANON_ARTIST_GID,
  ANON_ARTIST_ID,
  DARTIST_ID,
  DATA_ARTIST_GID,
  DATA_ARTIST_ID,
  DIALOGUE_ARTIST_GID,
  DIALOGUE_ARTIST_ID,
  NO_ARTIST_GID,
  NO_ARTIST_ID,
  TRAD_ARTIST_GID,
  TRAD_ARTIST_ID,
  UNKNOWN_ARTIST_GID,
  UNKNOWN_ARTIST_ID,
  VARTIST_GID,
  VARTIST_ID,
} from '../../common/constants.js';
import {
  createArtistObject,
} from '../../common/entity2.js';
import isSpecialPurpose from '../../common/utility/isSpecialPurpose.js';

test('isSpecialPurpose', function (t) {
  t.plan(17);

  t.ok(
    isSpecialPurpose(createArtistObject({id: DARTIST_ID})),
    'The id for Deleted Artist is detected as a special purpose artist ID',
  );
  t.ok(
    isSpecialPurpose(createArtistObject({id: VARTIST_ID})),
    'The id for Deleted Artist is detected as a special purpose artist ID',
  );
  t.ok(
    isSpecialPurpose(createArtistObject({gid: VARTIST_GID})),
    'The MBID for Various Artists is detected as a special purpose artist MBID',
  );
  t.ok(
    isSpecialPurpose(createArtistObject({id: ANON_ARTIST_ID})),
    'The id for [anonymous] is detected as a special purpose artist ID',
  );
  t.ok(
    isSpecialPurpose(createArtistObject({gid: ANON_ARTIST_GID})),
    'The MBID for [anonymous] is detected as a special purpose artist MBID',
  );
  t.ok(
    isSpecialPurpose(createArtistObject({id: DATA_ARTIST_ID})),
    'The id for [data] is detected as a special purpose artist ID',
  );
  t.ok(
    isSpecialPurpose(createArtistObject({gid: DATA_ARTIST_GID})),
    'The MBID for [data] is detected as a special purpose artist MBID',
  );
  t.ok(
    isSpecialPurpose(createArtistObject({id: DIALOGUE_ARTIST_ID})),
    'The id for [dialogue] is detected as a special purpose artist ID',
  );
  t.ok(
    isSpecialPurpose(createArtistObject({gid: DIALOGUE_ARTIST_GID})),
    'The MBID for [dialogue] is detected as a special purpose artist MBID',
  );
  t.ok(
    isSpecialPurpose(createArtistObject({id: NO_ARTIST_ID})),
    'The id for [no artist] is detected as a special purpose artist ID',
  );
  t.ok(
    isSpecialPurpose(createArtistObject({gid: NO_ARTIST_GID})),
    'The MBID for [no artist] is detected as a special purpose artist MBID',
  );
  t.ok(
    isSpecialPurpose(createArtistObject({id: TRAD_ARTIST_ID})),
    'The id for [traditional] is detected as a special purpose artist ID',
  );
  t.ok(
    isSpecialPurpose(createArtistObject({gid: TRAD_ARTIST_GID})),
    'The MBID for [traditional] is detected as a special purpose artist MBID',
  );
  t.ok(
    isSpecialPurpose(createArtistObject({id: UNKNOWN_ARTIST_ID})),
    'The id for [unknown] is detected as a special purpose artist ID',
  );
  t.ok(
    isSpecialPurpose(createArtistObject({gid: UNKNOWN_ARTIST_GID})),
    'The MBID for [unknown] is detected as a special purpose artist MBID',
  );
  t.ok(
    !isSpecialPurpose(createArtistObject({id: 5})),
    'A random artist id is not detected as special purpose',
  );
  t.ok(
    !isSpecialPurpose(createArtistObject({gid: '7527f6c2-d762-4b88-b5e2-9244f1e34c46'})),
    'A random artist MBID is not detected as special purpose',
  );
});
