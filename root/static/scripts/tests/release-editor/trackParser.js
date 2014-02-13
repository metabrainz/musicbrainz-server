// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

module("track parser");


test("track numbers", function () {

    var tests = [
        {
            input: [
                "a1  Kermis         02:04",
                "a2.  Glitch        02:51",
                "a3.Afrik Slang     02:11",
                "4 Rot Beat         01:07",
                "5. Pruik           02:21",
                "6.In Je Graff      03:21",
                "７ Ｈｉｌｌｗｏｏｄ   ０２：３４"
            ].join ("\n"),
            expected: [
                { position: 1, number: "a1", name: "Kermis" },
                { position: 2, number: "a2", name: "Glitch" },
                { position: 3, number: "a3", name: "Afrik Slang" },
                { position: 4, number: "4", name: "Rot Beat" },
                { position: 5, number: "5", name: "Pruik" },
                { position: 6, number: "6", name: "In Je Graff" },
                { position: 7, number: "7", name: "Ｈｉｌｌｗｏｏｄ" },
           ],
            trackNumbers: true, vinylNumbers: true, trackTimes: true
        }
    ];

    $.each(tests, function(idx, test) {
        var parser = MB.releaseEditor.trackParser;

        parser.options = {
            trackNumbers: ko.observable(test.trackNumbers),
            vinylNumbers: ko.observable(test.vinylNumbers),
            trackTimes: ko.observable(test.trackTimes)
        };

        var result = parser.parse(test.input);

        $.each (test.expected, function (idx, expected) {
            var r = result[idx];

            QUnit.equal(r.position(), expected.position, expected.position.toString());
            QUnit.equal(r.number(), expected.number, expected.number);
            QUnit.equal(r.name(), expected.name, expected.name);
        });
    });

});


test("bug fixes", function() {

    var tests = [
        {
            input: "1. Forgotten Child    3:39   \n" +
                "2. Dirty Looks  4:34  \n" +
                "  3. Private Life  3:29 \n" +
                "4.  Never Can Wait  3:24 ",
            expected: [
                { position: 1, name: "Forgotten Child", formattedLength: "3:39" },
                { position: 2, name: "Dirty Looks",     formattedLength: "4:34" },
                { position: 3, name: "Private Life",    formattedLength: "3:29" },
                { position: 4, name: "Never Can Wait",  formattedLength: "3:24" }
            ],
            bug: 'MBS-1284',
            trackNumbers: true, vinylNumbers: false, trackTimes: true
        },
        {
            input: "1. Criminology 2.5 \n",
            expected: [
                { position: 1, name: "Criminology 2.5", formattedLength: "" }
            ],
            bug: 'MBS-2511',
            trackNumbers: true, vinylNumbers: false, trackTimes: true
        },
        {
            input: "1 Freeman Hardy & Willis Acid\n\n" +
                "   Written-By – James*, Jenkinson* \n\n" +
                "5:42\n" +
                "2 Orange Romeda\n\n" +
                "Written-By – Eoin*, Sandison* \n\n" +
                "4:51 \n",
            expected: [
                { position: 1, name: "Freeman Hardy & Willis Acid", formattedLength: "" },
                { position: 2, name: "Orange Romeda", formattedLength: "" }
            ],
            bug: 'MBS-2540',
            trackNumbers: true, vinylNumbers: false, trackTimes: true
        },
        {
            input: "1. Love On A .45\n",
            expected: [ { position: 1, name: "Love On A .45", formattedLength: "" } ],
            bug: 'MBS-2902',
            trackNumbers: true, vinylNumbers: false, trackTimes: true
        },
        {
            input: "1. Love On A .45  05:22:31\n",
            expected: [ { position: 1, name: "Love On A .45", formattedLength: "5:22:31" } ],
            bug: 'MBS-3353',
            trackNumbers: true, vinylNumbers: false, trackTimes: true
        }
    ];

    $.each(tests, function(idx, test) {
        var parser = MB.releaseEditor.trackParser;

        parser.options = {
            trackNumbers: ko.observable(test.trackNumbers),
            vinylNumbers: ko.observable(test.vinylNumbers),
            trackTimes: ko.observable(test.trackTimes)
        };
        var result = parser.parse(test.input);

        $.each (test.expected, function (idx, expected) {
            var r = result[idx];

            QUnit.equal(r.position(), expected.position, test.bug + ', ' + expected.position);
            QUnit.equal(r.number(), idx+1, test.bug + ', ' + expected.name);
            QUnit.equal(r.name(), expected.name, test.bug + ', ' + expected.name);
            QUnit.equal(r.formattedLength(), expected.formattedLength, test.bug + ', ' + expected.name);
        });
    });
});
