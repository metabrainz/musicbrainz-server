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

    var release = releaseEditor.rootField.release(),
        medium = release.mediums()[0];

    ok(!medium.loaded(), "medium is not loaded");
    ok(!medium.needsTracks(), "medium doesn't require tracks");
    ok(!medium.needsTrackInfo(), "medium doesn't require track info");
    ok(!medium.needsRecordings(), "medium doesn't require recordings");
    ok(!release.needsMediums(), "release doesn't need mediums");
    ok(!release.needsTracks(), "release doesn't need tracks");
    ok(!release.needsTrackInfo(), "release doesn't need track info");
    ok(!release.needsRecordings(), "release doesn't need recordings");
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

    ok(events[0].isDuplicate());
    ok(events[1].isDuplicate());
    ok(events[2].isDuplicate());
    ok(events[3].isDuplicate());
    ok(releaseEditor.validation.errorsExist());
});
