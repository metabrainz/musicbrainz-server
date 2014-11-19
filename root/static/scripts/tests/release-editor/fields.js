// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

releaseEditor.test.module("release editor fields", releaseEditor.test.setupReleaseAdd);


test("release group types being preserved after editing the name", function () {
    var releaseGroup = this.release.releaseGroup;

    releaseGroup().typeID(3);
    releaseGroup().secondaryTypeIDs([1, 3, 5]);

    var $autocomplete = $("<input/>").val("foo");

    ko.applyBindingsToNode($autocomplete[0], {
        autocomplete: {
            entity: "release-group",
            currentSelection: releaseGroup,
            entityConstructor: releaseEditor.fields.ReleaseGroup
        }
    });

    $autocomplete.val("bar").trigger("input");

    equal(releaseGroup().typeID(), 3, "primary type is preserved");
    deepEqual(releaseGroup().secondaryTypeIDs(), [1, 3, 5], "secondary types are preserved");

    $autocomplete.autocomplete("destroy");
});


test("mediums having their \"loaded\" observable set correctly", function () {
    var fields = releaseEditor.fields;
    var mediums = this.release.mediums;

    mediums([
        fields.Medium({ tracks: [] }),
        fields.Medium({ tracks: [ {} ] }),
        fields.Medium({ id: 1, tracks: [] }),
        fields.Medium({ originalID: 1, tracks: [] }),
        fields.Medium({ id: 1, tracks: [ {} ] }),
        fields.Medium({ originalID: 1, tracks: [ {} ] })
    ]);

    equal(mediums()[0].loaded(), true, "medium without id or tracks is considered loaded");
    equal(mediums()[1].loaded(), true, "medium without id but with tracks is considered loaded");
    equal(mediums()[2].loaded(), false, "medium with id but without tracks is considered not loaded")
    equal(mediums()[3].loaded(), false, "medium with originalID but without tracks is considered not loaded");
    equal(mediums()[4].loaded(), true, "medium with id and with tracks is considered loaded")
    equal(mediums()[5].loaded(), true, "medium with originalID and with tracks is considered loaded");

});


test("loading a medium doesn't overwrite its original edit data", function () {
    var fields = releaseEditor.fields;

    var medium = fields.Medium({
        id: 123,
        position: 1,
        formatID: 1,
        name: "foo",
        tracks: []
    }, this.release);

    this.release.mediums([ medium ]);

    medium.position(2);
    medium.formatID(2);
    medium.name("bar");

    ok(!medium.loaded(), "medium is not loaded");

    var original = medium.original();

    equal(original.position, 1, "original position is 1");
    equal(original.format_id, 1, "original format_id is 1");
    equal(original.name, "foo", "original name is foo");

    medium.tracksLoaded({
        tracks: [ { position: 1, name: "~fooo~", length: 12345 } ]
    });

    ok(medium.loaded(), "medium is loaded");

    original = medium.original();

    equal(original.position, 1, "original position is still 1");
    equal(original.format_id, 1, "original format_id is still 1");
    equal(original.name, "foo", "original name is still foo");

    var loadedTrack = original.tracklist[0];

    equal(loadedTrack.position, 1, "loaded track position is 1");
    equal(loadedTrack.name, "~fooo~", "loaded track name is ~foooo~");
    equal(loadedTrack.length, 12345, "loaded track length is 12345");
});


test("data tracks are appended with a correct position if there's a pregap (MBS-8013)", function () {
    var fields = releaseEditor.fields;

    var medium = fields.Medium({ tracks: [] }, this.release);
    medium.hasPregap(true);
    medium.hasDataTracks(true);

    equal(medium.tracks()[1].position(), 1);
});


test("tracks are set correctly when the cdtoc is changed", function () {
    var fields = releaseEditor.fields;

    function lengthsAndPositions() {
        return _.map(medium.tracks(), function (t) {
            return { length: t.length(), position: t.position() };
        });
    }

    var toc1 = "1 7 171327 150 22179 49905 69318 96240 121186 143398";
    var toc2 = "1 5 180562 150 28552 55959 88371 125305";

    var tocData1 = [
        { length: 294000, position: 1 },
        { length: 370000, position: 2 },
        { length: 259000, position: 3 },
        { length: 359000, position: 4 },
        { length: 333000, position: 5 },
        { length: 296000, position: 6 },
        { length: 372000, position: 7 }
    ];

    var tocData2 = [
        { length: 379000, position: 1 },
        { length: 365000, position: 2 },
        { length: 432000, position: 3 },
        { length: 492000, position: 4 },
        { length: 737000, position: 5 }
    ];

    var medium = fields.Medium({ tracks: [] }, this.release);

    // 7 tracks added
    medium.toc(toc1);
    deepEqual(lengthsAndPositions(), tocData1);

    // 2 tracks removed, lengths are changed
    medium.toc(toc2);
    deepEqual(lengthsAndPositions(), tocData2);

    // 2 tracks added, pregap doesn't affect positions
    medium.hasPregap(true);
    medium.toc(toc1);
    deepEqual(lengthsAndPositions(), Array.prototype.concat({ length: undefined, position: 0 }, tocData1));

    // 2 tracks removed, data tracks left at end
    medium.hasDataTracks(true);
    medium.toc(toc2);
    deepEqual(
        lengthsAndPositions(),
        Array.prototype.concat({ length: undefined, position: 0 }, tocData2, { length: undefined, position: 6 })
    );
    ok(_.last(medium.tracks()).isDataTrack());

    // 2 tracks added, data tracks left at end
    medium.toc(toc1);
    deepEqual(
        lengthsAndPositions(),
        Array.prototype.concat({ length: undefined, position: 0 }, tocData1, { length: undefined, position: 8 })
    );
    ok(_.last(medium.tracks()).isDataTrack());
});
