var testRelease = {
    entityType: "release",
    relationships: {},
    name: "Love Me Do / I Saw Her Standing There",
    artistCredit: [
        {
            artist: {
                entityType: "artist",
                sortName: "Beatles, The",
                name: "The Beatles",
                id: 303,
                gid: "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d"
            },
            joinPhrase: ""
        }
    ],
    id: 211431,
    mediums: [
        {
            tracks: [
                {
                    length: 143000,
                    number: "A",
                    recording: {
                        entityType: "recording",
                        length: 143000,
                        relationships: {},
                        name: "Love Me Do",
                        id: 6393661,
                        gid: "87ec065e-f139-41b9-b3b9-f746addf5b1e"
                    },
                    position: 1,
                    name: "Love Me Do",
                    artistCredit: []
                },
                {
                    length: 176000,
                    number: "B",
                    recording: {
                        entityType: "recording",
                        length: 176000,
                        relationships: {},
                        name: "I Saw Her Standing There",
                        id: 6393662,
                        gid: "6de731d6-7a8f-43a0-8cb0-1dca5a40d04e"
                    },
                    position: 2,
                    name: "I Saw Her Standing There",
                    artistCredit: []
                }
            ],
            format: "Vinyl",
            position: 1
        }
    ],
    gid: "867cc694-0f35-4a65-acb4-bc873795701a",
    releaseGroup: {
        entityType: "release_group",
        artist: "The Beatles",
        name: "Love Me Do",
        id: 564256,
        gid: "5db85281-934d-36e5-865c-1922ad82a948",
        relationships: {}
    }
};


function setupReleaseRelationshipEditor(self) {
    self.vm = self.RE.ReleaseViewModel({
        sourceData: _.omit(testRelease, "mediums")
    });

    self.vm.releaseLoaded(testRelease);
}

function setupGenericRelationshipEditor(self, options) {
    self.$form = $("<form>").attr("action", "#");

    self.$form[0].onsubmit = function () {
        return false;
    };

    var $inputs = $("<div>").attr("id", "relationship-editor");

    self.formData = function () {
        var inputsArray = _.toArray($inputs.find("input[type=hidden]"));
        return _.transform(inputsArray, function (result, input) { result[input.name] = input.value }, {});
    };

    $("#qunit-fixture").append(self.$form, $inputs);

    self.vm = self.RE.GenericEntityViewModel(options);
    MB.sourceRelationshipEditor = self.vm;
}


module("relationship editor", {

    setup: function () {
        $("#qunit-fixture").append('<div id="content"></div><div id="dialog"></div>');

        this.fakeGID0 = "a0ba91b0-c564-4eec-be2e-9ff071a47b59";
        this.fakeGID1 = "acb75d59-b0dc-4105-bad6-81ac8c66da4d";
        this.fakeGID2 = "c4804cb2-bf33-4394-bb5f-3fac972fa7a5";

        // _.defer makes its target functions asynchronous. It is redefined
        // here to call its target right away, so that we don't have to deal
        // with writing async tests.

        this.__defer = _.defer;

        _.defer = function (func) {
            func.apply(null, _.toArray(arguments).slice(1));
        }

        this.RE = MB.relationshipEditor;
    },

    teardown: function () {
        _.defer = this.__defer;

        this.vm = null;

        MB.entityCache = {};
        MB.sourceRelationshipEditor = null;
        delete sessionStorage.submittedRelationships;
    }
});


test("link phrase interpolation", function () {
    setupReleaseRelationshipEditor(this);

    var source = MB.entity({ entityType: "recording" });
    var target = MB.entity({ entityType: "artist" });

    var relationship = this.vm.getRelationship({
        target: target,
        linkTypeID: 148
    }, source);

    var entities = relationship.entities();

    // link phrase construction

    var tests = [
        // test attribute interpolation
        {
            linkTypeID: 148,
            attributes: [123, 229, 277, 596],
            expected: "solo zither, guitar and bass guitar"
        },
        {
            linkTypeID: 141,
            attributes: [424, 425],
            expected: "co-executive producer"
        },
        {
            linkTypeID: 154,
            attributes: [1, 69, 75, 109, 302],
            expected: "contains additional samples by",
            expectedExtra: "strings, guitars, lyre and plucked string instruments"
        },
        // MBS-6129
        {
            linkTypeID: 149,
            attributes: [4],
            expected: "lead vocals"
        },
        {
            linkTypeID: 149,
            attributes: [],
            expected: "vocals"
        }
    ];

    _.each(tests, function (test) {
        relationship.linkTypeID(test.linkTypeID);
        relationship.attributes(test.attributes);

        var result = relationship.phraseAndExtraAttributes();

        equal(
            result[entities.indexOf(source)],
            test.expected,
            [test.linkTypeID, JSON.stringify(test.attributes)].join(", ")
        );

        if (test.expectedExtra) {
            equal(result[2], test.expectedExtra);
        }
    });

    relationship.remove();
});


test("merging duplicate relationships", function () {
    setupReleaseRelationshipEditor(this);

    var source = MB.entity({ entityType: "recording", name: "foo" });
    var target = MB.entity({ entityType: "artist", name: "bar" });

    var relationship = this.vm.getRelationship({
        target: target,
        linkTypeID: 148,
        attributes: [123, 194, 277],
        beginDate: { year: 2001 },
        endDate: null,
        ended: false
    }, source);

    var duplicateRelationship = this.vm.getRelationship({
        target: target,
        linkTypeID: 148,
        attributes: [123, 194, 277],
        beginDate: null,
        endDate: { year: 2002 },
        ended: true
    }, source);

    relationship.show();
    duplicateRelationship.show();

    ok(source.mergeRelationship(duplicateRelationship), "relationships were merged");

    deepEqual(
        relationship.attributes(),
        [123, 194, 277],
        "attributes are the same"
    );

    deepEqual(
        ko.toJS(relationship.period),
        {
            beginDate: { year: 2001, month: null, day: null },
            endDate: { year: 2002, month: null, day: null },
            ended: true
        },
        "date period is merged correctly"
    );

    equal(source.relationships.indexOf(duplicateRelationship), -1,
          "source does not have duplicate relationship");

    ok(duplicateRelationship.removed(), "`removed` is true for duplicate");

    var notDuplicateRelationship = this.vm.getRelationship({
        target: target,
        linkTypeID: 148,
        beginDate: { year: 2003 },
        endDate: { year: 2004 }
    }, source);

    notDuplicateRelationship.show();

    ok(!source.mergeRelationship(notDuplicateRelationship),
       "relationship with different date is not merged");

    relationship.remove();
    duplicateRelationship.remove();
    notDuplicateRelationship.remove();
});


test("dialog backwardness", function () {
    setupReleaseRelationshipEditor(this);

    var self = this;

    var release = MB.entity({ entityType: "release" });
    var recording0 = MB.entity({ entityType: "recording" });
    var recording1 = MB.entity({ entityType: "recording" });

    var tests = [
        {
            input: {
                source: release,
                target: recording0
            },
            expected: {
                backward: true,
                entities: [recording0, release]
            }
        },
        {
            input: {
                source: recording0,
                target: release
            },
            expected: {
                backward: false,
                entities: [recording0, release]
            }
        },
        {
            input: {
                source: recording0,
                target: recording1
            },
            expected: {
                backward: false,
                entities: [recording0, recording1]
            }
        },
        {
            input: {
                source: recording1,
                target: recording0,
                direction: "backward"
            },
            expected: {
                backward: true,
                entities: [recording0, recording1]
            }
        }
    ];

    _.each(tests, function (test) {
        var options = _.assign({ viewModel: self.vm }, test.input);
        var dialog = self.RE.UI.AddDialog(options);

        equal(dialog.backward(), test.expected.backward)
        deepEqual(dialog.relationship().entities(), test.expected.entities);

        dialog.close();
    });
});


test("AddDialog", function () {
    setupReleaseRelationshipEditor(this);

    var source = this.vm.source.mediums()[0].tracks[0].recording;
    var target = MB.entity({ entityType: "artist", gid: this.fakeGID0 });

    var dialog = this.RE.UI.AddDialog({ source: source, target: target, viewModel: this.vm });
    var relationship = dialog.relationship();

    relationship.linkTypeID(148);
    relationship.attributes([229]);
    dialog.accept();

    equal(source.relationships()[0], relationship, "relationship is added");

    relationship.remove();
});


test("BatchRelationshipDialog", function () {
    setupReleaseRelationshipEditor(this);

    var target = MB.entity({ entityType: "artist", gid: this.fakeGID0 });
    var recordings = _.pluck(this.vm.source.mediums()[0].tracks, "recording");

    var dialog = this.RE.UI.BatchRelationshipDialog({
        sources: recordings,
        target: target,
        viewModel: this.vm
    });

    var relationship = dialog.relationship();
    var relationships;

    relationship.linkTypeID(154);
    relationship.attributes([1]);

    dialog.accept();

    relationships = recordings[0].relationships();
    equal(relationships[0].entities()[0], target, "recording 0 has relationship with correct target");
    deepEqual(relationships[0].attributes(), [1], "recording 0 has relationship with correct attributes");

    relationships = recordings[1].relationships();
    equal(relationships[0].entities()[0], target, "recording 1 has relationship with correct target");
    deepEqual(relationships[0].attributes(), [1], "recording 1 has relationship with correct attributes");
});


test("BatchCreateWorksDialog", function () {
    setupReleaseRelationshipEditor(this);

    var recordings = _.pluck(this.vm.source.mediums()[0].tracks, "recording");

    var dialog = this.RE.UI.BatchCreateWorksDialog({
        sources: recordings, viewModel: this.vm
    });

    // Mock edit submission.
    var _MB_edit_create = MB.edit.create;
    var self = this;

    MB.edit.create = function () {
        return $.Deferred().resolve({
            edits: [
                { entity: { name: "WorkFoo", gid: self.fakeGID0, entityType: "work" } },
                { entity: { name: "WorkBar", gid: self.fakeGID1, entityType: "work" } }
            ]
        });
    }

    dialog.accept();

    deepEqual(recordings[0].relationships()[0].entities(), [
        recordings[0], MB.entity({ gid: this.fakeGID0 }, "work")
    ]);

    deepEqual(recordings[1].relationships()[0].entities(), [
        recordings[1], MB.entity({ gid: this.fakeGID1 }, "work")
    ]);

    MB.edit.create = _MB_edit_create;
});


test("canceling an edit dialog reverts the changes", function () {
    setupReleaseRelationshipEditor(this);

    var source = this.vm.source.mediums()[0].tracks[0].recording;
    var target = MB.entity({ entityType: "artist", name: "foo", gid: this.fakeGID0 });

    var relationship = this.vm.getRelationship({
        target: target,
        linkTypeID: 148,
        attributes: [],
    }, source);

    var dialog = this.RE.UI.EditDialog({
        relationship: relationship,
        source: source,
        viewModel: this.vm
    });

    var newTarget = MB.entity({ entityType: "artist", name: "bar", gid: this.fakeGID1 });
    var dialogRelationship = dialog.relationship();

    dialogRelationship.entities([newTarget, source]);
    dialogRelationship.attributes([229]);
    dialogRelationship.period.beginDate.year(1999);
    dialogRelationship.period.endDate.year(2000);

    // cancel should revert the change
    dialog.close(true /* cancel */);

    deepEqual(relationship.entities(), [target, source], "entities changed back");
    deepEqual(relationship.attributes(), [], "attributes changed back");
    equal(relationship.period.beginDate.year(), null, "beginDate changed back");
    equal(relationship.period.endDate.year(), null, "endDate changed back");
});


test("MBS-5389: added recording-recording relationship appears under both recordings", function () {
    setupReleaseRelationshipEditor(this);

    var tracks = this.vm.source.mediums()[0].tracks;

    var recording0 = tracks[0].recording;
    var recording1 = tracks[1].recording;

    var dialog = this.RE.UI.AddDialog({ source: recording1, target: recording0, viewModel: this.vm });

    var relationship = dialog.relationship();
    relationship.linkTypeID(231);

    dialog.accept();

    equal(recording0.relationships()[0], relationship, "relationship added to recording 0");
    equal(recording1.relationships()[0], relationship, "relationship added to recording 1");

    relationship.remove();
});


test("backwardness of submitted relationships is preserved (MBS-7636)", function () {
    sessionStorage.submittedRelationships = JSON.stringify([
        {
            id: 123,
            linkTypeID: 234,
            target: {
                entityType: "recording",
                gid: this.fakeGID1
            },
            direction: "backward"
        }
    ]);

    this.vm = this.RE.GenericEntityViewModel({
        sourceData: {
            entityType: "recording",
            gid: this.fakeGID0
        }
    });

    var entities = this.vm.source.relationships()[0].entities();
    equal(entities[0].gid, this.fakeGID1);
    equal(entities[1].gid, this.fakeGID0);
});


test("edit submission request is entered for release (MBS-7740, MBS-7746)", function () {
    setupReleaseRelationshipEditor(this);

    var recording = this.vm.source.mediums()[0].tracks[0].recording;

    var relationship1 = this.vm.getRelationship({
        target: {
            id: 102938,
            entityType: "release",
            gid: this.fakeGID2
        },
        linkTypeID: 69,
        attributes: []
    }, recording);

    var relationship2 = this.vm.getRelationship({
        target: {
            id: 839201,
            entityType: "work",
            gid: this.fakeGID1
        },
        linkTypeID: 278,
        attributes: []
    }, recording);

    relationship1.show();
    relationship2.show();

    this.vm.submissionDone = function (data, submitted) {
        deepEqual(submitted.edits, [
            {
                "edit_type": 90,
                "linkTypeID": 69,
                "entities": [
                    {
                        "entityType": "recording",
                        "gid": "87ec065e-f139-41b9-b3b9-f746addf5b1e",
                        "name": "Love Me Do"
                    },
                    {
                        "entityType": "release",
                        "gid": "c4804cb2-bf33-4394-bb5f-3fac972fa7a5",
                        "name": ""
                    }
                ],
                "attributes": [],
                "beginDate": null,
                "endDate": null,
                "ended": false,
                "hash": "c0362ff126851edb86c3581bc7e1596624ed0ea3"
            },
            {
                "edit_type": 90,
                "linkTypeID": 278,
                "entities": [
                    {
                        "entityType": "recording",
                        "gid": "87ec065e-f139-41b9-b3b9-f746addf5b1e",
                        "name": "Love Me Do"
                    },
                    {
                        "entityType": "work",
                        "gid": "acb75d59-b0dc-4105-bad6-81ac8c66da4d",
                        "name": ""
                    }
                ],
                "attributes": [],
                "beginDate": null,
                "endDate": null,
                "ended": false,
                "hash": "52e6994e72cd0d0599c2793d65da793af9487686"
            }
        ]);
    };

    this.vm.submit(null, $.Event());
});


test("hidden input fields are generated for non-release forms", function () {
    setupGenericRelationshipEditor(this, {
        sourceData: {
            entityType: "artist",
            name: "The Beatles",
            gid: "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d",
            relationships: [
                {
                    linkTypeID: 103,
                    direction: "backward",
                    ended: true,
                    target: {
                        entityType: "artist",
                        sortName: "McCartney, Paul",
                        comment: "",
                        name: "Paul McCartney",
                        id: 2122,
                        gid: "ba550d0e-adac-4864-b88b-407cab5e76af"
                    },
                    id: 131689,
                    attributes: [277, 4],
                    verbosePhrase: "is/was a member of"
                },
                {
                    linkTypeID: 103,
                    direction: "backward",
                    ended: true,
                    target: {
                        entityType: "artist",
                        sortName: "Sutcliffe, Stuart",
                        comment: "",
                        name: "Stuart Sutcliffe",
                        id: 321117,
                        gid: "49a51491-650e-44b3-8085-2f07ac2986dd"
                    },
                    id: 35568,
                    attributes: [277],
                    verbosePhrase: "is/was a member of"
                }
            ]
        },
        formName: "edit-artist"
    });

    var newRelationship = this.vm.getRelationship({
        linkTypeID: 103,
        direction: "backward",
        ended: true,
        target: {
            entityType: "artist",
            sortName: "Harrison, George",
            comment: "The Beatles",
            name: "George Harrison",
            id: 2863,
            gid: "42a8f507-8412-4611-854f-926571049fa0"
        },
        attributes: [229, 4],
        verbosePhrase: "is/was a member of"
    }, this.vm.source);

    newRelationship.show();

    var relationships = this.vm.source.relationships();
    relationships[0].period.beginDate.month(7);
    relationships[0].period.beginDate.year(1957);
    relationships[0].period.endDate.day(10);
    relationships[0].period.endDate.month(4);
    relationships[0].period.endDate.year(1970);
    relationships[0].attributes([]);
    relationships[1].removed(true);

    this.$form.submit();

    deepEqual(this.formData(), {
        "edit-artist.rel.0.relationship_id": "131689",
        "edit-artist.rel.0.target": "ba550d0e-adac-4864-b88b-407cab5e76af",
        "edit-artist.rel.0.period.begin_date.year": "1957",
        "edit-artist.rel.0.period.begin_date.month": "7",
        "edit-artist.rel.0.period.begin_date.day": "",
        "edit-artist.rel.0.period.end_date.year": "1970",
        "edit-artist.rel.0.period.end_date.month": "4",
        "edit-artist.rel.0.period.end_date.day": "10",
        "edit-artist.rel.0.period.ended": "1",
        "edit-artist.rel.0.backward": "1",
        "edit-artist.rel.0.link_type_id": "103",
        "edit-artist.rel.1.relationship_id": "35568",
        "edit-artist.rel.1.removed": "1",
        "edit-artist.rel.1.target": "49a51491-650e-44b3-8085-2f07ac2986dd",
        "edit-artist.rel.1.attributes.0": "277",
        "edit-artist.rel.1.period.ended": "1",
        "edit-artist.rel.1.backward": "1",
        "edit-artist.rel.1.link_type_id": "103",
        "edit-artist.rel.2.target": "42a8f507-8412-4611-854f-926571049fa0",
        "edit-artist.rel.2.attributes.0": "4",
        "edit-artist.rel.2.attributes.1": "229",
        "edit-artist.rel.2.period.ended": "1",
        "edit-artist.rel.2.backward": "1",
        "edit-artist.rel.2.link_type_id": "103"
    });
});


test("link orders are submitted for new, orderable relationships (MBS-7775)", function () {
    setupGenericRelationshipEditor(this, {
        sourceData: {
            entityType: "series",
            name: "「神のみぞ知るセカイ」キャラクターCD",
            gid: "0fda0386-cd02-422a-9baa-54dc91ea4771",
            relationships: []
        },
        formName: "edit-series"
    });

    var newRelationship1 = this.vm.getRelationship({
        linkTypeID: 742,
        direction: "backward",
        target: {
            entityType: "release_group",
            name: "「神のみぞ知るセカイ」キャラクターCD.0",
            gid: "0a95623a-08d1-41a6-9f0c-409e40ce4476"
        },
        linkOrder: 1,
        attributes: [788],
        attributeTextValues: { 788: "20101110" },
        verbosePhrase: "is a part of"
    }, this.vm.source);

    var newRelationship2 = this.vm.getRelationship({
        linkTypeID: 742,
        direction: "backward",
        target: {
            entityType: "release_group",
            name: "「神のみぞ知るセカイ」キャラクターCD.1",
            gid: "4550586c-c886-483d-922b-4e810f7c85fc"
        },
        linkOrder: 2,
        attributes: [788],
        attributeTextValues: { 788: "1" },
        verbosePhrase: "is a part of"
    }, this.vm.source);

    var newRelationship3 = this.vm.getRelationship({
        linkTypeID: 742,
        direction: "backward",
        target: {
            entityType: "release_group",
            name: "「神のみぞ知るセカイ」キャラクターCD.2",
            gid: "3c8460ee-25ec-45b2-8990-0c1e78fe2ead"
        },
        linkOrder: 3,
        attributes: [788],
        attributeTextValues: { 788: "2" },
        verbosePhrase: "is a part of"
    }, this.vm.source);

    newRelationship1.show();
    newRelationship2.show();
    newRelationship3.show();

    this.$form.submit();

    deepEqual(this.formData(), {
        "edit-series.rel.0.attribute_text_values.0.attribute": "788",
        "edit-series.rel.0.attribute_text_values.0.text_value": "20101110",
        "edit-series.rel.0.attributes.0": "788",
        "edit-series.rel.0.backward": "1",
        "edit-series.rel.0.link_order": "1",
        "edit-series.rel.0.link_type_id": "742",
        "edit-series.rel.0.target": "0a95623a-08d1-41a6-9f0c-409e40ce4476",
        "edit-series.rel.1.attribute_text_values.0.attribute": "788",
        "edit-series.rel.1.attribute_text_values.0.text_value": "1",
        "edit-series.rel.1.attributes.0": "788",
        "edit-series.rel.1.backward": "1",
        "edit-series.rel.1.link_order": "2",
        "edit-series.rel.1.link_type_id": "742",
        "edit-series.rel.1.target": "4550586c-c886-483d-922b-4e810f7c85fc",
        "edit-series.rel.2.attribute_text_values.0.attribute": "788",
        "edit-series.rel.2.attribute_text_values.0.text_value": "2",
        "edit-series.rel.2.attributes.0": "788",
        "edit-series.rel.2.backward": "1",
        "edit-series.rel.2.link_order": "3",
        "edit-series.rel.2.link_type_id": "742",
        "edit-series.rel.2.target": "3c8460ee-25ec-45b2-8990-0c1e78fe2ead"
    });
});


test("relationships for entities not editable under the viewModel are ignored (MBS-7782)", function () {
    setupGenericRelationshipEditor(this, {
        sourceData: {
            entityType: "series",
            name: "「神のみぞ知るセカイ」キャラクターCD",
            gid: "0fda0386-cd02-422a-9baa-54dc91ea4771",
            relationships: []
        },
        formName: "edit-series"
    });

    var artist = MB.entity({
        entityType: "artist",
        name: "Foo",
        gid: this.fakeGID0
    });

    var newRelationship = this.vm.getRelationship({
        linkTypeID: 65,
        target: {
            entityType: "release_group",
            name: "「神のみぞ知るセカイ」キャラクターCD.0",
            gid: "0a95623a-08d1-41a6-9f0c-409e40ce4476"
        }
    }, artist);

    equal(newRelationship, null);
    equal(artist.relationships().length, 0);
});
