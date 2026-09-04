/*
 * Copyright (C) 2026 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 *
 * The test cases compiled in this file are derived from:
 * https://github.com/kellnerd/es-utils/raw/refs/heads/main/string/punctuation.test.ts
 * Original version Copyright (C) 2021-2023 David Kellner, and released under
 * the MIT license: http://opensource.org/licenses/MIT
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
    ['You\'re Here and I\'ve Had It', 'You’re Here and I’ve Had It'],
    ['She\'ll Say He\'d Go', 'She’ll Say He’d Go'],
    ['It Isn\'t John\'s', 'It Isn’t John’s'],
    ['Lovin\' You', 'Lovin’ You'],
    ['Talkin\' \'Bout You', 'Talkin’ ’Bout You'],
    ['\'Cause I Said So', '’Cause I Said So'],
    ['L\'amour toujours', 'L’amour toujours'],
    ['Le temps de l\'été', 'Le temps de l’été'],
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
    ['4\'33"', '4\'33"'],
    ['Blue Hawai\'i', 'Blue Hawai\'i'],
    ['O\'Connor', 'O\'Connor'],
    ['He Is 6\'2"', 'He Is 6\'2"'],
  ];

  t.plan(tests.length);

  for (const [input, expected] of tests) {
    t.equal(guessPunctuation(input), expected, input);
  }
});
