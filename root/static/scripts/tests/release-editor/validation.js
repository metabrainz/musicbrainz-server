// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

var test = require('tape');

var releaseEditor = MB.releaseEditor;

function validationTest(name, callback) {
    test(name, function (t) {
        callback(t);
        releaseEditor.validation.errorFields([]);
    });
}

validationTest("non-loaded mediums validate, even though they have no tracks (MBS-7222)", function (t) {
    t.plan(8);

    releaseEditor.action = "edit";
    releaseEditor.rootField = releaseEditor.fields.Root();

    releaseEditor.releaseLoaded({
        mediums: [
            { id: 123, position: 1, tracks: [] },
        ]
    });

    var release = releaseEditor.rootField.release(),
        medium = release.mediums()[0];

    t.ok(!medium.loaded(), "medium is not loaded");
    t.ok(!medium.needsTracks(), "medium doesn't require tracks");
    t.ok(!medium.needsTrackInfo(), "medium doesn't require track info");
    t.ok(!medium.needsRecordings(), "medium doesn't require recordings");
    t.ok(!release.needsMediums(), "release doesn't need mediums");
    t.ok(!release.needsTracks(), "release doesn't need tracks");
    t.ok(!release.needsTrackInfo(), "release doesn't need track info");
    t.ok(!release.needsRecordings(), "release doesn't need recordings");
});

validationTest("duplicate release countries are rejected, including null ones (MBS-7624)", function (t) {
    t.plan(5);

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

    t.ok(events[0].isDuplicate());
    t.ok(events[1].isDuplicate());
    t.ok(events[2].isDuplicate());
    t.ok(events[3].isDuplicate());
    t.ok(releaseEditor.validation.errorsExist());
});
