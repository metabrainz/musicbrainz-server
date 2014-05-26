// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

releaseEditor.test.module("release editor actions", releaseEditor.test.setupReleaseEdit);


test("removing a track should change the track numbers", function () {
    var tracks = this.release.mediums()[0].tracks();
    var track2 = tracks[1];

    equal(track2.number(), "2", "track has number \"2\" before removal");

    releaseEditor.removeTrack(tracks[0]);

    equal(tracks[0], track2, "first track was removed");
    equal(track2.number(), "1", "track has number \"1\" after removal");
});


test("removing a medium should change the medium positions", function () {
    this.release.mediums.push(
        releaseEditor.fields.Medium(releaseEditor.test.testMedium),
        releaseEditor.fields.Medium({ tracks: [], position: 3 })
    );

    var mediums = this.release.mediums();
    deepEqual(_.invoke(mediums, "position"), [1, 2, 3], "medium positions are consecutive before removal");

    releaseEditor.removeMedium(mediums[0]);
    deepEqual(_.invoke(mediums, "position"), [1, 2], "medium positions are consecutive after removal");
});


test("reordering tracks that have non-consecutive \"position\" properties (MBS-7227)", function () {
    var tracks = this.release.mediums()[0].tracks();
    var originalTrack1 = tracks[0];
    var originalTrack2 = tracks[1];

    originalTrack2.position(3);

    releaseEditor.moveTrackUp(originalTrack2);

    equal(tracks[0], originalTrack2, "original track 2 has moved to position 1");
    equal(originalTrack2.position(), 1, "original track 2 now has position() 1");

    equal(tracks[1], originalTrack1, "original track 1 has moved to position 2");
    equal(originalTrack1.position(), 2, "original track 1 now has position() 2");
});
