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
