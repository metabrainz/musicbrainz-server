// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

releaseEditor.test.module("release editor validation");


test("non-loaded mediums validate, even though they have no tracks (MBS-7222)", function () {
    releaseEditor.action = "edit";
    releaseEditor.rootField = releaseEditor.fields.Root();

    releaseEditor.releaseLoaded({
        mediums: [
            { id: 123, position: 1, tracks: [] },
        ]
    });

    var release = releaseEditor.rootField.release();

    ok(!release.mediums()[0].loaded(), "medium is not loaded");
    ok(!release.mediums()[0].tracks.error(), "tracks are error-free");
});
