MB.tests.TrackParser = (MB.tests.TrackParser) ? MB.tests.TrackParser : {};

MB.tests.TrackParser.ReleaseDiscMock = function () {
    var self = MB.Object ();

    self.hasToc = function () { return false; }
    self.isVariousArtists = function () { return false; }

    return self;
};

MB.tests.TrackParser.BugFixes = function() {
    QUnit.module('Track Parser');
    QUnit.test('BugFixes', function() {

        var tests = [
            {
                input: "1. Forgotten Child    3:39   \n" +
                    "2. Dirty Looks  4:34  \n" +
                    "  3. Private Life  3:29 \n" +
                    "4.  Never Can Wait  3:24 ",
                expected: [
                    { title: "Forgotten Child", duration: "3:39" },
                    { title: "Dirty Looks",     duration: "4:34" },
                    { title: "Private Life",    duration: "3:29" },
                    { title: "Never Can Wait",  duration: "3:24" }
                ],
                bug: 'MBS-1284',
                tracknumbers: true, vinylnumbers: false, tracktimes: true
            }
        ];

        $.each(tests, function(idx, test) {
            var $textarea = $('textarea.tracklist');
            var disc = MB.tests.TrackParser.ReleaseDiscMock ();
            var parser = MB.TrackParser.Parser (disc, $textarea);
            parser.setOptions (test);

            $textarea.val (test.input);
            var result = parser.getTrackInput ();

            $.each (test.expected, function (idx, expected) {
                var r = result[idx];
                QUnit.equals(r.position, idx+1, test.bug + ', ' + expected.title);
                QUnit.equals(r.title, expected.title, test.bug + ', ' + expected.title);
                QUnit.equals(r.duration, expected.duration, test.bug + ', ' + expected.title);
            });
        });

    });
};

MB.tests.TrackParser.Run = function() {
    MB.tests.TrackParser.BugFixes ();
};
