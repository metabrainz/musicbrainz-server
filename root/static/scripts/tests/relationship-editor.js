// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

var test = require('tape');

var fakeGID0 = "a0ba91b0-c564-4eec-be2e-9ff071a47b59";
var fakeGID1 = "acb75d59-b0dc-4105-bad6-81ac8c66da4d";
var fakeGID2 = "c4804cb2-bf33-4394-bb5f-3fac972fa7a5";

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

function id2attr(id) { return { type: MB.attrInfoByID[id] } }

function ids2attrs(ids) { return _.map(ids, id2attr) }

function setupReleaseRelationshipEditor() {
    var vm = MB.relationshipEditor.ReleaseViewModel({
        sourceData: _.omit(testRelease, "mediums")
    });

    vm.releaseLoaded(testRelease);
    return vm;
}

function setupGenericRelationshipEditor(options) {
    MB.initRelationshipEditors(options);
    return MB.sourceRelationshipEditor;
}

function formData() {
    var inputsArray = _.toArray($("input[type=hidden]"));
    return _.transform(inputsArray, function (result, input) { result[input.name] = input.value }, {});
};

function relationshipEditorTest(name, callback) {
    test(name, function (t) {
        var $fixture =
            $('<div>')
                .attr('id', 'relationship-editor')
                .append('<div id="content"></div><div id="dialog"></div></div>')
                .appendTo('body');

        // _.defer makes its target functions asynchronous. It is redefined
        // here to call its target right away, so that we don't have to deal
        // with writing async tests.
        var _defer = _.defer;

        _.defer = function (func) {
            func.apply(null, _.toArray(arguments).slice(1));
        }

        callback(t);

        _.defer = _defer;

        MB.entityCache = {};
        MB.sourceRelationshipEditor = null;
        MB.sourceExternalLinksEditor = null;
        MB.releaseRelationshipEditor = null;
        MB.sourceEntity = null;
        window.sessionStorage.removeItem('submittedRelationships');

        $fixture.remove();
    });
}

relationshipEditorTest("link phrase interpolation", function (t) {
    t.plan(6);

    var vm = setupReleaseRelationshipEditor();

    var source = MB.entity({ entityType: "recording" });
    var target = MB.entity({ entityType: "artist" });

    var relationship = vm.getRelationship({
        target: target,
        linkTypeID: 148
    }, source);

    var entities = relationship.entities();

    // link phrase construction

    var tests = [
        // test attribute interpolation
        {
            linkTypeID: 148,
            attributes: ids2attrs([123, 229, 277, 596]),
            expected: "solo zither, guitar and bass guitar"
        },
        {
            linkTypeID: 141,
            attributes: ids2attrs([424, 425]),
            expected: "co-executive producer"
        },
        {
            linkTypeID: 154,
            attributes: ids2attrs([1, 69, 75, 109, 302]),
            expected: "contains additional samples by",
            expectedExtra: "lyre, guitars, strings, plucked string instruments"
        },
        // MBS-6129
        {
            linkTypeID: 149,
            attributes: ids2attrs([4]),
            expected: "lead vocals"
        },
        {
            linkTypeID: 149,
            attributes: ids2attrs([]),
            expected: "vocals"
        }
    ];

    _.each(tests, function (test) {
        relationship.linkTypeID(test.linkTypeID);
        relationship.setAttributes(test.attributes);

        var result = relationship.phraseAndExtraAttributes();

        t.equal(
            result[entities.indexOf(source)],
            test.expected,
            [test.linkTypeID, JSON.stringify(_(test.attributes).pluck("type").pluck("id").value())].join(", ")
        );

        if (test.expectedExtra) {
            t.equal(result[2], test.expectedExtra);
        }
    });

    relationship.remove();
});

relationshipEditorTest("merging duplicate relationships", function (t) {
    t.plan(6);

    var vm = setupReleaseRelationshipEditor();

    var source = MB.entity({ entityType: "recording", name: "foo" });
    var target = MB.entity({ entityType: "artist", name: "bar" });

    var relationship = vm.getRelationship({
        target: target,
        linkTypeID: 148,
        attributes: ids2attrs([123, 194, 277]),
        beginDate: { year: 2001 },
        endDate: null,
        ended: false
    }, source);

    var duplicateRelationship = vm.getRelationship({
        target: target,
        linkTypeID: 148,
        attributes: ids2attrs([123, 194, 277]),
        beginDate: null,
        endDate: { year: 2002 },
        ended: true
    }, source);

    relationship.show();
    duplicateRelationship.show();

    t.ok(source.mergeRelationship(duplicateRelationship), "relationships were merged");

    t.deepEqual(
        _(relationship.attributes()).pluck("type").pluck("id").value().sort(),
        [123, 194, 277],
        "attributes are the same"
    );

    t.deepEqual(
        ko.toJS(relationship.period),
        {
            beginDate: { year: 2001, month: null, day: null },
            endDate: { year: 2002, month: null, day: null },
            ended: true
        },
        "date period is merged correctly"
    );

    t.equal(source.relationships.indexOf(duplicateRelationship), -1,
          "source does not have duplicate relationship");

    t.ok(duplicateRelationship.removed(), "`removed` is true for duplicate");

    var notDuplicateRelationship = vm.getRelationship({
        target: target,
        linkTypeID: 148,
        beginDate: { year: 2003 },
        endDate: { year: 2004 }
    }, source);

    notDuplicateRelationship.show();

    t.ok(!source.mergeRelationship(notDuplicateRelationship),
       "relationship with different date is not merged");

    relationship.remove();
    duplicateRelationship.remove();
    notDuplicateRelationship.remove();
});

relationshipEditorTest("dialog backwardness", function (t) {
    t.plan(8);

    var vm = setupReleaseRelationshipEditor();

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
        var options = _.assign({ viewModel: vm }, test.input);
        var dialog = MB.relationshipEditor.UI.AddDialog(options);

        t.equal(dialog.backward(), test.expected.backward)
        t.deepEqual(dialog.relationship().entities(), test.expected.entities);

        dialog.close();
    });
});

relationshipEditorTest("AddDialog", function (t) {
    t.plan(1);

    var vm = setupReleaseRelationshipEditor();

    var source = vm.source.mediums()[0].tracks[0].recording;
    var target = MB.entity({ entityType: "artist", gid: fakeGID0 });

    var dialog = MB.relationshipEditor.UI.AddDialog({ source: source, target: target, viewModel: vm });
    var relationship = dialog.relationship();

    relationship.linkTypeID(148);
    relationship.setAttributes(ids2attrs([229]));
    dialog.accept();

    t.equal(source.relationships()[0], relationship, "relationship is added");

    relationship.remove();
});

relationshipEditorTest("BatchRelationshipDialog", function (t) {
    t.plan(6);

    var vm = setupReleaseRelationshipEditor();

    var target = MB.entity({ entityType: "artist", gid: fakeGID0 });
    var recordings = _.pluck(vm.source.mediums()[0].tracks, "recording");

    var dialog = MB.relationshipEditor.UI.BatchRelationshipDialog({
        sources: recordings,
        target: target,
        viewModel: vm
    });

    var relationship = dialog.relationship();
    var relationships, attributes;

    relationship.linkTypeID(154);
    relationship.setAttributes(ids2attrs([1]));

    dialog.accept();

    relationships = recordings[0].relationships();
    attributes = relationships[0].attributes();
    t.equal(relationships[0].entities()[0], target, "recording 0 has relationship with correct target");
    t.equal(attributes.length, 1, "recording 0 has 1 attribute");
    t.equal(attributes[0].type.id, 1, "recording 0 has relationship with additional attribute");

    relationships = recordings[1].relationships();
    attributes = relationships[0].attributes();
    t.equal(relationships[0].entities()[0], target, "recording 1 has relationship with correct target");
    t.equal(attributes.length, 1, "recording 1 has 1 attribute");
    t.equal(attributes[0].type.id, 1, "recording 1 has relationship with additional attribute");
});

relationshipEditorTest("BatchCreateWorksDialog", function (t) {
    t.plan(2);

    var vm = setupReleaseRelationshipEditor();

    var recordings = _.pluck(vm.source.mediums()[0].tracks, "recording");

    var dialog = MB.relationshipEditor.UI.BatchCreateWorksDialog({
        sources: recordings, viewModel: vm
    });

    // Mock edit submission.
    var _MB_edit_create = MB.edit.create;

    MB.edit.create = function () {
        return $.Deferred().resolve({
            edits: [
                { entity: { name: "WorkFoo", gid: fakeGID0, entityType: "work" } },
                { entity: { name: "WorkBar", gid: fakeGID1, entityType: "work" } }
            ]
        });
    }

    dialog.accept();

    t.deepEqual(recordings[0].relationships()[0].entities(), [
        recordings[0], MB.entity({ gid: fakeGID0 }, "work")
    ]);

    t.deepEqual(recordings[1].relationships()[0].entities(), [
        recordings[1], MB.entity({ gid: fakeGID1 }, "work")
    ]);

    MB.edit.create = _MB_edit_create;
});

relationshipEditorTest("canceling an edit dialog reverts the changes", function (t) {
    t.plan(4);

    var vm = setupReleaseRelationshipEditor();
    var source = vm.source.mediums()[0].tracks[0].recording;
    var target = MB.entity({ entityType: "artist", name: "foo", gid: fakeGID0 });

    var relationship = vm.getRelationship({
        target: target,
        linkTypeID: 148,
        attributes: [],
    }, source);

    var dialog = MB.relationshipEditor.UI.EditDialog({
        relationship: relationship,
        source: source,
        viewModel: vm
    });

    var newTarget = MB.entity({ entityType: "artist", name: "bar", gid: fakeGID1 });
    var dialogRelationship = dialog.relationship();

    dialogRelationship.entities([newTarget, source]);
    dialogRelationship.setAttributes(ids2attrs([229]));
    dialogRelationship.period.beginDate.year(1999);
    dialogRelationship.period.endDate.year(2000);

    // cancel should revert the change
    dialog.close(true /* cancel */);

    t.deepEqual(relationship.entities(), [target, source], "entities changed back");
    t.deepEqual(relationship.attributes(), [], "attributes changed back");
    t.equal(relationship.period.beginDate.year(), null, "beginDate changed back");
    t.equal(relationship.period.endDate.year(), null, "endDate changed back");
});

relationshipEditorTest("MBS-5389: added recording-recording relationship appears under both recordings", function (t) {
    t.plan(2);

    var vm = setupReleaseRelationshipEditor();
    var tracks = vm.source.mediums()[0].tracks;

    var recording0 = tracks[0].recording;
    var recording1 = tracks[1].recording;

    var dialog = MB.relationshipEditor.UI.AddDialog({ source: recording1, target: recording0, viewModel: vm });

    var relationship = dialog.relationship();
    relationship.linkTypeID(231);

    dialog.accept();

    t.equal(recording0.relationships()[0], relationship, "relationship added to recording 0");
    t.equal(recording1.relationships()[0], relationship, "relationship added to recording 1");

    relationship.remove();
});

relationshipEditorTest("backwardness of submitted relationships is preserved (MBS-7636)", function (t) {
    t.plan(2);

    var source = {
            entityType: "recording",
            gid: fakeGID0
        },
        target = {
            entityType: "recording",
            gid: fakeGID1
        };

    window.sessionStorage.setItem('submittedRelationships', JSON.stringify([
        {
            id: 123,
            linkTypeID: 234,
            target: target,
            entities: [target, source],
            direction: "backward"
        }
    ]));

    // Pretend the form was posted.
    MB.formWasPosted = true;
    var vm = setupGenericRelationshipEditor({ sourceData: source });
    MB.formWasPosted = false;

    var entities = vm.source.relationships()[0].entities();
    t.equal(entities[0].gid, fakeGID1);
    t.equal(entities[1].gid, fakeGID0);
});

relationshipEditorTest("edit submission request is entered for release (MBS-7740, MBS-7746)", function (t) {
    t.plan(1);

    var vm = setupReleaseRelationshipEditor();
    var recording = vm.source.mediums()[0].tracks[0].recording;

    var relationship1 = vm.getRelationship({
        target: {
            id: 102938,
            entityType: "release",
            gid: fakeGID2
        },
        linkTypeID: 69,
        attributes: []
    }, recording);

    var relationship2 = vm.getRelationship({
        target: {
            id: 839201,
            entityType: "work",
            gid: fakeGID1
        },
        linkTypeID: 278,
        attributes: []
    }, recording);

    relationship1.show();
    relationship2.show();

    vm.submissionDone = function (data, submitted) {
        t.deepEqual(submitted.edits, [
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
                "entity0_credit" : "",
                "entity1_credit" : "",
                "attributes": [],
                "beginDate": {year: null, month: null, day: null},
                "endDate": {year: null, month: null, day: null},
                "ended": false,
                "hash": "043e1bbcf25fd9da9512f9c04c6a60fa935e6d71"
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
                "entity0_credit" : "",
                "entity1_credit" : "",
                "attributes": [],
                "beginDate": {year: null, month: null, day: null},
                "endDate": {year: null, month: null, day: null},
                "ended": false,
                "hash": "8859a32687f9e8e154745cc6ea6946f402f18329"
            }
        ]);
    };

    vm.submit(null, $.Event());
});

relationshipEditorTest("hidden input fields are generated for non-release forms", function (t) {
    t.plan(1);

    var vm = setupGenericRelationshipEditor({
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
                    attributes: ids2attrs([277, 4]),
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
                    attributes: ids2attrs([277]),
                    verbosePhrase: "is/was a member of"
                }
            ]
        }
    });

    var newRelationship = vm.getRelationship({
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
        attributes: ids2attrs([229, 4]),
        verbosePhrase: "is/was a member of"
    }, vm.source);

    newRelationship.show();

    var relationships = vm.source.relationships();
    relationships[0].period.beginDate.month(7);
    relationships[0].period.beginDate.year(1957);
    relationships[0].period.endDate.day(10);
    relationships[0].period.endDate.month(4);
    relationships[0].period.endDate.year(1970);
    relationships[0].attributes([]);
    relationships[1].removed(true);

    MB.relationshipEditor.prepareSubmission('edit-artist');

    t.deepEqual(formData(), {
        "edit-artist.rel.0.relationship_id": "131689",
        "edit-artist.rel.0.target": "ba550d0e-adac-4864-b88b-407cab5e76af",
        "edit-artist.rel.0.period.begin_date.year": "1957",
        "edit-artist.rel.0.period.begin_date.month": "7",
        "edit-artist.rel.0.period.begin_date.day": "",
        "edit-artist.rel.0.period.end_date.year": "1970",
        "edit-artist.rel.0.period.end_date.month": "4",
        "edit-artist.rel.0.period.end_date.day": "10",
        "edit-artist.rel.0.backward": "1",
        "edit-artist.rel.0.link_type_id": "103",
        "edit-artist.rel.0.attributes.0.removed": "1",
        "edit-artist.rel.0.attributes.0.type.gid": "17f9f065-2312-4a24-8309-6f6dd63e2e33",
        "edit-artist.rel.0.attributes.1.removed": "1",
        "edit-artist.rel.0.attributes.1.type.gid": "8e2a3255-87c2-4809-a174-98cb3704f1a5",
        "edit-artist.rel.1.relationship_id": "35568",
        "edit-artist.rel.1.removed": "1",
        "edit-artist.rel.1.target": "49a51491-650e-44b3-8085-2f07ac2986dd",
        "edit-artist.rel.1.backward": "1",
        "edit-artist.rel.1.link_type_id": "103",
        "edit-artist.rel.2.target": "42a8f507-8412-4611-854f-926571049fa0",
        "edit-artist.rel.2.attributes.0.type.gid": "63021302-86cd-4aee-80df-2270d54f4978",
        "edit-artist.rel.2.attributes.1.type.gid": "8e2a3255-87c2-4809-a174-98cb3704f1a5",
        "edit-artist.rel.2.period.begin_date.day" : "",
        "edit-artist.rel.2.period.begin_date.month" : "",
        "edit-artist.rel.2.period.begin_date.year" : "",
        "edit-artist.rel.2.period.end_date.day" : "",
        "edit-artist.rel.2.period.end_date.month" : "",
        "edit-artist.rel.2.period.end_date.year" : "",
        "edit-artist.rel.2.period.ended": "1",
        "edit-artist.rel.2.backward": "1",
        "edit-artist.rel.2.entity0_credit": "",
        "edit-artist.rel.2.entity1_credit": "",
        "edit-artist.rel.2.link_type_id": "103"
    });
});

relationshipEditorTest("link orders are submitted for new, orderable relationships (MBS-7775)", function (t) {
    t.plan(1);

    var vm = setupGenericRelationshipEditor({
        sourceData: {
            entityType: "series",
            name: "「神のみぞ知るセカイ」キャラクターCD",
            gid: "0fda0386-cd02-422a-9baa-54dc91ea4771",
            relationships: []
        }
    });

    var newRelationship1 = vm.getRelationship({
        linkTypeID: 742,
        direction: "backward",
        target: {
            entityType: "release_group",
            name: "「神のみぞ知るセカイ」キャラクターCD.0",
            gid: "0a95623a-08d1-41a6-9f0c-409e40ce4476"
        },
        linkOrder: 1,
        attributes: ids2attrs([788]),
        verbosePhrase: "is a part of"
    }, vm.source);

    var newRelationship2 = vm.getRelationship({
        linkTypeID: 742,
        direction: "backward",
        target: {
            entityType: "release_group",
            name: "「神のみぞ知るセカイ」キャラクターCD.1",
            gid: "4550586c-c886-483d-922b-4e810f7c85fc"
        },
        linkOrder: 2,
        attributes: ids2attrs([788]),
        verbosePhrase: "is a part of"
    }, vm.source);

    var newRelationship3 = vm.getRelationship({
        linkTypeID: 742,
        direction: "backward",
        target: {
            entityType: "release_group",
            name: "「神のみぞ知るセカイ」キャラクターCD.2",
            gid: "3c8460ee-25ec-45b2-8990-0c1e78fe2ead"
        },
        linkOrder: 3,
        attributes: ids2attrs([788]),
        verbosePhrase: "is a part of"
    }, vm.source);

    newRelationship1.attributes()[0].textValue("20101110");
    newRelationship2.attributes()[0].textValue("1");
    newRelationship3.attributes()[0].textValue("2");

    newRelationship1.show();
    newRelationship2.show();
    newRelationship3.show();

    MB.relationshipEditor.prepareSubmission('edit-series');

    t.deepEqual(formData(), {
        "edit-series.rel.0.attributes.0.type.gid": "a59c5830-5ec7-38fe-9a21-c7ea54f6650a",
        "edit-series.rel.0.attributes.0.text_value": "20101110",
        "edit-series.rel.0.backward": "1",
        "edit-series.rel.0.link_order": "1",
        "edit-series.rel.0.link_type_id": "742",
        "edit-series.rel.0.target": "0a95623a-08d1-41a6-9f0c-409e40ce4476",
        "edit-series.rel.0.entity0_credit": "",
        "edit-series.rel.0.entity1_credit": "",
        "edit-series.rel.1.attributes.0.type.gid": "a59c5830-5ec7-38fe-9a21-c7ea54f6650a",
        "edit-series.rel.1.attributes.0.text_value": "1",
        "edit-series.rel.1.backward": "1",
        "edit-series.rel.1.link_order": "2",
        "edit-series.rel.1.link_type_id": "742",
        "edit-series.rel.1.target": "4550586c-c886-483d-922b-4e810f7c85fc",
        "edit-series.rel.1.entity0_credit": "",
        "edit-series.rel.1.entity1_credit": "",
        "edit-series.rel.2.attributes.0.type.gid": "a59c5830-5ec7-38fe-9a21-c7ea54f6650a",
        "edit-series.rel.2.attributes.0.text_value": "2",
        "edit-series.rel.2.backward": "1",
        "edit-series.rel.2.link_order": "3",
        "edit-series.rel.2.link_type_id": "742",
        "edit-series.rel.2.target": "3c8460ee-25ec-45b2-8990-0c1e78fe2ead",
        "edit-series.rel.2.entity0_credit": "",
        "edit-series.rel.2.entity1_credit": "",
    });
});

relationshipEditorTest("relationships for entities not editable under the viewModel are ignored (MBS-7782)", function (t) {
    t.plan(2);

    var vm = setupGenericRelationshipEditor({
        sourceData: {
            entityType: "series",
            name: "「神のみぞ知るセカイ」キャラクターCD",
            gid: "0fda0386-cd02-422a-9baa-54dc91ea4771",
            relationships: []
        }
    });

    var artist = MB.entity({
        entityType: "artist",
        name: "Foo",
        gid: fakeGID0
    });

    var newRelationship = vm.getRelationship({
        linkTypeID: 65,
        target: {
            entityType: "release_group",
            name: "「神のみぞ知るセカイ」キャラクターCD.0",
            gid: "0a95623a-08d1-41a6-9f0c-409e40ce4476"
        }
    }, artist);

    t.ok(!newRelationship);
    t.equal(artist.relationships().length, 0);
});

var loveMeDo = {
    entityType: "recording",
    name: "Love Me Do",
    gid: "1f518811-7cf9-4bdc-a656-0958e130f312",
    relationships: [
        {
            linkTypeID: 44,
            direction: "backward",
            target: {
                entityType: "artist",
                name: "Ringo Starr",
                gid: "300c4c73-33ac-4255-9d57-4e32627f5e13"
            },
            linkOrder: 0,
            attributes: ids2attrs([333]),
            verbosePhrase: "performed {additional} {guest} {solo} {instrument:%|instruments} on"
        }
    ]
};

relationshipEditorTest("attributes are cleared when the target type is changed (MBS-7875)", function (t) {
    t.plan(2);

    var vm = setupGenericRelationshipEditor({
        sourceData: _.cloneDeep(loveMeDo)
    });

    var relationship = vm.source.relationships()[0];
    t.equal(relationship.attributes().length, 1);

    var dialog = MB.relationshipEditor.UI.EditDialog({
        relationship: relationship,
        source: vm.source,
        viewModel: vm
    });

    dialog.targetType("work");

    relationship.entities([
        vm.source,
        MB.entity({
            gid: "3d2be76e-8193-307e-bca5-71f9c734c0f0",
            name: "Love Me Do"
        }, "work")
    ]);

    dialog.accept();
    relationship = dialog.relationship();
    t.equal(relationship.attributes().length, 0, "invalid attributes removed");
});

relationshipEditorTest("invalid attributes can’t be set on a relationship (MBS-7983)", function (t) {
    t.plan(2);

    var vm = setupGenericRelationshipEditor({
        sourceData: loveMeDo
    });

    var relationship = vm.source.relationships()[0];
    t.equal(relationship.attributes().length, 1);

    relationship.attributes.push(
        new MB.relationshipEditor.fields.LinkAttribute(
            { type: { gid: "ed11fcb1-5a18-4e1d-b12c-633ed19c8ee1" } }
        )
    );

    t.equal(relationship.attributes().length, 1, "invalid attribute not added");
});

relationshipEditorTest('relationships with different link orders are not duplicates of each other', function (t) {
    t.plan(1);

    var sourceData = _.cloneDeep(loveMeDo);

    var vm = setupGenericRelationshipEditor({
        sourceData: sourceData
    });

    var relationship = vm.source.relationships()[0];

    var newRelationship = vm.getRelationship(
        _.assign(_.clone(sourceData.relationships[0]), { linkOrder: 1 }),
        vm.source
    );

    t.ok(!newRelationship.isDuplicate(relationship));
});

relationshipEditorTest("empty dates are submitted as a hash, not as undef (MBS-8443)", function (t) {
    t.plan(1);

    var beethoven = {
        entityType: "artist",
        id: 1021,
        gid: "1f9df192-a621-4f54-8850-2c5373b7eac9",
        name: "Ludwig van Beethoven",
        sortName: "Beethoven, Ludwig van",
        comment: ""
    };

    var compositionData = {
        id: 666,
        linkTypeID: 168,
        direction: "backward",
        target: beethoven,
        linkOrder: 0,
        attributes: [],
        beginDate: {year: 1801},
        verbosePhrase: "{additional} composer",
    };

    var vm = MB.relationshipEditor.ReleaseViewModel({
        sourceData: {
            entityType: "release",
            name: "3 Great Piano Sonatas (Wilhelm Backhaus)",
            gid: "b01c805e-0d25-45ad-9ddb-785658fe56ce",
            relationships: [compositionData],
            artistCredit: [{artist: beethoven, joinPhrase: ""}],
            mediums: [],
            releaseGroup: {
                entityType: "release_group",
                id: 188961,
                gid: "d0dd466b-3385-356b-bdf0-856737c6baf7",
                name: "3 Great Piano Sonatas",
                artistCredit: [{name: "Beethoven", joinPhrase: "; ", artist: beethoven}],
            }
        }
    });

    var relationship = vm.getRelationship(compositionData, vm.source);
    relationship.period.beginDate.year(null);

    var editData = MB.edit.relationshipEdit(relationship.editData(), relationship.original, relationship);
    t.deepEqual(editData.beginDate, {year: null, month: null, day: null});
});

relationshipEditorTest("empty date period fields are outputted when cleared", function (t) {
    t.plan(1);

    var relData = {
        id: 1,
        linkTypeID: 103,
        target: {
            entityType: "artist",
            name: "Ringo Starr",
            gid: "300c4c73-33ac-4255-9d57-4e32627f5e13"
        },
        beginDate: {year: 2006},
        ended: true
    };

    var vm = setupGenericRelationshipEditor({
        sourceData: {
            entityType: "artist",
            name: "The Beatles",
            gid: "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d",
            relationships: [relData]
        }
    });

    var relationship = vm.getRelationship(relData, vm.source);
    relationship.period.beginDate.year(null);
    relationship.period.ended(false);

    MB.relationshipEditor.prepareSubmission('edit-artist');

    t.deepEqual(formData(), {
        "edit-artist.rel.0.relationship_id": "1",
        "edit-artist.rel.0.target": "300c4c73-33ac-4255-9d57-4e32627f5e13",
        "edit-artist.rel.0.period.begin_date.year": "",
        "edit-artist.rel.0.period.begin_date.month": "",
        "edit-artist.rel.0.period.begin_date.day": "",
        "edit-artist.rel.0.period.ended" : "0",
        "edit-artist.rel.0.link_type_id": "103",
    });
});
