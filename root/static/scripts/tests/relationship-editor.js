var typeInfo = {
    "recording-release": [
        {
            attributes: { 1: { min: 0, max: 1 }, 14: { min: 0, max: null } },
            reversePhrase: "{additional:additionally} {instrument} sampled by",
            id: 69,
            gid: "967746f9-9d79-456c-9d1e-50116f0b27fc",
            phrase: "{additional} {instrument} samples from",
            description: 1,
            type0: "recording",
            type1: "release",
            cardinality0: 0,
            cardinality1: 1
        }
    ],
    "artist-recording": [
        {
            reversePhrase: "performance",
            children: [
                {
                    attributes: { 1: { min: 0, max: 1 }, 194: { min: 0, max: 1 }, 596: { min: 0, max: 1 } },
                    reversePhrase: "{additional} {guest} {solo} performer",
                    children: [
                        {
                            attributes: { 1: { min: 0, max: 1 }, 14: [1, null], 194: { min: 0, max: 1 }, 596: { min: 0, max: 1 } },
                            reversePhrase: "{additional} {guest} {solo} {instrument}",
                            id: 148,
                            gid: "59054b12-01ac-43ee-a618-285fd397e461",
                            phrase: "{additional} {guest} {solo} {instrument}",
                            description: 1,
                            type0: "artist",
                            type1: "recording",
                            cardinality0: 1,
                            cardinality1: 0
                        },
                        {
                            attributes: { 1: { min: 0, max: 1 }, 3: { min: 0, max: null }, 194: { min: 0, max: 1 }, 596: { min: 0, max: 1 } },
                            reversePhrase: "{additional} {guest} {solo} {vocal:%|vocals}",
                            id: 149,
                            gid: "0fdbe3c6-7700-4a31-ae54-b53f06ae1cfa",
                            phrase: "{additional} {guest} {solo} {vocal:%|vocals}",
                            description: 1,
                            type0: "artist",
                            type1: "recording",
                            cardinality0: 1,
                            cardinality1: 0
                        }
                    ],
                    id: 156,
                    gid: "628a9658-f54c-4142-b0c0-95f031b544da",
                    phrase: "{additional:additionally} {guest} {solo} performed",
                    description: 1,
                    type0: "artist",
                    type1: "recording",
                    cardinality0: 1,
                    cardinality1: 0
                }
            ],
            id: 122,
            gid: "f8673e29-02a5-47b7-af61-dd4519328dd0",
            phrase: "performance",
            type0: "artist",
            type1: "recording",
            cardinality0: 1,
            cardinality1: 0
        },
        {
            reversePhrase: "remixes",
            children: [
                {
                    attributes: { 1: { min: 0, max: 1 }, 14: { min: 0, max: null } },
                    reversePhrase: "contains {additional} {instrument} samples by",
                    id: 154,
                    gid: "83f72956-2007-4bca-8a97-0ae539cca99d",
                    phrase: "produced {instrument} material that was {additional:additionally} sampled in",
                    description: 1,
                    type0: "artist",
                    type1: "recording",
                    cardinality0: 1,
                    cardinality1: 0
                }
            ],
            id: 157,
            gid: "91109adb-a5a3-47b1-99bf-06f88130e875",
            phrase: "remixes",
            type0: "artist",
            type1: "recording",
            cardinality0: 1,
            cardinality1: 0
        },
        {
            reversePhrase: "production",
            children: [
                {
                    attributes: { 1: { min: 0, max: 1 }, 424: { min: 0, max: 1 }, 425: { min: 0, max: 1 }, 526: { min: 0, max: 1 }, 527: { min: 0, max: 1 } },
                    reversePhrase: "{additional} {assistant} {associate} {co:co-}{executive:executive }producer",
                    id: 141,
                    gid: "5c0ceac3-feb4-41f0-868d-dc06f6e27fc0",
                    phrase: "{additional:additionally} {assistant} {associate} {co:co-}{executive:executive }produced",
                    description: 1,
                    type0: "artist",
                    type1: "recording",
                    cardinality0: 1,
                    cardinality1: 0
                }
            ],
            id: 160,
            gid: "b367fae0-c4b0-48b9-a40c-f3ae4c02cffc",
            phrase: "production",
            type0: "artist",
            type1: "recording",
            cardinality0: 1,
            cardinality1: 0
        }
    ],
    "recording-work": [
        {
            attributes: { 567: { min: 0, max: 1 }, 578: { min: 0, max: 1 }, 579: { min: 0, max: 1 }, 580: { min: 0, max: 1 } },
            reversePhrase: "{partial} {live} {instrumental} {cover} recordings",
            id: 278,
            gid: "a3005666-a872-32c3-ad06-98af558e99b0",
            phrase: "{partial} {live} {instrumental} {cover} recording of",
            description: 1,
            type0: "recording",
            type1: "work",
            cardinality0: 0,
            cardinality1: 1
        }
    ],
    "artist-work": [
        {
            reversePhrase: "composition",
            children: [
                {
                    attributes: { 1: { min: 0, max: 1 } },
                    reversePhrase: "{additional} writer",
                    id: 167,
                    gid: "a255bca1-b157-4518-9108-7b147dc3fc68",
                    phrase: "{additional:additionally} wrote",
                    description: 1,
                    type0: "artist",
                    type1: "work",
                    cardinality0: 1,
                    cardinality1: 0
                }
            ],
            id: 170,
            gid: "cc9fcb45-7ab5-4629-bc5f-277f2592fa5a",
            phrase: "composition",
            type0: "artist",
            type1: "work",
            cardinality0: 1,
            cardinality1: 0
        }
    ],
    "recording-recording": [
        {
            children: [
                {
                    attributes: { 1: { min: 0, max: 1 } },
                    description: 1,
                    id: 231,
                    gid: "9efd9ce9-e702-448b-8e76-641515e8fe62",
                    phrase: "{additional} samples",
                    reversePhrase: "{additional:additionally} sampled by",
                    type0: "recording",
                    type1: "recording",
                    cardinality0: 0,
                    cardinality1: 0
                }
            ],
            id: 234,
            gid: "1baddd63-4539-4d49-ae43-600df9ef4647",
            phrase: "remixes",
            reversePhrase: "remixes",
            type0: "recording",
            type1: "recording",
            cardinality0: 0,
            cardinality1: 0
        }
    ]
};

var attrInfo = {
    partial: {
        name: "partial",
        l_name: "partial",
        id: 579,
        gid: "d2b63be6-91ec-426a-987a-30b47f8aae2d",
        rootID: 579
    },
    cover: {
        name: "cover",
        l_name: "cover",
        id: 567,
        gid: "1e8536bd-6eda-3822-8e78-1c0f4d3d2113",
        rootID: 567
    },
    executive: {
        name: "executive",
        l_name: "executive",
        id: 425,
        gid: "e0039285-6667-4f94-80d6-aa6520c6d359",
        rootID: 425
    },
    co: {
        name: "co",
        l_name: "co",
        id: 424,
        gid: "ac6f6b4c-a4ec-4483-a04e-9f425a914573",
        rootID: 424
    },
    solo: {
        name: "solo",
        l_name: "solo",
        id: 596,
        gid: "63daa0d3-9b63-4434-acff-4977c07808ca",
        rootID: 596
    },
    instrumental: {
        name: "instrumental",
        l_name: "instrumental",
        id: 580,
        gid: "c031ed4f-c9bb-4394-8cf5-e8ce4db512ae",
        rootID: 580
    },
    instrument: {
        name: "instrument",
        l_name: "instrument",
        children: [
            {
                name: "strings",
                l_name: "strings",
                children: [
                    {
                        name: "plucked string instruments",
                        l_name: "plucked string instruments",
                        children: [
                            {
                                name: "guitars",
                                l_name: "guitars",
                                children: [
                                    {
                                        name: "guitar",
                                        l_name: "guitar",
                                        id: 229,
                                        gid: "63021302-86cd-4aee-80df-2270d54f4978",
                                        rootID: 14
                                    },
                                    {
                                        name: "bass guitar",
                                        l_name: "bass guitar",
                                        id: 277,
                                        gid: "17f9f065-2312-4a24-8309-6f6dd63e2e33",
                                        rootID: 14
                                    }
                                ],
                                id: 75,
                                gid: "f68936f2-194c-4bcd-94a9-81e1dd947b8d",
                                rootID: 14
                            },
                            {
                                name: "lyre",
                                l_name: "lyre",
                                id: 109,
                                gid: "21bd4d63-a75a-4022-abd3-52ba7487c2de",
                                rootID: 14
                            },
                            {
                                name: "zither",
                                l_name: "zither",
                                id: 123,
                                gid: "c6a133d5-c1e0-47d6-bc30-30d102a78893",
                                rootID: 14
                            }
                        ],
                        id: 302,
                        gid: "b879ca9a-bf4b-41f8-b1a3-aa109f2e3bea",
                        rootID: 14
                    }
                ],
                id: 69,
                gid: "32eca297-dde6-45d0-9305-ae479947c2a8",
                rootID: 14
            }
        ],
        id: 14,
        gid: "0abd7f04-5e28-425b-956f-94789d9bcbe2",
        rootID: 14
    },
    vocal: {
        l_name: "vocal",
        name: "vocal",
        id: 3,
        gid: "d92884b7-ee0c-46d5-96f3-918196ba8c5b",
        rootID: 3,
        children: [
            {
                l_name: "lead vocals",
                name: "lead vocals",
                id: 4,
                gid: "8e2a3255-87c2-4809-a174-98cb3704f1a5",
                rootID: 3
            }
        ]
    },
    associate: {
        name: "associate",
        l_name: "associate",
        id: 527,
        gid: "8d23d2dd-13df-43ea-85a0-d7eb38dc32ec",
        rootID: 527
    },
    assistant: {
        name: "assistant",
        l_name: "assistant",
        id: 526,
        gid: "8c4196b1-7053-4b16-921a-f22b2898ed44",
        rootID: 526
    },
    additional: {
        name: "additional",
        l_name: "additional",
        id: 1,
        gid: "0a5341f8-3b1d-4f99-a0c6-26b7f4e42c7f",
        rootID: 1
    },
    live: {
        name: "live",
        l_name: "live",
        id: 578,
        gid: "70007db6-a8bc-46d7-a770-80e6a0bb551a",
        rootID: 578
    },
    guest: {
        name: "guest",
        l_name: "guest",
        id: 194,
        gid: "b3045913-62ac-433e-9211-ac683cdf6b5c",
        rootID: 194
    }
};

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


module("relationship editor", {

    setup: function () {
        $("#qunit-fixture")
            .append('<div id="content"></div><div id="dialog"></div>');

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

        this.RE.exportTypeInfo(typeInfo, attrInfo);

        this.vm = this.RE.ReleaseViewModel({
            sourceData: _.omit(testRelease, "mediums")
        });

        this.vm.releaseLoaded(testRelease);
    },

    teardown: function () {
        _.defer = this.__defer;

        this.vm = null;

        MB.entityCache = {};
    }
});


test("link phrase interpolation", function () {
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
            expected: "contains additional strings, guitars, lyre and plucked string instruments samples by"
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

        equal(
            relationship.phraseAndExtraAttributes()[entities.indexOf(source)],
            test.expected,
            [test.linkTypeID, JSON.stringify(_(test.attributes).pluck("type").pluck("id").value())].join(", ")
        );
    });

    relationship.remove();
});


test("merging duplicate relationships", function () {
    var source = MB.entity({ entityType: "recording", name: "foo" });
    var target = MB.entity({ entityType: "artist", name: "bar" });

    var relationship = this.vm.getRelationship({
        target: target,
        linkTypeID: 148,
        attributes: ids2attrs([123, 194, 277]),
        beginDate: { year: 2001 },
        endDate: null,
        ended: false
    }, source);

    var duplicateRelationship = this.vm.getRelationship({
        target: target,
        linkTypeID: 148,
        attributes: ids2attrs([123, 194, 277]),
        beginDate: null,
        endDate: { year: 2002 },
        ended: true
    }, source);

    relationship.show();
    duplicateRelationship.show();

    ok(source.mergeRelationship(duplicateRelationship), "relationships were merged");

    deepEqual(
        _(relationship.attributes()).pluck("type").pluck("id").value(),
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
    var source = this.vm.source.mediums()[0].tracks[0].recording;
    var target = MB.entity({ entityType: "artist", gid: this.fakeGID0 });

    var dialog = this.RE.UI.AddDialog({ source: source, target: target, viewModel: this.vm });
    var relationship = dialog.relationship();

    relationship.linkTypeID(148);
    relationship.setAttributes(ids2attrs([229]));
    dialog.accept();

    equal(source.relationships()[0], relationship, "relationship is added");

    relationship.remove();
});


test("BatchRelationshipDialog", function () {
    var target = MB.entity({ entityType: "artist", gid: this.fakeGID0 });
    var recordings = _.pluck(this.vm.source.mediums()[0].tracks, "recording");

    var dialog = this.RE.UI.BatchRelationshipDialog({
        sources: recordings,
        target: target,
        viewModel: this.vm
    });

    var relationship = dialog.relationship();
    var relationships, attributes;

    relationship.linkTypeID(154);
    relationship.setAttributes(ids2attrs([1]));

    dialog.accept();

    relationships = recordings[0].relationships();
    attributes = relationships[0].attributes();
    equal(relationships[0].entities()[0], target, "recording 0 has relationship with correct target");
    equal(attributes.length, 1, "recording 0 has 1 attribute");
    equal(attributes[0].type.id, 1, "recording 0 has relationship with additional attribute");

    relationships = recordings[1].relationships();
    attributes = relationships[0].attributes();
    equal(relationships[0].entities()[0], target, "recording 1 has relationship with correct target");
    equal(attributes.length, 1, "recording 1 has 1 attribute");
    equal(attributes[0].type.id, 1, "recording 1 has relationship with additional attribute");
});


test("BatchCreateWorksDialog", function () {
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
    dialogRelationship.setAttributes(ids2attrs([229]));
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
    this.vm = this.RE.GenericEntityViewModel({
        sourceData: {
            entityType: "recording",
            gid: this.fakeGID0,
            submittedRelationships: [
                {
                    id: 123,
                    linkTypeID: 234,
                    target: {
                        entityType: "recording",
                        gid: this.fakeGID1
                    },
                    direction: "backward"
                }
            ]
        }
    });

    var entities = this.vm.source.relationships()[0].entities();
    equal(entities[0].gid, this.fakeGID1);
    equal(entities[1].gid, this.fakeGID0);
});


test("edit submission request is entered for release (MBS-7740, MBS-7746)", function () {
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
                "linkOrder": 0,
                "beginDate": null,
                "endDate": null,
                "ended": false,
                "hash": "e201ef6c17e846c125a10aa7c32978b5a7e8374a"
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
                "linkOrder": 0,
                "beginDate": null,
                "endDate": null,
                "ended": false,
                "hash": "361082ca99b79b1bf70cbed7895f2fde7536d4f0"
            }
        ]);
    };

    this.vm.submit(null, $.Event());
});
