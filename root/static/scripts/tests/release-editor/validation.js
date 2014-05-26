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


test("duplicate release countries are rejected, including null ones (MBS-7624)", function () {
    releaseEditor.action = "edit";
    releaseEditor.rootField = releaseEditor.fields.Root();

    releaseEditor.releaseLoaded({
        events: [
            { countryID: 123, date: "1999" },
            { countryID: 123, date: "2000" },
            { countryID: null, date: "1999" },
            { countryID: null, date: "2000" },
        ]
    });

    var release = releaseEditor.rootField.release();
    var events = release.events();

    ok(events[0].countryID.error());
    ok(events[1].countryID.error());
    ok(events[2].countryID.error());
    ok(events[3].countryID.error());
});
