/*
 * Copyright (C) 2013 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import setCookie from '../common/utility/setCookie';
import gc from '../guess-case/MB/GuessCase/Main';

setCookie('guesscase_roman', 'false');
gc.CFG_KEEP_UPPERCASED = 'false';
gc.modeName = 'English';

/* eslint-disable sort-keys */
test('Sortname', function (t) {
  t.plan(6);

  let tests = [
    {
      input: 'Members Of Mayday',
      expected: 'Members Of Mayday',
      person: false,
    },
    {
      input: 'The Prodigy & Tom Morello',
      expected: 'Prodigy, The & Morello, Tom',
      person: true,
    },
    {
      input: 'DJ Shadow',
      expected: 'Shadow, DJ',
      person: true,
    },
  ];

  for (const test of tests) {
    const result = gc.entities.artist.sortname(test.input, test.person);
    t.equal(result, test.expected, test.input);
  }

  tests = [
    {
      input: 'Da! Heard It Records',
      expected: 'Da! Heard It Records',
    },
    {
      input: 'The Cadenza Collection',
      expected: 'Cadenza Collection, The',
    },
    {
      input: 'Los Enanos Gigantes',
      expected: 'Enanos Gigantes, Los',
    },
    /*
     * FIXME: improve article code.  These should be handled.
     * {
     * input: "L'Amicale underground",
     * expected: "Amicale underground, L'"
     * },
     * {
     * input: "Les Industries Musicales et Électriques Pathé Marconi",
     * expected: "Industries Musicales et Électriques Pathé Marconi, Les"
     * },
     * {
     * input: "Die Schöne Blumen Musik Werk",
     * expected: "Schöne Blumen Musik Werk, Die"
     * }
     */
  ];

  for (const test of tests) {
    const result = gc.entities.label.sortname(test.input);
    t.equal(result, test.expected, test.input);
  }
});

test('Artist', function (t) {
  t.plan(8);

  const tests = [
    {
      input: 'Members Of Mayday',
      expected: 'Members of Mayday',
    },
    {
      input: 'the prodigy & tom morello',
      expected: 'The Prodigy & Tom Morello',
    },
    {
      input: ' ',
      expected: '[unknown]',
    },
    {
      input: 'n/a',
      expected: '[unknown]',
    },
    {
      input: 'NONE',
      expected: '[unknown]',
    },
    {
      input: 'unknown',
      expected: '[unknown]',
    },
    {
      input: 'No Artist',
      expected: '[unknown]',
    },
    {
      input: 'Peggy Sue And The Pirates',
      expected: 'Peggy Sue and the Pirates',
      bug: 'MBS-1370 / MBS-9836',
      mode: 'Artist',
    },
  ];

  for (const test of tests) {
    const result = gc.entities.artist.guess(test.input);

    const prefix = test.bug ? test.bug + ', ' : '';

    t.equal(result, test.expected, prefix + test.input);
  }
});

test('Instrument', function (t) {
  t.plan(1);

  const tests = [
    {
      input: 'This Instrument',
      expected: 'this instrument',
      message: 'Instrument guess case lowercases name',
    },
  ];

  for (const test of tests) {
    t.equal(
      gc.entities.instrument.guess(test.input),
      test.expected,
      test.message,
    );
  }
});

test('Label', function (t) {
  t.plan(6);

  const tests = [
    {
      input: 'da! heard it records',
      expected: 'Da! Heard It Records',
    },
    {input: ' ', expected: '[unknown]'},
    {input: 'n/a', expected: '[unknown]'},
    {input: 'NONE', expected: '[unknown]'},
    {input: 'unknown', expected: '[unknown]'},
    {input: 'No Label', expected: '[unknown]'},
  ];

  for (const test of tests) {
    const result = gc.entities.label.guess(test.input);
    t.equal(result, test.expected, test.input);
  }
});

test('Recording', function (t) {
  t.plan(2);

  const tests = [
    {
      input: 'ハイタッチ (w/o maaya)',
      expected: 'ハイタッチ (w/o Maaya)',
      message: 'w/o is not capitalized',
    },
    {
      input: 'ハイタッチ (w／o maaya)',
      expected: 'ハイタッチ (w／o Maaya)',
      message: 'w／o is not capitalized',
    },
  ];

  for (const test of tests) {
    t.equal(
      gc.entities.recording.guess(test.input),
      test.expected,
      test.message,
    );
  }
});

test('Release', function (t) {
  t.plan(2);

  const tests = [
    {
      input: 'All The Piano Sonatas',
      expected: 'All the Piano Sonatas',
      message: 'Release guess case runs correctly (English)',
      mode: 'English',
    },
    {
      input: 'Todas Las Sonatas Para Piano',
      expected: 'Todas las sonatas para piano',
      message: 'Release guess case runs correctly (Sentence)',
      mode: 'Sentence',
    },
  ];

  for (const test of tests) {
    gc.modeName = test.mode;

    t.equal(
      gc.entities.release.guess(test.input),
      test.expected,
      test.message,
    );
  }
});

test('Work', function (t) {
  t.plan(24);

  const tests = [
    {
      input: 'WE LOVE TECHPARA VI',
      expected: 'WE LOVE TECHPARA VI',
      mode: 'English',
      roman: true,
      keepuppercase: true,
    },
    {
      input: 'WE LOVE TECHPARA VI',
      expected: 'We Love Techpara VI',
      mode: 'English',
      roman: true,
      keepuppercase: false,
    },
    {
      input: 'WE LOVE TECHPARA VI',
      expected: 'We Love Techpara Vi',
      mode: 'English',
      roman: false,
      keepuppercase: false,
    },
    {
      input: 'WE LOVE TECHPARA VI',
      expected: 'We love techpara VI',
      mode: 'Sentence',
      roman: true,
      keepuppercase: false,
    },
    {
      input: 'acte 1, no. 7: chœur: «voyons brigadier»',
      expected: 'Acte 1, no. 7 : Chœur : « Voyons brigadier »',
      mode: 'French',
      roman: false,
      keepuppercase: false,
    },
    {
      input: 'La chenille',
      expected: 'La Chenille',
      mode: 'French',
      roman: false,
      keepuppercase: false,
    },
    {
      input: 'Le téléphone',
      expected: 'Le Téléphone',
      mode: 'French',
      roman: false,
      keepuppercase: false,
    },
    {
      input: 'Le tire-bouchon',
      expected: 'Le Tire-bouchon',
      mode: 'French',
      roman: false,
      keepuppercase: false,
    },
    {
      input: 'Les corons',
      expected: 'Les Corons',
      mode: 'French',
      roman: false,
      keepuppercase: false,
    },
    {
      input: "L'envie",
      expected: 'L’Envie',
      mode: 'French',
      roman: false,
      keepuppercase: false,
    },
    {
      input: 'L’envie',
      expected: 'L’Envie',
      mode: 'French',
      roman: false,
      keepuppercase: false,
    },
    {
      input: 'La patience est le courage de la vertu.',
      expected: 'La patience est le courage de la vertu.',
      mode: 'French',
      roman: false,
      keepuppercase: false,
    },
    {
      input: 'American Way ft. Kelis',
      expected: 'American Way (ft. Kelis)',
      mode: 'English',
      roman: true,
      keepuppercase: false,
    },
    {
      input: 'Bring It All To Me (f. 50 Cent)',
      expected: 'Bring It All to Me (f. 50 Cent)',
      mode: 'English',
      roman: true,
      keepuppercase: false,
    },
    {
      input: 'izarın gül gül olmuş',
      expected: 'İzarın Gül Gül Olmuş',
      mode: 'Turkish',
      roman: false,
      keepuppercase: false,
    },
    {
      input: 'efendim hu nasibim Bu IECELLİ TAKSI\u0307RAT yahu',
      expected: 'Efendim Hu Nasibim Bu Iecelli Taksirat Yahu',
      mode: 'Turkish',
      roman: false,
      keepuppercase: false,
    },
    {
      input: 'ben De YAZDIM',
      expected: 'Ben de YAZDIM',
      mode: 'Turkish',
      roman: false,
      keepuppercase: true,
    },
    {
      input: 'ya devlet başa Ya Kuzgun Leşe',
      expected: 'Ya Devlet Başa ya Kuzgun Leşe',
      mode: 'Turkish',
      roman: false,
      keepuppercase: false,
    },
    {
      input: 'My Favourite Numbers ARE IV, Viii, xIx and mcmxcvi',
      expected: 'My Favourite Numbers Are IV, VIII, XIX and MCMXCVI',
      bug: 'MBS-5338',
      mode: 'English',
      roman: true,
      keepuppercase: false,
    },
    {
      input: "C'est le hautbois d'amour no. cvi",
      expected: "C'est le hautbois d'amour no. CVI",
      bug: 'MBS-11264',
      mode: 'French',
      roman: true,
      keepuppercase: false,
    },
    {
      input: 'My brother is a minor',
      expected: 'My Brother Is a Minor',
      bug: 'MBS-10840',
      mode: 'English',
      roman: false,
      keepuppercase: false,
    },
    {
      input: 'Sonata in a minor',
      expected: 'Sonata in A minor',
      bug: 'MBS-10840',
      mode: 'English',
      roman: false,
      keepuppercase: false,
    },
    {
      input: 'Sonata in g flat major',
      expected: 'Sonata in G-flat major',
      bug: 'MBS-10840',
      mode: 'English',
      roman: false,
      keepuppercase: false,
    },
    {
      input: 'hyphen-minus? hyphen‐maximus!',
      expected: 'Hyphen-Minus? Hyphen‐Maximus!',
      bug: 'MBS-11854',
      mode: 'English',
      roman: false,
      keepuppercase: false,
    },
  ];

  for (const test of tests) {
    setCookie('guesscase_roman', String(test.roman));
    gc.CFG_KEEP_UPPERCASED = test.keepuppercase;
    gc.modeName = test.mode;

    const result = gc.entities.work.guess(test.input);
    t.equal(result, test.expected, test.input);
  }
});

test('BugFixes', function (t) {
  t.plan(30);

  const tests = [
    {
      input: 'Je T’Aime Moi… Non Plus (feat. Miss Kittin)',
      expected: 'Je T’Aime Moi… Non Plus (feat. Miss Kittin)',
      bug: 'MBS-991',
      mode: 'English',
    },
    {
      input: 'E Pra Sempre Te Amar: Ao Vivo',
      expected: 'E pra sempre te amar: Ao vivo',
      bug: 'MBS-1311',
      mode: 'Sentence',
    },
    {
      input: 'Me Esqueça / No Limite / Desesperadamente Apaixonado',
      expected: 'Me esqueça / No limite / Desesperadamente apaixonado',
      bug: 'MBS-1311',
      mode: 'Sentence',
    },
    {
      input: 'Megablast (Rap Version) (ft. Merlin)',
      expected: 'Megablast (rap version) (ft. Merlin)',
      bug: 'MBS-1313',
      mode: 'English',
    },
    {
      input: '너 (Techno Version)',
      expected: '너 (techno version)',
      bug: 'MBS-1313',
      mode: 'English',
    },
    {
      input: 'aka AKA a.k.a. A.K.A. a/k/a A/K/A',
      expected: 'aka aka a.k.a. a.k.a. a.k.a. a.k.a.',
      bug: 'MBS-1314, MBS-8065',
      mode: 'English',
    },
    {
      input: 'Stuff aka Stuffy AKA Stuffy Stuff',
      expected: 'Stuff aka Stuffy aka Stuffy Stuff',
      bug: 'MBS-8065',
      mode: 'English',
    },
    {
      input: 'Boy In Da Corner / Fire Ina Hole / Bird Inna De Nest / Rock Di Mexicano',
      expected: 'Boy in da Corner / Fire ina Hole / Bird inna de Nest / Rock di Mexicano',
      bug: 'MBS-1315',
      mode: 'English',
    },
    {
      input: 'We Ready Fe Dem / Santa Fe Express / We Come Fi Rock',
      expected: 'We Ready fe Dem / Santa Fe Express / We Come fi Rock',
      bug: 'MBS-1315',
      mode: 'English',
    },
    {
      input: 'Contagious (The Isley Brothers f/ R. Kelly)',
      expected: 'Contagious (The Isley Brothers f/ R. Kelly)',
      bug: 'MBS-1316',
      mode: 'English',
    },
    {
      input: 'X (extended version, Part 1) (feat. Peter Tosh & Bunny Wailer)',
      expected: 'X (extended version, Part 1) (feat. Peter Tosh & Bunny Wailer)',
      bug: 'MBS-1318',
      mode: 'English',
    },
    {
      input: "Hold on, I'm Coming",
      expected: "Hold On, I'm Coming",
      bug: 'MBS-3013',
      mode: 'English',
    },
    {
      input: 'I’ll do something - Johnny’s great band',
      expected: 'I’ll Do Something - Johnny’s Great Band',
      bug: 'MBS-2923',
      mode: 'English',
    },
    {
      input: '10000 dB Goa Trance',
      expected: '10000 dB Goa Trance',
      bug: 'MBS-2756',
      mode: 'English',
    },
    {
      input: "Hey c'Mon Everybody",
      expected: "Hey C'mon Everybody",
      bug: 'MBS-8867',
      mode: 'English',
    },
    {
      input: "Hey c'Mon Everybody",
      expected: "Hey c'mon everybody",
      bug: 'MBS-11264',
      mode: 'French',
    },
    {
      input: 'We Love Techno (Remode)',
      expected: 'We Love Techno (remode)',
      bug: 'MBS-10156',
      mode: 'English',
    },
    {
      input: 'We Love Techno (Stereo)',
      expected: 'We Love Techno (stereo)',
      bug: 'MBS-10161',
      mode: 'English',
    },
    {
      input: '¿qué No? ¡anda Que No!',
      expected: '¿Qué no? ¡Anda que no!',
      bug: 'MBS-1549',
      mode: 'Sentence',
    },
    {
      input: '¿QUÉ NO? ¡ANDA QUE NO!',
      expected: '¿Qué no? ¡Anda que no!',
      bug: 'MBS-1549',
      mode: 'Sentence',
    },
    {
      input: 'Protect Ya Neck',
      expected: 'Protect Ya Neck',
      bug: 'MBS-9837',
      mode: 'English',
    },
    {
      input: 'Protect Ya Neck',
      expected: 'Protect ya Neck',
      bug: 'MBS-9837',
      mode: 'Turkish',
    },
    {
      input: 'I Love My iPad, My IPod and My Iphone!',
      expected: 'I Love My iPad, My iPod and My iPhone!',
      bug: 'MBS-7421',
      mode: 'English',
    },
    {
      input: 'A story of YouTube (youtube edit)',
      expected: 'A Story of YouTube (YouTube edit)',
      bug: 'MBS-12017',
      mode: 'English',
    },
    {
      input: 'Stuff with f',
      expected: 'Stuff With F',
      bug: 'MBS-10138',
      mode: 'English',
    },
    {
      input: '«quoted stuff»',
      expected: '« Quoted stuff »',
      bug: 'MBS-8232',
      mode: 'French',
    },
    {
      input: '“quoted stuff”',
      expected: '“Quoted Stuff”',
      bug: 'MBS-8232',
      mode: 'English',
    },
    {
      input: '[Unknown] / This track is / [Untitled]',
      expected: '[unknown] / This Track Is / [untitled]',
      bug: 'MBS-11662',
      mode: 'English',
    },
    {
      input: 'The Best Song (Official Video Mix)',
      expected: 'The Best Song (official video mix)',
      bug: 'MBS-11788',
      mode: 'English',
    },
    {
      input: 'The Best Song (Uncensored Explicit Video)',
      expected: 'The Best Song (uncensored explicit video)',
      bug: 'MBS-11797',
      mode: 'English',
    },
    /*
     * There is no fix for these yet.
     * {
     * input: "(Dance With the) Guitar Man",
     * expected: "(Dance With the) Guitar Man",
     * bug: "MBS-1317", mode: "English"
     * },
     * {
     * input: "My Life (Live to the Max)",
     * expected: "My Life (Live to the Max)",
     * bug: "MBS-1317", mode: "English"
     * },
     * {
     * input: "My Life (Club Is Open)",
     * expected: "My Life (Club Is Open)",
     * bug: "MBS-1317", mode: "English"
     * },
     * {
     * input: "Here I Am (Come and Take Me)",
     * expected: "Here I Am (Come and Take Me)",
     * bug: "MBS-1317", mode: "English"
     * }
     */
  ];

  for (const test of tests) {
    gc.CFG_KEEP_UPPERCASED = false;
    gc.modeName = test.mode;

    const result = gc.entities.work.guess(test.input);
    t.equal(result, test.expected, test.bug + ', ' + test.input);
  }
});

test('vinyl numbers are fixed', function (t) {
  t.plan(5);

  setCookie('guesscase_roman', 'false');
  gc.modeName = 'English';

  const tests = [
    {
      // MBS-3032
      input: 'Testing 7 in, 10in, 12" vinyl sizes in mix titles',
      expected: 'Testing 7 In, 10", 12" Vinyl Sizes in Mix Titles',
    },
    {
      input: "Fine Day (Mike Koglin 12' mix)",
      expected: 'Fine Day (Mike Koglin 12" mix)',
    },
    {
      input: 'Where Love Lives (12"Classic mix)',
      expected: 'Where Love Lives (12" Classic mix)',
    },
    {
      input: "7's 10's 12's",
      expected: "7's 10's 12's",
    },
    {
      input: "greatest 80's hits",
      expected: "Greatest 80's Hits",
    },
  ];

  for (const test of tests) {
    t.equal(gc.entities.track.guess(test.input), test.expected);
  }
});

test('no "quote blocks" over multiple track titles (MBS-8621)', function (t) {
  t.plan(3);

  setCookie('guesscase_roman', 'false');
  gc.modeName = 'English';

  const tests = [
    {
      input: 'Boot ’Em Up',
      expected: 'Boot ’em Up',
    },
    {
      input: 'Look, no apostrophes!',
      expected: 'Look, No Apostrophes!',
    },
    {
      input: 'Tryin’ To Get To You',
      expected: 'Tryin’ to Get to You',
    },
  ];

  for (const test of tests) {
    t.equal(gc.entities.track.guess(test.input), test.expected);
  }
});
