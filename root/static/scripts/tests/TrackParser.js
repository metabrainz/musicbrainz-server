MB.tests.TrackParser = (MB.tests.TrackParser) ? MB.tests.TrackParser : {};

MB.tests.TrackParser.ReleaseDiscMock = function () {
    var self = MB.Object ();

    self.hasToc = function () { return false; }
    self.isVariousArtists = function () { return false; }

    return self;
};

MB.tests.TrackParser.BugFixes = function() {
    QUnit.module('Track Parser');
    QUnit.test('Tracknumbers', function() {

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
                    { number: "a1", title: "Kermis" },
                    { number: "a2", title: "Glitch" },
                    { number: "a3", title: "Afrik Slang" },
                    { number: "4", title: "Rot Beat" },
                    { number: "5", title: "Pruik" },
                    { number: "6", title: "In Je Graff" },
                    { number: "7", title: "Ｈｉｌｌｗｏｏｄ" },
               ],
                tracknumbers: true, vinylnumbers: true, tracktimes: true
            }
        ];

        $.each(tests, function(idx, test) {
            var disc = MB.tests.TrackParser.ReleaseDiscMock ();
            var parser = MB.TrackParser.Parser (disc);
            parser.setOptions (test);

            var result = parser.getTrackInput (test.input);

            $.each (test.expected, function (idx, expected) {
                var r = result[idx];
                QUnit.equal(r.number, expected.number, expected.number);
                QUnit.equal(r.title, expected.title, expected.title);
            });
        });

    });


    QUnit.test('BugFixes', function() {

        var tests = [
            {
                input: "1. Forgotten Child    3:39   \n" +
                    "2. Dirty Looks  4:34  \n" +
                    "  3. Private Life  3:29 \n" +
                    "4.  Never Can Wait  3:24 ",
                expected: [
                    { title: "Forgotten Child", duration: 219000 },
                    { title: "Dirty Looks",     duration: 274000 },
                    { title: "Private Life",    duration: 209000 },
                    { title: "Never Can Wait",  duration: 204000 }
                ],
                bug: 'MBS-1284',
                tracknumbers: true, vinylnumbers: false, tracktimes: true
            },
            {
                input: "1. Criminology 2.5 \n",
                expected: [
                    { title: "Criminology 2.5", duration: null }
                ],
                bug: 'MBS-2511',
                tracknumbers: true, vinylnumbers: false, tracktimes: true
            },
            {
                input: "1 Freeman Hardy & Willis Acid\n\n" +
                    "   Written-By – James*, Jenkinson* \n\n" +
                    "5:42\n" +
                    "2 Orange Romeda\n\n" +
                    "Written-By – Eoin*, Sandison* \n\n" +
                    "4:51 \n",
                expected: [
                    { title: "Freeman Hardy & Willis Acid", duration: null },
                    { title: "Orange Romeda", duration: null }
                ],
                bug: 'MBS-2540',
                tracknumbers: true, vinylnumbers: false, tracktimes: true
            },
            {
                input: "1. Love On A .45\n",
                expected: [ { title: "Love On A .45", duration: null } ],
                bug: 'MBS-2902',
                tracknumbers: true, vinylnumbers: false, tracktimes: true
            },
            {
                input: "1. Love On A .45  05:22:31\n",
                expected: [ { title: "Love On A .45", duration: 19351000 } ],
                bug: 'MBS-3353',
                tracknumbers: true, vinylnumbers: false, tracktimes: true
            }
        ];

        $.each(tests, function(idx, test) {
            var disc = MB.tests.TrackParser.ReleaseDiscMock ();
            var parser = MB.TrackParser.Parser (disc);
            parser.setOptions (test);

            var result = parser.getTrackInput (test.input);

            $.each (test.expected, function (idx, expected) {
                var r = result[idx];
                QUnit.equal(r.position, idx+1, test.bug + ', ' + expected.title);
                QUnit.equal(r.title, expected.title, test.bug + ', ' + expected.title);
                QUnit.equal(r.duration, expected.duration, test.bug + ', ' + expected.title);
            });
        });

    });
};

MB.tests.TrackParser.Run = function() {
    MB.tests.TrackParser.BugFixes ();
};
