MB.tests.RelationshipEditor = (MB.tests.RelationshipEditor) ? MB.tests.RelationshipEditor : {};

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
                            "reverse_phrase": "{additional} {guest} {solo} {vocal} vocals",
                            "id": 149,
                            "phrase": "{additional} {guest} {solo} {vocal} vocals",
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
            "joinphrase": ""
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
        artist:          "Artist",
        label:           "Label",
        recording:       "Recording",
        release:         "Release",
        "release-group": "Release group",
        url:             "URL",
        work:            "Work",
    },
    AttributeNotSupported: "This attribute is not supported for the selected relationship type.",
    AttributeTooMany: "This attribute can only be specified {max} times. You specified {n}.",
    AttributeRequired: "This attribute is required.",
    InvalidDate: "The date you've entered is not valid.",
    InvalidEndDate: "The end date cannot preceed the begin date.",
    InvalidValue: "The value you've entered is not valid.",
    RequiredField: "Required field.",
});

MB.text.Date = {from: "from", until: "until", on: "on"};

MB.tests.RelationshipEditor.Util = function() {
    QUnit.module("Relationship editor");

    QUnit.test('Util', function() {
        var RE = MB.RelationshipEditor, Util = RE.Util;

        var tests = [
            // artist-recording
            {
                source: Util.tempEntity("recording"),
                target: Util.tempEntity("artist"),
                expected: function() {
                    return [this.target, this.source];
                }
            },
            // recording-release
            {
                source: Util.tempEntity("recording"),
                target: Util.tempEntity("release"),
                expected: function() {
                    return [this.source, this.target];
                }
            },
            {
                source: Util.tempEntity("recording"),
                target: Util.tempEntity("release"),
                backward: true,
                expected: function() {
                    return [this.target, this.source];
                }
            },
            // recording-work
            {
                source: Util.tempEntity("recording"),
                target: Util.tempEntity("work"),
                expected: function() {
                    return [this.source, this.target];
                }
            },
            {
                source: Util.tempEntity("recording"),
                target: Util.tempEntity("work"),
                backward: true,
                expected: function() {
                    return [this.target, this.source];
                }
            },
            // work-work
            {
                source: Util.tempEntity("work"),
                target: Util.tempEntity("work"),
                backward: true,
                expected: function() {
                    return [this.target, this.source];
                }
            }
        ];

        $.each(tests, function(i, test) {
            var obj = {source: test.source, target: test.target}, relationship;
            if (test.backward) obj.backward = true;
            relationship = RE.Relationship(obj);

            QUnit.deepEqual(relationship.entity(), test.expected(),
                relationship.type() + ", " + relationship.backward());
        });

        tests = [
            {date: "", expected: {
                year: null, month: null, day: null}
            },
            {date: "1999-01-02", expected: {
                year: "1999", month: "01", day: "02"}
            },
            {date: "1999-01", expected: {
                year: "1999", month: "01", day: null}
            },
            {date: "1999", expected: {
                year: "1999", month: null, day: null}
            },
        ];

        $.each(tests, function(i, test) {
            var result = RE.Util.parseDate(test.date);
            QUnit.deepEqual(result, test.expected, test.date);
        });

        tests = [
            {root: Util.attrInfo(424), value: undefined, expected: false},
            {root: Util.attrInfo(424), value: null, expected: false},
            {root: Util.attrInfo(424), value: 0, expected: false},
            {root: Util.attrInfo(424), value: 1, expected: true},
            {root: Util.attrInfo(14), value: undefined, expected: []},
            {root: Util.attrInfo(14), value: null, expected: []},
            {root: Util.attrInfo(14), value: 0, expected: []},
            {root: Util.attrInfo(14), value: [0], expected: []},
            {root: Util.attrInfo(14), value: ["foo", "bar", "baz"], expected: []},
            {root: Util.attrInfo(14), value: 1, expected: [1]},
            {root: Util.attrInfo(14), value: [3, 3, 2, 2, 1, 1], expected: [1, 2, 3]},
            {root: Util.attrInfo(14), value: ["3", "3", "2", "2", "1", "1"], expected: [1, 2, 3]},
            {root: Util.attrInfo(14), value: ["1", 0, "9", 0, "5"], expected: [1, 5, 9]},
        ];

        $.each(tests, function(i, test) {
            var result = RE.Util.convertAttr(test.root, test.value);
            QUnit.deepEqual(result, test.expected, String(test.value));
        });

        var ac1 = [{artist: {gid: 1, name: "a"}, joinphrase: "/"}],
            ac2 = [{artist: {gid: 1, name: "b"}, joinphrase: "/"}],
            ac3 = [{artist: {gid: 1, name: "a"}, joinphrase: "/"}, {artist: {gid: 2, name: "b"}}];

        QUnit.equal(RE.Util.compareArtistCredits(ac1, ac1), true,
            JSON.stringify(ac1) + " == " + JSON.stringify(ac1));

        QUnit.equal(RE.Util.compareArtistCredits(ac1, ac2), false,
            JSON.stringify(ac1) + " != " + JSON.stringify(ac2));

        QUnit.equal(RE.Util.compareArtistCredits(ac1, ac3), false,
            JSON.stringify(ac1) + " != " + JSON.stringify(ac3));
    });
};


MB.tests.RelationshipEditor.Fields = function() {
    QUnit.module("Relationship editor");

    QUnit.test('Fields', function() {
        var RE = MB.RelationshipEditor, Fields = RE.Fields;

        var field = new Fields.Integer();

        var tests = [
            {input: undefined, expected: null},
            {input: false, expected: null},
            {input: "", expected: null},
            {input: 0, expected: 0},
            {input: 12, expected: 12},
            {input: "0", expected: 0},
            {input: "012", expected: 12},
        ];

        $.each(tests, function(i, test) {
            field(test.input);
            QUnit.equal(field(), test.expected, String(test.input));
        });

        var relationship = RE.Relationship({
            source: RE.Util.tempEntity("recording"),
            target: RE.Util.tempEntity("work"),
            action: "add",
            link_type: 278
        }, false);

        field = new Fields.Attributes(relationship);

        tests = [
            {
                input: {},
                expected: {partial: false, live: false, instrumental: false, cover: false}
            },
            {
                input: {foo: 1, bar: 2, partial: undefined},
                expected: {partial: false, live: false, instrumental: false, cover: false}
            },
            {
                input: {cover: 1, instrumental: 0, live: 1},
                expected: {partial: false, live: true, instrumental: false, cover: true}
            },
        ];

        $.each(tests, function(i, test) {
            field(test.input);
            var result = ko.toJS(field());
            QUnit.deepEqual(result, test.expected, JSON.stringify(test.input));
        });

        // test Fields.Target

        field = relationship.target;
        oldTarget = field.peek();
        newTarget = RE.Util.tempEntity("work");

        QUnit.equal(oldTarget.refcount, 1, oldTarget.id + " refcount");
        QUnit.equal(oldTarget.performanceRefcount, 1, oldTarget.id + " performanceRefcount");
        QUnit.equal(newTarget.refcount, 0, newTarget.id + " refcount");
        QUnit.equal(newTarget.performanceRefcount, 0, newTarget.id + " performanceRefcount");

        field(newTarget);

        QUnit.equal(oldTarget.refcount, 0, oldTarget.id + " refcount");
        QUnit.equal(oldTarget.performanceRefcount, 0, oldTarget.id + " performanceRefcount");
        QUnit.equal(newTarget.refcount, 1, newTarget.id + " refcount");
        QUnit.equal(newTarget.performanceRefcount, 1, newTarget.id + " performanceRefcount");

        // test Fields.PartialDate

        field = new Fields.PartialDate("");
        QUnit.deepEqual(ko.toJS(field), {year: null, month: null, day: null}, "\"\"");

        field("2012-08-21");
        QUnit.deepEqual(ko.toJS(field), {year: 2012, month: 8, day: 21}, "2012-08-21");

        field({year: 2011, month: 7, day: 20});
        QUnit.deepEqual(ko.toJS(field), {year: 2011, month: 7, day: 20}, "{year: 2012, month: 7, day: 20}");

        field(undefined);
        QUnit.deepEqual(ko.toJS(field), {year: null, month: null, day: null}, "undefined");
    });
};


MB.tests.RelationshipEditor.Relationship = function() {
    QUnit.module("Relationship editor");

    QUnit.test('Relationship', function() {

        var RE = MB.RelationshipEditor,
            source = RE.Util.tempEntity("recording"),
            target = RE.Util.tempEntity("artist");

        var relationship = RE.Relationship({
            source: source,
            target: target,
            action: "add",
            link_type: 148
        }, false);

        // link phrase construction

        var tests = [
            // test attribute interpolation
            {
                linkType: 148,
                backward: false,
                attrs: {instrument: [123, 229, 277], solo: true},
                expected: "solo zither, guitar & bass guitar"
            },
            {
                linkType: 141,
                backward: true,
                attrs: {co: true, executive: true},
                expected: "co-executive producer"
            },
            {
                linkType: 154,
                backward: true,
                attrs: {instrument: [69, 75, 109, 302], additional: true},
                expected: "contains additional strings, guitars, lyre & plucked string instruments samples by"
            }
        ];

        $.each(tests, function(i, test) {
            relationship.link_type(test.linkType);
            relationship.backward(test.backward);
            relationship.attributes(test.attrs);
            var result = relationship.buildLinkPhrase();

            QUnit.equal(result, test.expected, [test.linkType, JSON.stringify(test.attrs)].join(", "));
        });

        // test date rendering

        tests = [
            {
                begin_date: {year: 2001, month: 5, day: 13},
                end_date: {},
                ended: true,
                expected: "2001-05-13 – ????"
            },
            {
                begin_date: {year: 2001, month: 5, day: 13},
                end_date: {},
                ended: false,
                expected: "2001-05-13 – "
            },
            {
                begin_date: {year: 2001, month: 5, day: 13},
                end_date: {year: 2001, month: 5, day: 13},
                ended: true,
                expected: "2001-05-13"
            },
            {
                begin_date: {},
                end_date: {year: 2002, month: 8, day: 12},
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

        $.each(tests, function(i, test) {
            var a = relationship.begin_date(), b = relationship.end_date();

            a.year(test.begin_date.year);
            a.month(test.begin_date.month);
            a.day(test.begin_date.day);

            b.year(test.end_date.year);
            b.month(test.end_date.month);
            b.day(test.end_date.day);

            relationship.ended(test.ended);
            var result = relationship.renderDate();

            QUnit.equal(result, test.expected, [
                JSON.stringify(test.begin_date),
                JSON.stringify(test.end_date),
                JSON.stringify(test.ended)
            ].join(", "));
        });

        // test errors

        // the target has an invalid gid to start with, so errorCount = 1
        QUnit.equal(relationship.errorCount, 1, "relationship.errorCount");

        // backward must be either true or false
        relationship.backward("foo");
        QUnit.equal(relationship.errorCount, 2, "relationship.errorCount");

        // ended must be boolean
        relationship.ended(null);
        QUnit.equal(relationship.errorCount, 3, "relationship.errorCount");

        // date must exist
        relationship.begin_date("2001-01-32");
        QUnit.equal(relationship.errorCount, 4, "relationship.errorCount");

        relationship.begin_date("2001-01-31");
        QUnit.equal(relationship.errorCount, 3, "relationship.errorCount");

        // end date must be after begin date
        relationship.end_date("2000-01-31");
        QUnit.equal(relationship.errorCount, 4, "relationship.errorCount");

        relationship.end_date("2002-01-31");
        QUnit.equal(relationship.errorCount, 3, "relationship.errorCount");

        relationship.target().gid = "00000000-0000-0000-0000-000000000000";
        relationship.target.notifySubscribers(relationship.target());
        QUnit.equal(relationship.errorCount, 2, "relationship.errorCount");

        relationship.backward(true);
        QUnit.equal(relationship.errorCount, 1, "relationship.errorCount");

        relationship.ended(true);
        QUnit.equal(relationship.errorCount, 0, "relationship.errorCount");
    });
};


MB.tests.RelationshipEditor.Entity = function() {
    QUnit.module("Relationship editor");

    QUnit.test('Entity', function() {

        var RE = MB.RelationshipEditor,
            entity = RE.Util.tempEntity("artist");

        QUnit.equal(
            entity.rendering(),
            _.sprintf('<a href="/artist/%s" target="_blank" />', entity.gid),
            "artist link"
        );

        entity.sortname("foo");

        QUnit.equal(
            entity.rendering(),
            _.sprintf('<a href="/artist/%s" target="_blank" title="foo" />', entity.gid),
            "artist link w/ sortname"
        );

        QUnit.equal(RE.Entity.isInstance(entity), true, "entity isInstance");
        QUnit.equal(RE.Entity.isInstance({}), false, "object isInstance");

        var relationship = RE.Relationship({
            source: RE.Util.tempEntity("recording"),
            target: entity,
            action: "add",
            link_type: 148,
            attributes: {instrument: [123, 277], guest: true},
            begin_date: "2001",
            end_date: ""
        }, false);

        var duplicateRelationship = RE.Relationship({
            source: relationship.source,
            target: entity,
            action: "add",
            link_type: 148,
            attributes: {instrument: [229], solo: true},
            begin_date: "",
            end_date: "2002"
        }, false);

        relationship.show();
        duplicateRelationship.show();

        relationship.source.mergeRelationship(duplicateRelationship);

        QUnit.deepEqual(
            ko.toJS(relationship.attributes),
            {instrument: [229], additional: false, guest: true, solo: true},
            "attributes"
        );

        QUnit.deepEqual(
            ko.toJS(relationship.begin_date),
            {year: 2001, month: null, day: null},
            "begin date"
        );

        QUnit.deepEqual(
            ko.toJS(relationship.end_date),
            {year: 2002, month: null, day: null},
            "end date"
        );

        QUnit.equal(relationship.source.relationships.indexOf(duplicateRelationship), -1,
            "removed from source's relationships");

        QUnit.equal(duplicateRelationship.removed, true,
            "relationship.removed");

        var notDuplicateRelationship = RE.Relationship({
            source: relationship.source,
            target: entity,
            action: "add",
            link_type: 148,
            begin_date: "2003",
            end_date: "2004"
        }, false);

        QUnit.equal(relationship.source.mergeRelationship(notDuplicateRelationship),
            false, "different dates -> not merged")
    });
};


MB.tests.RelationshipEditor.RelationshipEditor = function() {
    QUnit.module("Relationship editor");

    QUnit.test('RelationshipEditor', function() {
        var RE = MB.RelationshipEditor, vm = RE.releaseViewModel,
            media = vm.media();

        QUnit.equal(media.length, 1, "medium count");

        var recordings = media[0].recordings();
        QUnit.equal(recordings.length, 2, "recording count");

        var recording = recordings[0];
        QUnit.equal(recording.number, "A", "recording number");
        QUnit.equal(recording.position, 1, "recording position");
        QUnit.equal(recording.name(), "Love Me Do", "recording name");
        QUnit.equal(recording.id, 6393661, "recording id");
        QUnit.equal(recording.gid, "87ec065e-f139-41b9-b3b9-f746addf5b1e", "recording gid");
    });
};


MB.tests.RelationshipEditor.Dialog = function() {
    QUnit.module("Relationship editor");

    QUnit.test('Dialog', function() {

        var RE = MB.RelationshipEditor, UI = RE.UI, vm = RE.releaseViewModel,
            recordings = vm.media()[0].recordings(), source = recordings[0],
            target = RE.Util.tempEntity("artist");

        // AddDialog

        target.gid = "00000000-0000-0000-0000-000000000000";
        target.name("foo");

        UI.AddDialog.show({source: source, target: target});
        var relationship = UI.Dialog.relationship();
        relationship.link_type(148);
        relationship.attributes({instrument: [229]});
        UI.AddDialog.accept();

        QUnit.equal(source.relationships()[0], relationship, "AddDialog");

        // EditDialog

        UI.EditDialog.show(relationship);
        var dialogAttrs = UI.Dialog.attributes();

        var solo = _.find(dialogAttrs, function(attr) {
            return attr.data.name == "solo";
        });

        solo.value(true);
        UI.EditDialog.accept();

        QUnit.deepEqual(
            ko.toJS(relationship.attributes),
            {instrument: [229], additional: false, guest: false, solo: true},
            "EditDialog"
        );

        UI.EditDialog.show(relationship);

        var instrument = _.find(dialogAttrs, function(attr) {
            return attr.data.name == "instrument";
        });

        instrument.value([229, 277]);

        var newTarget = RE.Util.tempEntity("artist");
        relationship.target(newTarget);
        QUnit.equal(newTarget.refcount, 1, "newTarget refcount");

        // cancel should revert the change
        UI.EditDialog.hide();

        QUnit.deepEqual(relationship.attributes().instrument(), [229], "attributes changed back");
        QUnit.equal(relationship.target(), target, "target changed back");
        QUnit.equal(newTarget.refcount, 0, "newTarget refcount");

        // BatchRecordingRelationshipDialog

        // XXX rewrite checkedRecordings so that batch tests work
        UI.checkedRecordings = function() {return recordings};

        UI.BatchRecordingRelationshipDialog.show();

        newTarget = RE.Util.tempEntity("work");
        newTarget.gid = "00000000-0000-0000-0000-000000000001";
        newTarget.name("workfoo");

        relationship = UI.Dialog.relationship();

        relationship.target(newTarget);
        relationship.link_type(278);
        relationship.attributes().live(true);

        UI.BatchRecordingRelationshipDialog.accept();

        for (var i = 0; i <= 1; i++) {
            var relationships = recordings[i].performanceRelationships();
            QUnit.equal(relationships[0].target(), newTarget, "recording " + i + " target");
            QUnit.deepEqual(
                ko.toJS(relationships[0].attributes),
                {live: true, partial: false, instrumental: false, cover: false},
                "recording " + i + " attributes"
            );
        }

        // BatchWorkRelationshipDialog

        var works = [newTarget];
        UI.checkedWorks = function() {return works};

        UI.BatchWorkRelationshipDialog.show();

        newTarget = RE.Util.tempEntity("artist");
        newTarget.gid = "00000000-0000-0000-0000-000000000002";
        newTarget.name("writer");

        relationship = UI.Dialog.relationship();

        relationship.target(newTarget);
        relationship.link_type(167);
        relationship.attributes().additional(true);

        UI.BatchWorkRelationshipDialog.accept();

        var relationships = works[0].relationships();
        QUnit.equal(relationships[0].target(), newTarget, "work target");
        QUnit.deepEqual(
            ko.toJS(relationships[0].attributes),
            {additional: true},
            "work attributes"
        );
    });
};


MB.tests.RelationshipEditor.Run = function() {
    var RE = MB.RelationshipEditor;

    RE.Util.callbackQueue = function(targets, callback) {
        for (var i = 0; i < targets.length; i++)
            callback(targets[i]);
    };

    RE.Util.init(typeInfo, attrInfo);
    RE.UI.init(testRelease.gid, testRelease.release_group.gid, testRelease);
    RE.UI.Dialog.init();

    MB.tests.RelationshipEditor.Util();
    MB.tests.RelationshipEditor.Fields();
    MB.tests.RelationshipEditor.Relationship();
    MB.tests.RelationshipEditor.Entity();
    MB.tests.RelationshipEditor.RelationshipEditor();
    MB.tests.RelationshipEditor.Dialog();
};
