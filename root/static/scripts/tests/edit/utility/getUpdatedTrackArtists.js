/*
 * @flow strict-local
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import getUpdatedTrackArtists from
  '../../../edit/utility/getUpdatedTrackArtists.js';
import {genericArtist} from '../../utility/constants.js';

test('getUpdatedTrackArtists', function (t) {
  const name = (
    name: string,
    gid: string,
    joinPhrase: string = '',
    creditedAs: string = '',
  ) => {
    const artist = {...genericArtist, name, gid};
    return {artist, joinPhrase, name: creditedAs};
  };

  const testCases = [
    {
      desc: 'artist change, track matches old',
      track: [name('Old', '1')],
      oldRel: [name('Old', '1')],
      newRel: [name('New', '2')],
      want: [name('New', '2')],
    },
    {
      desc: 'artist change, track doesn’t match old',
      track: [name('Other', '3')],
      oldRel: [name('Old', '1')],
      newRel: [name('New', '2')],
      want: [name('Other', '3')],
    },
    {
      desc: 'added credited-as, track matches old',
      track: [name('Old', '1')],
      oldRel: [name('Old', '1')],
      newRel: [name('Old', '1', '', 'Alt')],
      want: [name('Old', '1', '', 'Alt')],
    },
    {
      desc: 'removed credited-as, track matches old',
      track: [name('Old', '1', '', 'Alt')],
      oldRel: [name('Old', '1', '', 'Alt')],
      newRel: [name('Old', '1')],
      want: [name('Old', '1')],
    },
    {
      desc: 'multiple artists, track matches old',
      track: [name('A', '1', ' & '), name('B', '2')],
      oldRel: [name('A', '1', ' & '), name('B', '2')],
      newRel: [name('C', '3', ' feat. '), name('D', '4')],
      want: [name('C', '3', ' feat. '), name('D', '4')],
    },
    {
      desc: 'multiple artists, track matches old plus feat.',
      track: [
        name('A', '1', ' & '),
        name('B', '2', ' feat. '),
        name('E', '5'),
      ],
      oldRel: [name('A', '1', ' & '), name('B', '2')],
      newRel: [name('C', '3', ' with '), name('D', '4')],
      want: [
        name('C', '3', ' with '),
        name('D', '4', ' feat. '),
        name('E', '5'),
      ],
    },
    {
      desc: 'multiple artists, track matches first old',
      track: [name('A', '1')],
      oldRel: [name('A', '1', ' & '), name('B', '2')],
      newRel: [name('C', '3', ' & '), name('D', '4')],
      want: [name('A', '1')],
    },
    {
      desc: 'multiple artists, track matches second old',
      track: [name('B', '2')],
      oldRel: [name('A', '1', ' & '), name('B', '2')],
      newRel: [name('C', '3', ' & '), name('D', '4')],
      want: [name('B', '2')],
    },
    {
      desc: 'track matches new with diff. join phrase',
      track: [name('C', '3', ' feat. '), name('D', '4')],
      oldRel: [name('A', '1', ' & '), name('B', '2')],
      newRel: [name('C', '3', ' & '), name('D', '4')],
      want: [name('C', '3', ' & '), name('D', '4')],
    },
    {
      desc: 'shared prefix, track matches new with diff. join phrase',
      track: [name('A', '1', ' & '), name('B', '2')],
      oldRel: [name('A', '1')],
      newRel: [name('A', '1', ' feat. '), name('B', '2')],
      want: [name('A', '1', ' feat. '), name('B', '2')],
    },
    {
      desc: 'multiple artists with credited-as, track matches old',
      track: [name('A', '1', ' & ', 'a'), name('B', '2')],
      oldRel: [name('A', '1', ' & ', 'a'), name('B', '2')],
      newRel: [name('A', '1', ' & '), name('B', '2')],
      want: [name('A', '1', ' & '), name('B', '2')],
    },
    {
      desc: 'multiple artists with credited-as, track has feat.',
      track: [
        name('A', '1', ' & ', 'a'),
        name('B', '2', ' feat. '),
        name('C', '3'),
      ],
      oldRel: [name('A', '1', ' & ', 'a'), name('B', '2')],
      newRel: [name('A', '1', ' & '), name('B', '2')],
      want: [
        /*
         * TODO: As discussed in MBS-13273, the first artist's credited-as
         * name should be removed here.
         */
        name('A', '1', ' & ', 'a'),
        name('B', '2', ' feat. '),
        name('C', '3'),
      ],
    },
    {
      desc: 'old name but diff. entity',
      track: [name('A', '1')],
      oldRel: [name('A', '2')],
      newRel: [name('B', '3')],
      want: [name('B', '3')],
    },
    {
      desc: 'old name but diff. entity with feat.',
      track: [name('A', '1', ' feat. '), name('C', '4')],
      oldRel: [name('A', '2')],
      newRel: [name('B', '3')],
      want: [name('B', '3', ' feat. '), name('C', '4')],
    },
    {
      desc: 'old name but diff. entity (single vs. multiple)',
      track: [name('A & B', '1')],
      oldRel: [name('A', '2', ' & '), name('B', '3')],
      newRel: [name('C', '4')],
      want: [name('C', '4')],
    },
    {
      desc: 'old name but diff. entity (single vs. multiple) with feat.',
      track: [name('A & B', '1', ' feat. '), name('C', '2')],
      oldRel: [name('A', '3', ' & '), name('B', '4')],
      newRel: [name('D', '5')],
      // TODO: This should be updated like the non-feat. version.
      want: [name('A & B', '1', ' feat. '), name('C', '2')],
    },
    {
      desc: 'old name but diff. entity (multiple vs. single)',
      track: [name('A', '1', ' & '), name('B', '2')],
      oldRel: [name('A & B', '3')],
      newRel: [name('C', '4')],
      want: [name('C', '4')],
    },
    {
      desc: 'old name but diff. entity (multiple vs. single) with feat.',
      track: [
        name('A', '1', ' & '),
        name('B', '2', ' feat. '),
        name('C', '3'),
      ],
      oldRel: [name('A & B', '4')],
      newRel: [name('D', '5')],
      // TODO: This should be updated like the non-feat. version.
      want: [
        name('A', '1', ' & '),
        name('B', '2', ' feat. '),
        name('C', '3'),
      ],
    },
    {
      desc: 'new name but diff. entity',
      track: [name('A', '1')],
      oldRel: [name('B', '2')],
      newRel: [name('A', '3')],
      want: [name('A', '1')],
    },
    {
      desc: 'new name but diff. entity with feat.',
      track: [name('A', '1', ' feat. '), name('C', '4')],
      oldRel: [name('B', '2')],
      newRel: [name('A', '3')],
      want: [name('A', '1', ' feat. '), name('C', '4')],
    },
    {
      desc: 'new name but diff. entity (single vs. multiple)',
      track: [name('A & B', '1')],
      oldRel: [name('C', '4')],
      newRel: [name('A', '2', ' & '), name('B', '3')],
      // TODO: This should possibly use the new release artists.
      want: [name('A & B', '1')],
    },
    {
      desc: 'new name but diff. entity (single vs. multiple) with feat.',
      track: [name('A & B', '1', ' feat. '), name('D', '5')],
      oldRel: [name('C', '4')],
      newRel: [name('A', '2', ' & '), name('B', '3')],
      // TODO: This should possibly use the new release artists.
      want: [name('A & B', '1', ' feat. '), name('D', '5')],
    },
    {
      desc: 'new name but diff. entity (multiple vs. single)',
      track: [name('A', '1', ' & '), name('B', '2')],
      oldRel: [name('C', '3')],
      newRel: [name('A & B', '4')],
      // TODO: This should possibly use the new release artist.
      want: [name('A', '1', ' & '), name('B', '2')],
    },
    {
      desc: 'new name but diff. entity (multiple vs. single) with feat.',
      track: [
        name('A', '1', ' & '),
        name('B', '2', ' feat. '),
        name('D', '5'),
      ],
      oldRel: [name('C', '3')],
      newRel: [name('A & B', '4')],
      // TODO: This should possibly use the new release artist.
      want: [
        name('A', '1', ' & '),
        name('B', '2', ' feat. '),
        name('D', '5'),
      ],
    },
  ];

  t.plan(testCases.length);

  for (const tc of testCases) {
    const got = getUpdatedTrackArtists(tc.track, tc.oldRel, tc.newRel);
    t.deepEqual(got, tc.want, tc.desc);
  }
});
