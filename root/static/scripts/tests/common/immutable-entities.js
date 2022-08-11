/*
 * Copyright (C) 2016 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import {
  artistCreditsAreEqual,
  isComplexArtistCredit,
} from '../../common/immutable-entities.js';

const bowie = {
  gid: '5441c29d-3602-4898-b1a1-b77fa23b8e50',
  id: 956,
  name: 'david bowie',
};
const crosby = {
  gid: '2437980f-513a-44fc-80f1-b90d9d7fcf8f',
  id: 99,
  name: 'bing crosby',
};

test('isComplexArtistCredit', function (t) {
  t.plan(4);

  let ac = {names: [{artist: bowie, name: 'david bowie'}]};
  t.equal(isComplexArtistCredit(ac), false, 'david bowie is not complex');

  ac = {names: [{artist: bowie, name: 'david robert jones'}]};
  t.equal(isComplexArtistCredit(ac), true, 'david robert jones is complex');

  ac = {names: [{artist: bowie, name: '', joinPhrase: ''}]};
  t.equal(isComplexArtistCredit(ac), true, 'empty artist credit is complex');

  ac = {
    names: [
      {artist: bowie, name: 'david bowie', joinPhrase: ' & '},
      {artist: crosby, name: 'bing crosby'},
    ],
  };
  t.equal(
    isComplexArtistCredit(ac),
    true,
    'david bowie & bing crosby is complex',
  );
});

test('artistCreditsAreEqual', function (t) {
  t.plan(4);

  const ac1 = {
    names: [
      {artist: {gid: 1, name: 'a'}, joinPhrase: '/', name: 'a'},
    ],
  };
  const ac2 = {
    names: [
      {artist: {gid: 1, name: 'a'}, joinPhrase: '/', name: 'a'},
    ],
  };
  const ac3 = {
    names: [
      {artist: {gid: 1, name: 'a'}, joinPhrase: '/', name: 'b'},
    ],
  };
  const ac4 = {
    names: [
      {artist: {gid: 1, name: 'a'}, joinPhrase: '/', name: 'a'},
      {artist: {gid: 2, name: 'b'}, joinPhrase: '', name: 'b'},
    ],
  };

  t.ok(!artistCreditsAreEqual(ac1, ac3));
  t.ok(!artistCreditsAreEqual(ac1, ac4));
  t.ok(artistCreditsAreEqual(ac1, ac1));
  t.ok(artistCreditsAreEqual(ac1, ac2));
});
