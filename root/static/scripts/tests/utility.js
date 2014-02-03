// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

module('utility');


test('All', function () {

    var input = "ＭｕｓｉｃＢｒａｉｎｚ！～２０１１";
    var expected = "MusicBrainz!~2011";
    equal (MB.utility.fullWidthConverter (input),
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

    equal (MB.utility.structureToString (input1),
                 MB.utility.structureToString (input2),
                 'structureToString equivalent');
    notEqual (MB.utility.structureToString (input2),
                    MB.utility.structureToString (input3),
                    'structureToString different');

    var input1sha = b64_sha1 (MB.utility.structureToString (input1));
    equal (input1sha, "aIkUXodpaNX7Q1YfttiKMkKCxB0", "SHA-1 of input1");

    var seconds = 1000;
    var minutes = 60 * seconds;
    var hours = 60 * minutes;

    equal (MB.utility.formatTrackLength (23), '23 ms', 'formatTrackLength');
    equal (MB.utility.formatTrackLength (260586), '4:21', 'formatTrackLength');
    equal (MB.utility.formatTrackLength (23 * seconds), '0:23', 'formatTrackLength');
    equal (MB.utility.formatTrackLength (59 * minutes), '59:00', 'formatTrackLength');
    equal (MB.utility.formatTrackLength (60 * minutes), '1:00:00', 'formatTrackLength');
    equal (MB.utility.formatTrackLength (14 * hours + 15 * minutes + 16 * seconds), '14:15:16', 'formatTrackLength');

    equal (MB.utility.unformatTrackLength ('?:??'), null, 'MBS-5086: unformatTrackLength(?:??) should be null');
    equal (MB.utility.unformatTrackLength ('23 ms'), 23, 'unformatTrackLength');
    equal (MB.utility.unformatTrackLength ('00:23'), 23 * seconds, 'unformatTrackLength');
    equal (MB.utility.unformatTrackLength (':57'), 57 * seconds, 'MBS-3352: Handle the case of ":57"');
    equal (MB.utility.unformatTrackLength ('59:00'), 59 * minutes, 'unformatTrackLength');
    equal (MB.utility.unformatTrackLength ('01:00:00'), 60 * minutes, 'unformatTrackLength');
    equal (MB.utility.unformatTrackLength ('14:15:16'), 14 * hours + 15 * minutes + 16 * seconds, 'unformatTrackLength');

    equal (MB.utility.validDate(1960, 2, 29), true, 'MBS-5663: validDate should handle leap years');
});


test('filesize.js wrapper', function () {

    equal (MB.utility.filesize (857372), "837.3KB");
    equal (MB.utility.filesize (1235783), "1.2MB");
    equal (MB.utility.filesize (7440138), "7.1MB");
    equal (MB.utility.filesize (2379302), "2.3MB");
    equal (MB.utility.filesize (159985050), "152.5MB");

});
