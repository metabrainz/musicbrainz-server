var typeInfo = {
    "recording-release": [
        {
            "attrs": {"1": [0, 1], "14": [0, null]},
            "reverse_phrase": "{additional:additionally} {instrument} sampled by",
            "id": 69,
            "phrase": "{additional} {instrument} samples from",
            "descr": 1
        }
    ],
    "artist-recording": [
        {
            "reverse_phrase": "performance",
            "children": [
                {
                    "attrs": {"1": [0, 1], "194": [0, 1], "596": [0, 1]},
                    "reverse_phrase": "{additional} {guest} {solo} performer",
                    "children": [
                        {
                            "attrs": {"1": [0, 1], "14": [1, null], "194": [0, 1], "596": [0, 1]},
                            "reverse_phrase": "{additional} {guest} {solo} {instrument}",
                            "id": 148,
                            "phrase": "{additional} {guest} {solo} {instrument}",
                            "descr": 1
                        },
                        {
                            "attrs": {"1": [0, 1], "3": [0, null], "194": [0, 1], "596": [0, 1]},
                            "reverse_phrase": "{additional} {guest} {solo} {vocal:%|vocals}",
                            "id": 149,
                            "phrase": "{additional} {guest} {solo} {vocal:%|vocals}",
                            "descr": 1
                        }
                    ],
                    "id": 156,
                    "phrase": "{additional:additionally} {guest} {solo} performed",
                    "descr": 1
                }
            ],
            "id": 122,
            "phrase": "performance"
        },
        {
            "reverse_phrase": "remixes",
            "children": [
                {
                    "attrs": {"1": [0, 1], "14": [0, null]},
                    "reverse_phrase": "contains {additional} {instrument} samples by",
                    "id": 154,
                    "phrase": "produced {instrument} material that was {additional:additionally} sampled in",
                    "descr": 1
                }
            ],
            "id": 157,
            "phrase": "remixes"
        },
        {
            "reverse_phrase": "production",
            "children": [
                {
                    "attrs": {"1": [0, 1], "424": [0, 1], "425": [0, 1], "526": [0, 1], "527": [0, 1]},
                    "reverse_phrase": "{additional} {assistant} {associate} {co:co-}{executive:executive }producer",
                    "id": 141,
                    "phrase": "{additional:additionally} {assistant} {associate} {co:co-}{executive:executive }produced",
                    "descr": 1
                }
            ],
            "id": 160,
            "phrase": "production"
        }
    ],
    "recording-work": [
        {
            "reverse_phrase": "covers or other versions",
            "children": [
                {
                    "attrs": {"567": [0, 1], "578": [0, 1], "579": [0, 1], "580": [0, 1]},
                    "reverse_phrase": "{partial} {live} {instrumental} {cover} recordings",
                    "id": 278,
                    "phrase": "{partial} {live} {instrumental} {cover} recording of",
                    "descr": 1
                }
            ],
            "id": 245,
            "phrase": "covers or other versions"
        }
    ],
    "artist-work": [
        {
            "reverse_phrase": "composition",
            "children": [
                {
                    "attrs": {"1": [0, 1]},
                    "reverse_phrase": "{additional} writer",
                    "id": 167,
                    "phrase": "{additional:additionally} wrote",
                    "descr": 1
                }
            ],
            "id": 170,
            "phrase": "composition"
        }
    ],
    "work-work": [
        {
            "reverse_phrase": "referred to in medleys",
            "id": 239,
            "phrase": "medley of",
            "descr": 1
        }
    ],
    "recording-recording": [
        {
            "children": [
                {
                    "attrs": {"1": [0, 1]},
                    "descr": 1,
                    "id": 231,
                    "phrase": "{additional} samples",
                    "reverse_phrase": "{additional:additionally} sampled by"
                }
            ],
            "id": 234,
            "phrase": "remixes",
            "reverse_phrase": "remixes"
        }
    ]
};

var attrInfo = {
    "partial": {
        "name": "partial",
        "l_name": "partial",
        "id": 579
    },
    "cover": {
        "name": "cover",
        "l_name": "cover",
        "id": 567
    },
    "executive": {
        "name": "executive",
        "l_name": "executive",
        "id": 425
    },
    "co": {
        "name": "co",
        "l_name": "co",
        "id": 424
    },
    "solo": {
        "name": "solo",
        "l_name": "solo",
        "id": 596
    },
    "instrumental": {
        "name": "instrumental",
        "l_name": "instrumental",
        "id": 580
    },
    "instrument": {
        "name": "instrument",
        "l_name": "instrument",
        "children": [
            {
                "name": "strings",
                "l_name": "strings",
                "children": [
                    {
                        "name": "plucked string instruments",
                        "l_name": "plucked string instruments",
                        "children": [
                            {
                                "name": "guitars",
                                "l_name": "guitars",
                                "children": [
                                    {
                                        "name": "guitar",
                                        "l_name": "guitar",
                                        "id": 229
                                    },
                                    {
                                        "name": "bass guitar",
                                        "l_name": "bass guitar",
                                        "id": 277
                                    }
                                ],
                                "id": 75
                            },
                            {
                                "name": "lyre",
                                "l_name": "lyre",
                                "id": 109
                            },
                            {
                                "name": "zither",
                                "l_name": "zither",
                                "id": 123
                            }
                        ],
                        "id": 302
                    }
                ],
                "id": 69
            }
        ],
        "id": 14
    },
    "vocal": {
        "l_name": "vocal",
        "name": "vocal",
        "id": 3,
        "children": [
            {
                "l_name": "lead vocals",
                "name": "lead vocals",
                "id": 4
            }
        ]
    },
    "associate": {
        "name": "associate",
        "l_name": "associate",
        "id": 527
    },
    "assistant": {
        "name": "assistant",
        "l_name": "assistant",
        "id": 526
    },
    "additional": {
        "name": "additional",
        "l_name": "additional",
        "id": 1
    },
    "live": {
        "name": "live",
        "l_name": "live",
        "id": 578
    },
    "guest": {
        "name": "guest",
        "l_name": "guest",
        "id": 194
    }
};

var testRelease = {
    "relationships": {},
    "name": "Love Me Do / I Saw Her Standing There",
    "artist_credit": [
        {
            "artist": {
                "sortname": "Beatles, The",
                "name": "The Beatles",
                "id": 303,
                "gid": "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d"
            },
            "join_phrase": ""
        }
    ],
    "id": 211431,
    "mediums": [
        {
            "tracks": [
                {
                    "length": 143000,
                    "number": "A",
                    "recording": {
                          "length": "2:23",
                          "relationships": {},
                          "name": "Love Me Do",
                          "id": 6393661,
                          "gid": "87ec065e-f139-41b9-b3b9-f746addf5b1e"
                    },
                    "position": 1,
                    "name": "Love Me Do",
                    "artist_credit": []
                },
                {
                    "length": 176000,
                    "number": "B",
                    "recording": {
                          "length": "2:56",
                          "relationships": {},
                          "name": "I Saw Her Standing There",
                          "id": 6393662,
                          "gid": "6de731d6-7a8f-43a0-8cb0-1dca5a40d04e"
                    },
                    "position": 2,
                    "name": "I Saw Her Standing There",
                    "artist_credit": []
                }
            ],
            "format": "Vinyl",
            "position": 1
        }
    ],
    "gid": "867cc694-0f35-4a65-acb4-bc873795701a",
    "release_group": {
        "artist": "The Beatles",
        "name": "Love Me Do",
        "id": 564256,
        "gid": "5db85281-934d-36e5-865c-1922ad82a948",
        "relationships": {}
    }
};

$.extend(MB.text = MB.text || {}, {
    Entity: {
        artist:        "Artist",
        label:         "Label",
        recording:     "Recording",
        release:       "Release",
        release_group: "Release group",
        url:           "URL",
        work:          "Work"
    },
    AttributeNotSupported: "This attribute is not supported for the selected relationship type.",
    AttributeTooMany: "This attribute can only be specified {max} times. You specified {n}.",
    AttributeRequired: "This attribute is required.",
    InvalidDate: "The date you've entered is not valid.",
    InvalidEndDate: "The end date cannot preceed the begin date.",
    InvalidValue: "The value you've entered is not valid.",
    RequiredField: "Required field.",
    EnumerationComma: ", ",
    EnumerationAnd: "{b} and {a}"
});


module("relationship editor", {

    setup: function () {
        $("#qunit-fixture")
            .append('<div id="content"></div><div id="dialog"></div>');

        this.fakeGID = [
            'a0ba91b0-c564-4eec-be2e-9ff071a47b59',
            'acb75d59-b0dc-4105-bad6-81ac8c66da4d',
            '3d3c3707-ef51-4852-995d-f9f14c68f5f0',
        ];

        // _.defer and RE.Util.callbackQueue both make their target functions
        // asynchronous. They are redefined here to call their targets right
        // away, so that we don't have to deal with  writing async tests.

        this.__defer = _.defer;

        _.defer = function (func) {
            func.apply(null, _.toArray(arguments).slice(1));
        }

        this.RE = MB.RelationshipEditor;

        this.__callbackQueue = this.RE.Util.callbackQueue;

        this.RE.Util.callbackQueue = function (targets, callback) {
            for (var i = 0; i < targets.length; i++)
                callback(targets[i]);
        };

        this.RE.Util.init(typeInfo, attrInfo);

        this.RE.UI.init(
            testRelease.gid, testRelease.release_group.gid, testRelease
        );
    },

    teardown: function () {
        _.defer = this.__defer;

        this.RE.Util.callbackQueue = this.__callbackQueue;

        this.RE.releaseViewModel.release({ relationships: [] });
        this.RE.releaseViewModel.releaseGroup({ relationships: [] });
        this.RE.releaseViewModel.media([]);

        MB.entity.clearCache();
    }
});


test("Util", function () {
    var self = this;
    var Util = this.RE.Util;

    var tests = [
        { date: "", expected: { year: null, month: null, day: null} },
        { date: "1999-01-02", expected: { year: "1999", month: "01", day: "02"} },
        { date: "1999-01", expected: { year: "1999", month: "01", day: null } },
        { date: "1999", expected: { year: "1999", month: null, day: null } }
    ];

    $.each(tests, function (i, test) {
        var result = Util.parseDate(test.date);
        deepEqual(result, test.expected, test.date);
    });

    tests = [
        { root: Util.attrInfo(424), value: undefined, expected: false },
        { root: Util.attrInfo(424), value: null, expected: false },
        { root: Util.attrInfo(424), value: 0, expected: false },
        { root: Util.attrInfo(424), value: 1, expected: true },
        { root: Util.attrInfo(14), value: undefined, expected: [] },
        { root: Util.attrInfo(14), value: null, expected: [] },
        { root: Util.attrInfo(14), value: 0, expected: [] },
        { root: Util.attrInfo(14), value: [0], expected: [] },
        { root: Util.attrInfo(14), value: ["foo", "bar", "baz"], expected: [] },
        { root: Util.attrInfo(14), value: 1, expected: [1] },
        { root: Util.attrInfo(14), value: [3, 3, 2, 2, 1, 1], expected: [1, 2, 3] },
        { root: Util.attrInfo(14), value: ["3", "3", "2", "2", "1", "1"], expected: [1, 2, 3] },
        { root: Util.attrInfo(14), value: ["1", 0, "9", 0, "5"], expected: [1, 5, 9] }
    ];

    $.each(tests, function (i, test) {
        var result = new self.RE.Fields.Attribute(test.root, test.value)();
        deepEqual(result, test.expected, String(test.value));
    });
});


test("Fields", function () {
    var field = new this.RE.Fields.Integer();

    var tests = [
        { input: undefined, expected: null },
        { input: false, expected: null },
        { input: "", expected: null },
        { input: 0, expected: 0 },
        { input: 12, expected: 12 },
        { input: "0", expected: 0 },
        { input: "012", expected: 12 }
    ];

    $.each(tests, function (i, test) {
        field(test.input);
        equal(field(), test.expected, String(test.input));
    });

    var relationship = this.RE.Relationship({
        action: "add",
        link_type: 278,
        entity: [
            MB.entity({ type: "recording" }),
            MB.entity({ type: "work" })
        ]
    });

    relationship.show();

    field = relationship.attrs;

    tests = [
        {
            input: {},
            expected: { partial: false, live: false, instrumental: false, cover: false }
        },
        {
            input: { foo: 1, bar: 2, partial: undefined },
            expected: { partial: false, live: false, instrumental: false, cover: false }
        },
        {
            input: { cover: 1, instrumental: 0, live: 1 },
            expected: { partial: false, live: true, instrumental: false, cover: true }
        }
    ];

    $.each(tests, function (i, test) {
        field(test.input);

        deepEqual(ko.toJS(field()), test.expected, JSON.stringify(test.input));
    });

    // test Fields.Entity

    field = relationship.entity[1];
    oldTarget = field.peek();
    newTarget = MB.entity({ type: "work" });

    equal(oldTarget.performanceCount, 1, oldTarget.id + " performanceCount");
    equal(newTarget.performanceCount, 0, newTarget.id + " performanceCount");

    field(newTarget);

    equal(oldTarget.performanceCount, 0, oldTarget.id + " performanceCount");
    equal(newTarget.performanceCount, 1, newTarget.id + " performanceCount");

    // test Fields.PartialDate

    field = new this.RE.Fields.PartialDate("");
    deepEqual(ko.toJS(field), { year: null, month: null, day: null }, '""');

    field("2012-08-21");
    deepEqual(ko.toJS(field), { year: 2012, month: 8, day: 21 }, "2012-08-21");

    field({ year: 2011, month: 7, day: 20 });
    deepEqual(ko.toJS(field), { year: 2011, month: 7, day: 20 }, "{year: 2012, month: 7, day: 20}");

    field(undefined);
    deepEqual(ko.toJS(field), { year: null, month: null, day: null }, "undefined");

    relationship.remove();
});


test("Relationship", function () {

    var source = MB.entity({ type: "recording" }),
        target = MB.entity({ type: "artist" });

    var relationship = this.RE.Relationship({
        entity: [target, source],
        action: "add",
        link_type: 148
    });

    relationship.show();

    // link phrase construction

    var tests = [
        // test attribute interpolation
        {
            linkType: 148,
            backward: false,
            attrs: { instrument: [123, 229, 277], solo: true },
            expected: "solo zither, guitar and bass guitar"
        },
        {
            linkType: 141,
            backward: true,
            attrs: { co: true, executive: true },
            expected: "co-executive producer"
        },
        {
            linkType: 154,
            backward: true,
            attrs: { instrument: [69, 75, 109, 302], additional: true },
            expected: "contains additional strings, guitars, lyre and plucked string instruments samples by"
        },
        // MBS-6129
        {
            linkType: 149,
            backward: true,
            attrs: { additional: false, vocal: [4] },
            expected: "lead vocals"
        },
        {
            linkType: 149,
            backward: true,
            attrs: { additional: false, vocal: [] },
            expected: "vocal"
        }
    ];

    $.each(tests, function (i, test) {
        relationship.link_type(test.linkType);
        relationship.attrs(test.attrs);

        var result = relationship.linkPhrase(test.backward
            ? relationship.entity[1]() : relationship.entity[0]());

        equal(result, test.expected, [test.linkType, JSON.stringify(test.attrs)].join(", "));
    });

    // test date rendering

    tests = [
        {
            begin_date: { year: 2001, month: 5, day: 13 },
            end_date: {},
            ended: true,
            expected: "2001-05-13 – ????"
        },
        {
            begin_date: { year: 2001, month: 5, day: 13 },
            end_date: {},
            ended: false,
            expected: "2001-05-13 – "
        },
        {
            begin_date: { year: 2001, month: 5, day: 13 },
            end_date: { year: 2001, month: 5, day: 13 },
            ended: true,
            expected: "2001-05-13"
        },
        {
            begin_date: {},
            end_date: { year: 2002, month: 8, day: 12 },
            ended: true,
            expected: " – 2002-08-12"
        },
        {
            begin_date: {},
            end_date: {},
            ended: true,
            expected: ""
        }
    ];

    $.each(tests, function (i, test) {
        var a = relationship.period.begin_date(),
            b = relationship.period.end_date();

        a.year(test.begin_date.year);
        a.month(test.begin_date.month);
        a.day(test.begin_date.day);

        b.year(test.end_date.year);
        b.month(test.end_date.month);
        b.day(test.end_date.day);

        relationship.period.ended(test.ended);
        var result = relationship.renderDate();

        equal(result, test.expected, [
            JSON.stringify(test.begin_date),
            JSON.stringify(test.end_date),
            JSON.stringify(test.ended)
        ].join(", "));
    });

    // test errors

    // the source/target have invalid gids to start with, so errorCount = 2
    equal(relationship.errorCount, 2, "relationship.errorCount");

    // ended must be boolean
    relationship.period.ended(null);
    equal(relationship.errorCount, 3, "relationship.errorCount");

    // date must exist
    relationship.period.begin_date("2001-01-32");
    equal(relationship.errorCount, 4, "relationship.errorCount");

    relationship.period.begin_date("2001-01-31");
    equal(relationship.errorCount, 3, "relationship.errorCount");

    // end date must be after begin date
    relationship.period.end_date("2000-01-31");
    equal(relationship.errorCount, 4, "relationship.errorCount");

    relationship.period.end_date("2002-01-31");
    equal(relationship.errorCount, 3, "relationship.errorCount");

    relationship.entity[0]().gid = this.fakeGID[0];
    relationship.entity[0].notifySubscribers(relationship.entity[0]());
    equal(relationship.errorCount, 2, "relationship.errorCount");

    relationship.entity[1]().gid = this.fakeGID[1];
    relationship.entity[1].notifySubscribers(relationship.entity[1]());
    equal(relationship.errorCount, 1, "relationship.errorCount");

    relationship.period.ended(true);
    equal(relationship.errorCount, 0, "relationship.errorCount");

    relationship.remove();
});


test("Entity", function () {

    var source = MB.entity({ type: "recording", name: "a recording" }),
        target = MB.entity({ type: "artist", name: "foo", sortname: "bar" });

    var relationship = this.RE.Relationship({
        entity: [target, source],
        action: "add",
        link_type: 148,
        attrs: { instrument: [123, 277], guest: true },
        period: { begin_date: "2001", end_date: "", ended: false }
    });

    var duplicateRelationship = this.RE.Relationship({
        entity: [target, source],
        action: "add",
        link_type: 148,
        attrs: { instrument: [123, 277], guest: true },
        period: { begin_date: "", end_date: "2002", ended: true }
    });

    relationship.show();
    duplicateRelationship.show();

    source.mergeRelationship(duplicateRelationship);

    deepEqual(
        ko.toJS(relationship.attrs),
        { instrument: [123, 277], additional: false, guest: true, solo: false },
        "attributes"
    );

    deepEqual(
        ko.toJS(relationship.period.begin_date),
        { year: 2001, month: null, day: null },
        "begin date"
    );

    deepEqual(
        ko.toJS(relationship.period.end_date),
        { year: 2002, month: null, day: null },
        "end date"
    );

    ok(relationship.period.ended(), "ended");

    equal(source.relationships.indexOf(duplicateRelationship), -1,
        "removed from source's relationships");

    ok(duplicateRelationship.removed, "relationship.removed");

    var notDuplicateRelationship = this.RE.Relationship({
        entity: [target, source],
        action: "add",
        link_type: 148,
        period: { begin_date: "2003", end_date: "2004" }
    });

    notDuplicateRelationship.show();

    ok(!source.mergeRelationship(notDuplicateRelationship),
        "different dates -> not merged");

    relationship.remove();
    duplicateRelationship.remove();
    notDuplicateRelationship.remove();
});


test("RelationshipEditor", function () {
    var vm = this.RE.releaseViewModel,
        media = vm.media();

    equal(media.length, 1, "medium count");

    var tracks = media[0].tracks;
    equal(tracks.length, 2, "track count");

    var track = tracks[0];
    equal(track.number, "A", "track number");
    equal(track.position, 1, "track position");
    equal(track.name, "Love Me Do", "track name");
    equal(track.recording.id, 6393661, "recording id");
    equal(track.recording.gid, "87ec065e-f139-41b9-b3b9-f746addf5b1e", "recording gid");
});


test("Dialog", function () {

    var UI = this.RE.UI,
        vm = this.RE.releaseViewModel,
        tracks = vm.media()[0].tracks,
        source = tracks[0].recording,
        target = MB.entity({ type: "artist", gid: this.fakeGID[0] });

    UI.Dialog.resize = function () {};

    var tests = [
        {
            entity: [
                MB.entity({ type: "recording" }),
                MB.entity({ type: "release" })
            ],
            backward: true,
            source: function () { return this.entity[1] },
            target: function () { return this.entity[0] }
        },
        {
            entity: [
                MB.entity({ type: "recording" }),
                MB.entity({ type: "release" })
            ],
            backward: false,
            source: function () { return this.entity[0] },
            target: function () { return this.entity[1] }
        }
    ];

    $.each(tests, function (i, test) {
        UI.AddDialog.show({entity: test.entity, source: test.source()});

        equal(UI.Dialog.backward(), test.backward,
            "entities should be backward: " + test.backward);

        equal(UI.Dialog.source, test.source(),
            "source should be entity[" + (test.backward ? "1" : "0") + "]");

        equal(UI.Dialog.target, test.target(),
            "target should be entity[" + (test.backward ? "0" : "1") + "]");

        UI.AddDialog.hide();
    });

    // AddDialog

    UI.AddDialog.show({entity: [target, source], source: source});
    var relationship = UI.Dialog.relationship();
    relationship.link_type(148);
    relationship.attrs({instrument: [229]});
    UI.AddDialog.accept();

    equal(source.relationships()[0], relationship, "AddDialog");

    // AddDialog - relationship between recordings on same release (MBS-5389)
    var recording0 = tracks[0].recording,
        recording1 = tracks[1].recording;

    UI.AddDialog.show({entity: [recording0, recording1], source: recording1});
    relationship = UI.Dialog.relationship();
    relationship.link_type(231);

    equal(UI.Dialog.sourceField(), relationship.entity[1], "AddDialog sourceField");
    equal(UI.Dialog.targetField(), relationship.entity[0], "AddDialog targetField");
    equal(UI.Dialog.source, recording1, "AddDialog source");
    equal(UI.Dialog.target, recording0, "AddDialog target");
    equal(UI.Dialog.backward(), true, "AddDialog: relationship is backward");

    UI.Dialog.changeDirection();

    equal(UI.Dialog.sourceField(), relationship.entity[0], "AddDialog sourceField");
    equal(UI.Dialog.targetField(), relationship.entity[1], "AddDialog targetField");
    // source and target should stay the same
    equal(UI.Dialog.source, recording1, "AddDialog source");
    equal(UI.Dialog.target, recording0, "AddDialog target");
    equal(UI.Dialog.backward(), false, "AddDialog: relationship is not backward");

    UI.AddDialog.accept();

    equal(recording0.relationships()[1], relationship, "relationship added to recording 0");
    equal(recording1.relationships()[0], relationship, "relationship added to recording 1");

    relationship.remove();

    equal(recording0.relationships()[1], undefined, "relationship removed from recording 0");
    equal(recording1.relationships()[0], undefined, "relationship removed from recording 1");

    // EditDialog

    relationship = source.relationships()[0];

    UI.EditDialog.show({relationship: relationship, source: source});
    var dialogAttrs = UI.Dialog.attrs();

    var solo = _.find(dialogAttrs, function (attr) {
        return attr.data.name == "solo";
    });

    solo.value(true);
    UI.EditDialog.accept();

    deepEqual(
        ko.toJS(relationship.attrs),
        {instrument: [229], additional: false, guest: false, solo: true},
        "EditDialog"
    );

    UI.EditDialog.show({relationship: relationship, source: source});

    var instrument = _.find(dialogAttrs, function (attr) {
        return attr.data.name == "instrument";
    });

    instrument.value([229, 277]);

    var newTarget = MB.entity({type: "artist"});
    UI.Dialog.targetField()(newTarget);

    // cancel should revert the change
    UI.EditDialog.hide();

    deepEqual(relationship.attrs().instrument(), [229], "attributes changed back");
    equal(relationship.entity[0](), target, "target changed back");

    // BatchRecordingRelationshipDialog

    UI.BatchRelationshipDialog.show(_.map(tracks, function (track) {
        return track.recording;
    }));

    newTarget = MB.entity({ type: "artist", gid: this.fakeGID[1] });

    relationship = UI.Dialog.relationship();

    UI.Dialog.targetField()(newTarget);
    relationship.link_type(154);
    relationship.attrs().additional(true);

    UI.BatchRelationshipDialog.accept();

    var attrs = {additional: true, instrument: []},
        relationships = recording0.relationships();

    equal(relationships[1].entity[0](), newTarget, "recording 0 target");
    deepEqual(ko.toJS(relationships[1].attrs), attrs, "recording 0 attributes");

    relationships = recording1.relationships();
    equal(relationships[0].entity[0](), newTarget, "recording 0 target");
    deepEqual(ko.toJS(relationships[0].attrs), attrs, "recording 0 attributes");

    // BatchWorkRelationshipDialog

    var works = [ MB.entity({ type: "work", gid: this.fakeGID[2] }) ];
    UI.BatchRelationshipDialog.show(works);

    relationship = UI.Dialog.relationship();

    relationship.entity[0](newTarget);
    relationship.link_type(167);
    relationship.attrs().additional(true);

    UI.BatchRelationshipDialog.accept();

    relationships = works[0].relationships();
    equal(relationships[0].entity[0](), newTarget, "work target");
    deepEqual(ko.toJS(relationships[0].attrs), {additional: true}, "work attributes");
});
