/*
 * Copyright (C) 2026 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import guessPunctuation from '../guess-punctuation.js';

test('Guess punctuation', function (t) {
  const tests = [
    ['Are \'Friends\' Electric?', 'Are ‘Friends’ Electric?'],
    [
      'One of These Days (\'French Windows\')',
      'One of These Days (‘French Windows’)',
    ],
    ['I\'m Free', 'I’m Free'],
    ['Lovin\' You', 'Lovin’ You'],
    ['Talkin\' \'Bout You', 'Talkin’ ’Bout You'],
    ['Summer \'68', 'Summer ’68'],
    ['\'39', '’39'],
    ['Rock \'n\' Roll', 'Rock ’n’ Roll'],
    ['Rock \'N\' Roll', 'Rock ’N’ Roll'],
    ['Back to the 70\'s', 'Back to the 70’s'],
    [
      'Little Billy (aka \'Little Billy\'s Doing Fine\')',
      'Little Billy (aka ‘Little Billy’s Doing Fine’)',
    ],
    [
      'Όσο Και Να Σ\' Αγαπάω (Υπ\' Ευθύνη Μου)',
      'Όσο Και Να Σ’ Αγαπάω (Υπ’ Ευθύνη Μου)',
    ],
  ];

  t.plan(tests.length);

  for (const [input, expected] of tests) {
    t.equal(guessPunctuation(input), expected, input);
  }
});
