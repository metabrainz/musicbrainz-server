// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

var releaseEditor = MB.releaseEditor;


$.ajax = function () {
    var mockXHR = $.Deferred();

    mockXHR.success = mockXHR.done;
    mockXHR.error = mockXHR.fail;
    mockXHR.complete = mockXHR.always;

    return mockXHR;
};


module("release editor fields", {

    setup: function () {
        $("#qunit-fixture").append($("<div>").attr("id", "release-editor"));

        releaseEditor.action = "add";
        releaseEditor.rootField = releaseEditor.fields.Root();
        releaseEditor.seed({ seed: {} });

        this.release = releaseEditor.rootField.release();
    },

    teardown: function () {
        releaseEditor.rootField.release(null);
    }
});


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
