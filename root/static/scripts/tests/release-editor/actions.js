// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import _ from 'lodash';
import test from 'tape';

import actions from '../../release-editor/actions';
import fields from '../../release-editor/fields';

import * as common from './common';

test("removing a track should change the track numbers", function (t) {
    t.plan(3);

    var release = common.setupReleaseEdit();
    var tracks = release.mediums()[0].tracks();
    var track2 = tracks[1];

    t.equal(track2.number(), "2", "track has number \"2\" before removal");

    actions.removeTrack(tracks[0]);

    t.equal(tracks[0], track2, "first track was removed");
    t.equal(+track2.number(), 1, "track has number \"1\" after removal");
});

test("removing a medium should change the medium positions", function (t) {
    t.plan(2);

    var release = common.setupReleaseEdit();

    release.mediums.push(
        new fields.Medium(common.testMedium),
        new fields.Medium({ tracks: [], position: 3 }),
    );

    var mediums = release.mediums();
    t.deepEqual(_.invokeMap(mediums, "position"), [1, 2, 3], "medium positions are consecutive before removal");

    actions.removeMedium(mediums[0]);
    t.deepEqual(_.invokeMap(mediums, "position"), [1, 2], "medium positions are consecutive after removal");
});

test("reordering tracks that have non-consecutive \"position\" properties (MBS-7227)", function (t) {
    t.plan(4);

    var release = common.setupReleaseEdit();
    var tracks = release.mediums()[0].tracks();
    var originalTrack1 = tracks[0];
    var originalTrack2 = tracks[1];

    originalTrack2.position(3);

    actions.moveTrackUp(originalTrack2);

    t.equal(tracks[0], originalTrack2, "original track 2 has moved to position 1");
    t.equal(originalTrack2.position(), 1, "original track 2 now has position() 1");

    t.equal(tracks[1], originalTrack1, "original track 1 has moved to position 2");
    t.equal(originalTrack1.position(), 2, "original track 1 now has position() 2");
});
