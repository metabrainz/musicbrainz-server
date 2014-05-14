var typeInfo = {
    "recording-release": [
        {
            attributes: { 1: { min: 0, max: 1 }, 14: { min: 0, max: null } },
            reversePhrase: "{additional:additionally} {instrument} sampled by",
            id: 69,
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
                            phrase: "{additional} {guest} {solo} {vocal:%|vocals}",
                            description: 1,
                            type0: "artist",
                            type1: "recording",
                            cardinality0: 1,
                            cardinality1: 0
                        }
                    ],
                    id: 156,
                    phrase: "{additional:additionally} {guest} {solo} performed",
                    description: 1,
                    type0: "artist",
                    type1: "recording",
                    cardinality0: 1,
                    cardinality1: 0
                }
            ],
            id: 122,
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
                    phrase: "produced {instrument} material that was {additional:additionally} sampled in",
                    description: 1,
                    type0: "artist",
                    type1: "recording",
                    cardinality0: 1,
                    cardinality1: 0
                }
            ],
            id: 157,
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
                    phrase: "{additional:additionally} {assistant} {associate} {co:co-}{executive:executive }produced",
                    description: 1,
                    type0: "artist",
                    type1: "recording",
                    cardinality0: 1,
                    cardinality1: 0
                }
            ],
            id: 160,
            phrase: "production",
            type0: "artist",
            type1: "recording",
            cardinality0: 1,
            cardinality1: 0
        }
    ],
    "recording-work": [
        {
            reversePhrase: "covers or other versions",
            children: [
                {
                    attributes: { 567: { min: 0, max: 1 }, 578: { min: 0, max: 1 }, 579: { min: 0, max: 1 }, 580: { min: 0, max: 1 } },
                    reversePhrase: "{partial} {live} {instrumental} {cover} recordings",
                    id: 278,
                    phrase: "{partial} {live} {instrumental} {cover} recording of",
                    description: 1,
                    type0: "recording",
                    type1: "work",
                    cardinality0: 0,
                    cardinality1: 1
                }
            ],
            id: 245,
            phrase: "covers or other versions",
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
                    phrase: "{additional:additionally} wrote",
                    description: 1,
                    type0: "artist",
                    type1: "work",
                    cardinality0: 1,
                    cardinality1: 0
                }
            ],
            id: 170,
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
                    phrase: "{additional} samples",
                    reversePhrase: "{additional:additionally} sampled by",
                    type0: "recording",
                    type1: "recording",
                    cardinality0: 0,
                    cardinality1: 0
                }
            ],
            id: 234,
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
        root_id: 579
    },
    cover: {
        name: "cover",
        l_name: "cover",
        id: 567,
        root_id: 567
    },
    executive: {
        name: "executive",
        l_name: "executive",
        id: 425,
        root_id: 425
    },
    co: {
        name: "co",
        l_name: "co",
        id: 424,
        root_id: 424
    },
    solo: {
        name: "solo",
        l_name: "solo",
        id: 596,
        root_id: 596
    },
    instrumental: {
        name: "instrumental",
        l_name: "instrumental",
        id: 580,
        root_id: 580
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
                                        root_id: 14
                                    },
                                    {
                                        name: "bass guitar",
                                        l_name: "bass guitar",
                                        id: 277,
                                        root_id: 14
                                    }
                                ],
                                id: 75,
                                root_id: 14
                            },
                            {
                                name: "lyre",
                                l_name: "lyre",
                                id: 109,
                                root_id: 14
                            },
                            {
                                name: "zither",
                                l_name: "zither",
                                id: 123,
                                root_id: 14
                            }
                        ],
                        id: 302,
                        root_id: 14
                    }
                ],
                id: 69,
                root_id: 14
            }
        ],
        id: 14,
        root_id: 14
    },
    vocal: {
        l_name: "vocal",
        name: "vocal",
        id: 3,
        root_id: 3,
        children: [
            {
                l_name: "lead vocals",
                name: "lead vocals",
                id: 4,
                root_id: 3
            }
        ]
    },
    associate: {
        name: "associate",
        l_name: "associate",
        id: 527,
        root_id: 527
    },
    assistant: {
        name: "assistant",
        l_name: "assistant",
        id: 526,
        root_id: 526
    },
    additional: {
        name: "additional",
        l_name: "additional",
        id: 1,
        root_id: 1
    },
    live: {
        name: "live",
        l_name: "live",
        id: 578,
        root_id: 578
    },
    guest: {
        name: "guest",
        l_name: "guest",
        id: 194,
        root_id: 194
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


module("relationship editor", {

    setup: function () {
        $("#qunit-fixture")
            .append('<div id="content"></div><div id="dialog"></div>');

        this.fakeGID0 = "a0ba91b0-c564-4eec-be2e-9ff071a47b59";
        this.fakeGID1 = "acb75d59-b0dc-4105-bad6-81ac8c66da4d";

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
            expected: "contains additional strings, guitars, lyre and plucked string instruments samples by"
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

        equal(
            relationship.phraseAndExtraAttributes(source)[0],
            test.expected,
            [test.linkTypeID, JSON.stringify(test.attributes)].join(", ")
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
    relationship.attributes([229]);
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

    relationship.entities([newTarget, source]);
    relationship.attributes([229]);
    relationship.period.beginDate.year(1999);
    relationship.period.endDate.year(2000);

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
