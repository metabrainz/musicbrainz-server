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
