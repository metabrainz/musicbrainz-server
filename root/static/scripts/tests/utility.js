MB.tests.utility = (MB.tests.utility) ? MB.tests.utility : {};

MB.tests.utility.All = function() {
    QUnit.module('utility');
    QUnit.test('All', function() {

        var input = "ＭｕｓｉｃＢｒａｉｎｚ！～２０１１";
        var expected = "MusicBrainz!~2011";
        QUnit.equal (MB.utility.fullWidthConverter (input),
                      expected, "fullWidthConverter (" + input + ")");

        input1 = {
            'length': '4:03',
            'title': 'the Love bug',
            'names': [
                { 'name': 'm-flo', 'id': '135345' },
                { 'name': 'BoA', 'id': '9496' }
            ]
        };

        input2 = {
            'names': [
                { 'id': '135345', 'name': 'm-flo' },
                { 'name': 'BoA', 'id': '9496' }
            ],
            'title': 'the Love bug',
            'length': '4:03'
        };

        input3 = {
            'names': [
                { 'name': 'BoA', 'id': '9496' },
                { 'id': '135345', 'name': 'm-flo' }
            ],
            'title': 'the Love bug',
            'length': '4:03'
        };

        QUnit.equal (MB.utility.structureToString (input1),
                     MB.utility.structureToString (input2),
                     'structureToString equivalent');
        QUnit.notEqual (MB.utility.structureToString (input2),
                        MB.utility.structureToString (input3),
                        'structureToString different');

        var input1sha = b64_sha1 (MB.utility.structureToString (input1));
        QUnit.equal (input1sha, "aIkUXodpaNX7Q1YfttiKMkKCxB0", "SHA-1 of input1");

        var seconds = 1000;
        var minutes = 60 * seconds;
        var hours = 60 * minutes;

        QUnit.equal (MB.utility.formatTrackLength (23), '23 ms', 'formatTrackLength');
        QUnit.equal (MB.utility.formatTrackLength (260586), '4:21', 'formatTrackLength');
        QUnit.equal (MB.utility.formatTrackLength (23 * seconds), '0:23', 'formatTrackLength');
        QUnit.equal (MB.utility.formatTrackLength (59 * minutes), '59:00', 'formatTrackLength');
        QUnit.equal (MB.utility.formatTrackLength (60 * minutes), '1:00:00', 'formatTrackLength');
        QUnit.equal (MB.utility.formatTrackLength (14 * hours + 15 * minutes + 16 * seconds), '14:15:16', 'formatTrackLength');

        QUnit.equal (MB.utility.unformatTrackLength ('?:??'), null, 'MBS-5086: unformatTrackLength(?:??) should be null');
        QUnit.equal (MB.utility.unformatTrackLength ('23 ms'), 23, 'unformatTrackLength');
        QUnit.equal (MB.utility.unformatTrackLength ('00:23'), 23 * seconds, 'unformatTrackLength');
        QUnit.equal (MB.utility.unformatTrackLength (':57'), 57 * seconds, 'MBS-3352: Handle the case of ":57"');
        QUnit.equal (MB.utility.unformatTrackLength ('59:00'), 59 * minutes, 'unformatTrackLength');
        QUnit.equal (MB.utility.unformatTrackLength ('01:00:00'), 60 * minutes, 'unformatTrackLength');
        QUnit.equal (MB.utility.unformatTrackLength ('14:15:16'), 14 * hours + 15 * minutes + 16 * seconds, 'unformatTrackLength');
    });

};

MB.tests.utility.Run = function() {
    MB.tests.utility.All ();
};


