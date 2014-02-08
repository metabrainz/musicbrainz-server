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
    });

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
