// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2013 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

var _ = require('lodash');
var test = require('tape');

test('Sortname', function (t) {
    t.plan(6);

    var tests = [
        {
            input: 'Members Of Mayday',
            expected: 'Members Of Mayday',
            person: false
        },
        {
            input: 'The Prodigy & Tom Morello',
            expected: 'Prodigy, The & Morello, Tom',
            person: true
        },
        {
            input: 'DJ Shadow',
            expected: 'Shadow, DJ',
            person: true
        }
    ];

    $.each(tests, function (idx, test) {
        var result = MB.GuessCase.artist.sortname(test.input, test.person);
        t.equal(result, test.expected, test.input);
    });

    tests = [
        {
            input: 'Da! Heard It Records',
            expected: 'Da! Heard It Records'
        },
        {
            input: "The Cadenza Collection",
            expected: "Cadenza Collection, The"
        },
        {
            input: "Los Enanos Gigantes",
            expected: "Enanos Gigantes, Los"
        }
        /* FIXME: improve article code.  These should be handled.
        {
            input: "L'Amicale underground",
            expected: "Amicale underground, L'"
        },
        {
            input: "Les Industries Musicales et Électriques Pathé Marconi",
            expected: "Industries Musicales et Électriques Pathé Marconi, Les"
        },
        {
            input: "Die Schöne Blumen Musik Werk",
            expected: "Schöne Blumen Musik Werk, Die"
        }
        */
    ];

    $.each(tests, function (idx, test) {
        var result = MB.GuessCase.label.sortname(test.input);
        t.equal(result, test.expected, test.input);
    });
});

test('Artist', function (t) {
    t.plan(8);

    var tests = [
        {
            input: 'Members Of Mayday',
            expected: 'Members of Mayday'
        },
        {
            input: 'the prodigy & tom morello',
            expected: 'The Prodigy & Tom Morello'
        },
        { input: ' ',         expected: '[unknown]' },
        { input: 'n/a',       expected: '[unknown]' },
        { input: 'NONE',      expected: '[unknown]' },
        { input: 'unknown',   expected: '[unknown]' },
        { input: 'No Artist', expected: '[unknown]' },
        {
            input: "Peggy Sue And The Pirates",
            expected: "Peggy Sue and The Pirates",
            bug: "MBS-1370", mode: "Artist"
        }
    ];

    $.each(tests, function (idx, test) {
        var result = MB.GuessCase.artist.guess(test.input);

        var prefix = test.bug ? test.bug + ', ' : '';

        t.equal(result, test.expected, prefix + test.input);
    });
});

test('Label', function (t) {
    t.plan(6);

    var tests = [
        {
            input: 'da! heard it records',
            expected: 'Da! Heard It Records'
        },
        { input: ' ',         expected: '[unknown]' },
        { input: 'n/a',       expected: '[unknown]' },
        { input: 'NONE',      expected: '[unknown]' },
        { input: 'unknown',   expected: '[unknown]' },
        { input: 'No Label',  expected: '[unknown]' }
    ];

    $.each(tests, function (idx, test) {
        var result = MB.GuessCase.label.guess(test.input);
        t.equal(result, test.expected, test.input);
    });
});

test('Recording', function (t) {
    t.plan(2);

    var tests = [
        {
            input: "ハイタッチ (w/o maaya)",
            expected: "ハイタッチ (w/o Maaya)",
            message: 'w/o is not capitalized'
        },
        {
            input: "ハイタッチ (w／o maaya)",
            expected: "ハイタッチ (w／o Maaya)",
            message: 'w／o is not capitalized'
        }
    ];

    _.each(tests, function (test) {
        t.equal(
            MB.GuessCase.recording.guess(test.input),
            test.expected,
            test.message
        );
    });
});

test('Work', function (t) {
    t.plan(7);

    var tests = [
        {
            input: "WE LOVE TECHPARA VI",
            expected: "WE LOVE TECHPARA VI",
            mode: "English", roman: true, keepuppercase: true
        },
        {
            input: "WE LOVE TECHPARA VI",
            expected: "We Love Techpara VI",
            mode: "English", roman: true, keepuppercase: false
        },
        {
            input: "WE LOVE TECHPARA VI",
            expected: "We Love Techpara Vi",
            mode: "English", roman: false, keepuppercase: false
        },
        {
            input: "WE LOVE TECHPARA VI",
            expected: "We love techpara VI",
            mode: "Sentence", roman: true, keepuppercase: false
        },
        {
            input: "acte 1, no. 7: chœur: «voyons brigadier»",
            expected: "Acte 1, no. 7 : Chœur : « voyons brigadier »",
            mode: "French", roman: false, keepuppercase: false
        },
        {
            input: "American Way ft. Kelis",
            expected: "American Way (feat. Kelis)",
            mode: "English", roman: true, keepuppercase: false
        },
        {
            input: "Bring It All To Me (f. 50 Cent)",
            expected: "Bring It All to Me (feat. 50 Cent)",
            mode: "English", roman: true, keepuppercase: false
        }
    ];

    $.each(tests, function (idx, test) {
        gc.CFG_UC_ROMANNUMERALS = test.roman;
        gc.CFG_UC_UPPERCASED = test.keepuppercase;
        gc.mode = MB.GuessCase.Mode[test.mode];

        var result = MB.GuessCase.work.guess(test.input);
        t.equal(result, test.expected, test.input);
    });
});

test('BugFixes', function (t) {
    t.plan(15);

    var tests = [
        {
            input: "Je T’Aime Moi… Non Plus (feat. Miss Kittin)",
            expected: "Je T’Aime Moi… Non Plus (feat. Miss Kittin)",
            bug: 'MBS-991', mode: "English"
        },
        {
            input: "E Pra Sempre Te Amar: Ao Vivo",
            expected: "E pra sempre te amar: Ao vivo",
            bug: 'MBS-1311', mode: "Sentence"
        },
        {
            input: "Me Esqueça / No Limite / Desesperadamente Apaixonado",
            expected: "Me esqueça / No limite / Desesperadamente apaixonado",
            bug: 'MBS-1311', mode: "Sentence"
        },
        {
            input: "Megablast (Rap Version) (ft. Merlin)",
            expected: "Megablast (rap version) (feat. Merlin)",
            bug: 'MBS-1313', mode: "English"
        },
        {
            input: "너 (Techno Version)",
            expected: "너 (techno version)",
            bug: 'MBS-1313', mode: "English"
        },
        {
            input: "aka AKA a.k.a. A.K.A. a/k/a A/K/A",
            expected: "a.k.a. a.k.a. a.k.a. a.k.a. a.k.a. a.k.a.",
            bug: "MBS-1314", mode: "English"
        },
        {
            input: "Boy In Da Corner / Fire Ina Hole / Bird Inna De Nest / Rock Di Mexicano",
            expected: "Boy in da Corner / Fire ina Hole / Bird inna de Nest / Rock di Mexicano",
            bug: "MBS-1315", mode: "English"
        },
        {
            input: "We Ready Fe Dem / Santa Fe Express / We Come Fi Rock",
            expected: "We Ready fe Dem / Santa Fe Express / We Come fi Rock",
            bug: "MBS-1315", mode: "English"
        },
        {
            input: "Contagious (The Isley Brothers f/ R. Kelly)",
            expected: "Contagious (The Isley Brothers feat. R. Kelly)",
            bug: "MBS-1316", mode: "English"
        },
        {
            input: "X (extended version, Part 1) (feat. Peter Tosh & Bunny Wailer)",
            expected: "X (extended version, Part 1) (feat. Peter Tosh & Bunny Wailer)",
            bug: "MBS-1318", mode: "English"
        },
        {
            input: "Hold on, I'm Coming",
            expected: "Hold On, I'm Coming",
            bug: "MBS-3013", mode: "English"
        },
        {
            input: "I’ll do something - Johnny’s great band",
            expected: "I’ll Do Something - Johnny’s Great Band",
            bug: "MBS-2923", mode: "English"
        },
        {
            input: "10000 dB Goa Trance",
            expected: "10000 dB Goa Trance",
            bug: "MBS-2756", mode: "English"
        },
        {
            input: "¿qué No? ¡anda Que No!",
            expected: "¿Qué no? ¡Anda que no!",
            bug: "MBS-1549", mode: "Sentence"
        },
        {
            input: "¿QUÉ NO? ¡ANDA QUE NO!",
            expected: "¿Qué no? ¡Anda que no!",
            bug: "MBS-1549", mode: "Sentence"
        }

        /* There is no fix for these yet.
        {
            input: "(Dance With the) Guitar Man",
            expected: "(Dance With the) Guitar Man",
            bug: "MBS-1317", mode: "English"
        },
        {
            input: "My Life (Live to the Max)",
            expected: "My Life (Live to the Max)",
            bug: "MBS-1317", mode: "English"
        },
        {
            input: "My Life (Club Is Open)",
            expected: "My Life (Club Is Open)",
            bug: "MBS-1317", mode: "English"
        },
        {
            input: "Here I Am (Come and Take Me)",
            expected: "Here I Am (Come and Take Me)",
            bug: "MBS-1317", mode: "English"
        }
        */
    ];

    $.each(tests, function (idx, test) {
        gc.mode = MB.GuessCase.Mode[test.mode];

        var result = MB.GuessCase.work.guess(test.input);
        t.equal(result, test.expected, test.bug + ', ' + test.input);
    });
});

test("vinyl numbers are fixed", function (t) {
    t.plan(4);

    gc.mode = MB.GuessCase.Mode.English;

    var tests = [
        {
            // MBS-3032
            input: 'Testing 7 in, 10in, 12" vinyl sizes in mix titles',
            expected: 'Testing 7 In, 10", 12" Vinyl Sizes in Mix Titles'
        },
        {
            input: "Fine Day (Mike Koglin 12' mix)",
            expected: "Fine Day (Mike Koglin 12\" mix)"
        },
        {
            input: "Where Love Lives (12\"Classic mix)",
            expected: "Where Love Lives (12\" Classic mix)"
        },
        {
            input: "7's 10's 12's",
            expected: "7's 10's 12's"
        }
    ];

    _.each(tests, function (test) {
        t.equal(MB.GuessCase.track.guess(test.input), test.expected);
    });
});
