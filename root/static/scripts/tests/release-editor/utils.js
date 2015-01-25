// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

var test = require('tape');

test('unformatTrackLength', function (t) {
    t.plan(7);

    var unformatTrackLength = MB.releaseEditor.utils.unformatTrackLength;

    var seconds = 1000;
    var minutes = 60 * seconds;
    var hours = 60 * minutes;

    t.equal(unformatTrackLength('?:??'), null, 'MBS-5086: unformatTrackLength(?:??) should be null');
    t.equal(unformatTrackLength('23 ms'), 23, 'unformatTrackLength');
    t.equal(unformatTrackLength('00:23'), 23 * seconds, 'unformatTrackLength');
    t.equal(unformatTrackLength(':57'), 57 * seconds, 'MBS-3352: Handle the case of ":57"');
    t.equal(unformatTrackLength('59:00'), 59 * minutes, 'unformatTrackLength');
    t.equal(unformatTrackLength('01:00:00'), 60 * minutes, 'unformatTrackLength');
    t.equal(unformatTrackLength('14:15:16'), 14 * hours + 15 * minutes + 16 * seconds, 'unformatTrackLength');
});
