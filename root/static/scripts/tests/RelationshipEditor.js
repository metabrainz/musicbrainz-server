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


MB.tests.RelationshipEditor.Util = function() {
    QUnit.module("Relationship editor");

    QUnit.test('Util', function() {
        var RE = MB.RelationshipEditor, Util = RE.Util;

        var tests = [
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
            }
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
            {root: Util.attrInfo(14), value: ["1", 0, "9", 0, "5"], expected: [1, 5, 9]}
        ];

        $.each(tests, function(i, test) {
            var result = new RE.Fields.Attribute(test.root, test.value)();
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
            {input: "012", expected: 12}
        ];

        $.each(tests, function(i, test) {
            field(test.input);
            QUnit.equal(field(), test.expected, String(test.input));
        });

        var relationship = RE.Relationship({
            entity: [RE.Entity({type: "recording"}), RE.Entity({type: "work"})],
            action: "add",
            link_type: 278
        });

        relationship.show();

        field = relationship.attrs;

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
            }
        ];

        $.each(tests, function(i, test) {
            field(test.input);
            var result = ko.toJS(field());
            QUnit.deepEqual(result, test.expected, JSON.stringify(test.input));
        });

        // test Fields.Entity

        field = relationship.entity[1];
        oldTarget = field.peek();
        newTarget = RE.Entity({type: "work"});

        QUnit.equal(oldTarget.performanceCount, 1, oldTarget.id + " performanceCount");
        QUnit.equal(newTarget.performanceCount, 0, newTarget.id + " performanceCount");

        field(newTarget);

        QUnit.equal(oldTarget.performanceCount, 0, oldTarget.id + " performanceCount");
        QUnit.equal(newTarget.performanceCount, 1, newTarget.id + " performanceCount");

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
            source = RE.Entity({type: "recording"}), target = RE.Entity({type: "artist"});

        var relationship = RE.Relationship({
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
                attrs: {instrument: [123, 229, 277], solo: true},
                expected: "solo zither, guitar and bass guitar"
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
                expected: "contains additional strings, guitars, lyre and plucked string instruments samples by"
            },
            // MBS-6129
            {
                linkType: 149,
                backward: true,
                attrs: {additional: false, vocal: [4]},
                expected: "lead vocals"
            },
            {
                linkType: 149,
                backward: true,
                attrs: {additional: false, vocal: []},
                expected: "vocal"
            }
        ];

        $.each(tests, function(i, test) {
            relationship.link_type(test.linkType);
            relationship.attrs(test.attrs);

            var result = relationship.linkPhrase(test.backward
                ? relationship.entity[1]() : relationship.entity[0]());

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

            QUnit.equal(result, test.expected, [
                JSON.stringify(test.begin_date),
                JSON.stringify(test.end_date),
                JSON.stringify(test.ended)
            ].join(", "));
        });

        // test errors

        // the source/target have invalid gids to start with, so errorCount = 2
        QUnit.equal(relationship.errorCount, 2, "relationship.errorCount");

        // ended must be boolean
        relationship.period.ended(null);
        QUnit.equal(relationship.errorCount, 3, "relationship.errorCount");

        // date must exist
        relationship.period.begin_date("2001-01-32");
        QUnit.equal(relationship.errorCount, 4, "relationship.errorCount");

        relationship.period.begin_date("2001-01-31");
        QUnit.equal(relationship.errorCount, 3, "relationship.errorCount");

        // end date must be after begin date
        relationship.period.end_date("2000-01-31");
        QUnit.equal(relationship.errorCount, 4, "relationship.errorCount");

        relationship.period.end_date("2002-01-31");
        QUnit.equal(relationship.errorCount, 3, "relationship.errorCount");

        relationship.entity[0]().gid = "00000000-0000-0000-0000-000000000001";
        relationship.entity[0].notifySubscribers(relationship.entity[0]());
        QUnit.equal(relationship.errorCount, 2, "relationship.errorCount");

        relationship.entity[1]().gid = "00000000-0000-0000-0000-000000000002";
        relationship.entity[1].notifySubscribers(relationship.entity[1]());
        QUnit.equal(relationship.errorCount, 1, "relationship.errorCount");

        relationship.period.ended(true);
        QUnit.equal(relationship.errorCount, 0, "relationship.errorCount");
    });
};


MB.tests.RelationshipEditor.Entity = function() {
    QUnit.module("Relationship editor");

    QUnit.test('Entity', function() {

        var RE = MB.RelationshipEditor,
            source = RE.Entity({type: "recording", name: "a recording"}),
            target = RE.Entity({type: "artist", name: "foo", sortname: "bar"});

        QUnit.equal(
            source.rendering,
            _.sprintf('<a href="/recording/%s" target="_blank">a recording</a>', source.gid),
            "recording link"
        );

        QUnit.equal(
            target.rendering,
            _.sprintf('<a href="/artist/%s" target="_blank" title="bar">foo</a>', target.gid),
            "artist link"
        );

        QUnit.equal(RE.Entity.isInstance(source), true, "entity isInstance");
        QUnit.equal(RE.Entity.isInstance({}), false, "object isInstance");

        var relationship = RE.Relationship({
            entity: [target, source],
            action: "add",
            link_type: 148,
            attrs: {instrument: [123, 277], guest: true},
            period: {begin_date: "2001", end_date: "", ended: false}
        });

        var duplicateRelationship = RE.Relationship({
            entity: [target, source],
            action: "add",
            link_type: 148,
            attrs: {instrument: [123, 277], guest: true},
            period: {begin_date: "", end_date: "2002", ended: true}
        });

        relationship.show();
        duplicateRelationship.show();

        source.mergeRelationship(duplicateRelationship);

        QUnit.deepEqual(
            ko.toJS(relationship.attrs),
            {instrument: [123, 277], additional: false, guest: true, solo: false},
            "attributes"
        );

        QUnit.deepEqual(
            ko.toJS(relationship.period.begin_date),
            {year: 2001, month: null, day: null},
            "begin date"
        );

        QUnit.deepEqual(
            ko.toJS(relationship.period.end_date),
            {year: 2002, month: null, day: null},
            "end date"
        );

        QUnit.equal(relationship.period.ended(), true, "ended");

        QUnit.equal(source.relationships.indexOf(duplicateRelationship), -1,
            "removed from source's relationships");

        QUnit.equal(duplicateRelationship.removed, true,
            "relationship.removed");

        var notDuplicateRelationship = RE.Relationship({
            entity: [target, source],
            action: "add",
            link_type: 148,
            period: {begin_date: "2003", end_date: "2004"}
        });

        notDuplicateRelationship.show();

        QUnit.equal(source.mergeRelationship(notDuplicateRelationship),
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
        QUnit.equal(recording.name, "Love Me Do", "recording name");
        QUnit.equal(recording.id, 6393661, "recording id");
        QUnit.equal(recording.gid, "87ec065e-f139-41b9-b3b9-f746addf5b1e", "recording gid");

        // test artist credit rendering
        var ac = [
            {
                artist: {
                    sortname: "Sheridan, Tony",
                    name: "Tony Sheridan",
                    id: 117906,
                    gid: "7f9a3245-df19-4681-8314-4a4c1281dc74"
                },
                joinphrase: " & "
            },
            {
                artist: {
                    sortname: "Beatles, The",
                    name: "The Beatles",
                    id: 303,
                    gid: "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d"
                },
                joinphrase: ""
            }
        ];

        QUnit.equal(RE.UI.renderArtistCredit(ac),
            '<a href="/artist/7f9a3245-df19-4681-8314-4a4c1281dc74" target="_blank" title="Sheridan, Tony">Tony Sheridan</a> & ' +
            '<a href="/artist/b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d" target="_blank" title="Beatles, The">The Beatles</a>',
            "artist credit rendering");
    });
};


MB.tests.RelationshipEditor.Dialog = function() {
    QUnit.module("Relationship editor");

    QUnit.test('Dialog', function() {

        var RE = MB.RelationshipEditor, UI = RE.UI, Util = RE.Util,
            vm = RE.releaseViewModel,
            recordings = vm.media()[0].recordings(),
            source = recordings[0],
            target = RE.Entity({type: "artist", gid: "00000000-0000-0000-0000-000000000003"});

        UI.Dialog.resize = function() {};

        var tests = [
            {
                entity: [RE.Entity({type: "recording"}), RE.Entity({type: "release"})],
                backward: true,
                source: function() {return this.entity[1];},
                target: function() {return this.entity[0];}
            },
            {
                entity: [RE.Entity({type: "recording"}), RE.Entity({type: "release"})],
                backward: false,
                source: function() {return this.entity[0];},
                target: function() {return this.entity[1];}
            }
        ];

        $.each(tests, function(i, test) {
            UI.AddDialog.show({entity: test.entity, source: test.source()});

            QUnit.equal(UI.Dialog.backward(), test.backward,
                "entities should be backward: " + test.backward);

            QUnit.equal(UI.Dialog.source, test.source(),
                "source should be entity[" + (test.backward ? "1" : "0") + "]");

            QUnit.equal(UI.Dialog.target, test.target(),
                "target should be entity[" + (test.backward ? "0" : "1") + "]");

            UI.AddDialog.hide();
        });

        // AddDialog

        UI.AddDialog.show({entity: [target, source], source: source});
        var relationship = UI.Dialog.relationship();
        relationship.link_type(148);
        relationship.attrs({instrument: [229]});
        UI.AddDialog.accept();

        QUnit.equal(source.relationships()[0], relationship, "AddDialog");

        // AddDialog - relationship between recordings on same release (MBS-5389)

        UI.AddDialog.show({entity: [recordings[0], recordings[1]], source: recordings[1]});
        relationship = UI.Dialog.relationship();
        relationship.link_type(231);

        QUnit.equal(UI.Dialog.sourceField(), relationship.entity[1], "AddDialog sourceField");
        QUnit.equal(UI.Dialog.targetField(), relationship.entity[0], "AddDialog targetField");
        QUnit.equal(UI.Dialog.source, recordings[1], "AddDialog source");
        QUnit.equal(UI.Dialog.target, recordings[0], "AddDialog target");
        QUnit.equal(UI.Dialog.backward(), true, "AddDialog: relationship is backward");

        UI.Dialog.changeDirection();

        QUnit.equal(UI.Dialog.sourceField(), relationship.entity[0], "AddDialog sourceField");
        QUnit.equal(UI.Dialog.targetField(), relationship.entity[1], "AddDialog targetField");
        // source and target should stay the same
        QUnit.equal(UI.Dialog.source, recordings[1], "AddDialog source");
        QUnit.equal(UI.Dialog.target, recordings[0], "AddDialog target");
        QUnit.equal(UI.Dialog.backward(), false, "AddDialog: relationship is not backward");

        UI.AddDialog.accept();

        QUnit.equal(recordings[0].relationships()[1], relationship, "relationship added to recording 0");
        QUnit.equal(recordings[1].relationships()[0], relationship, "relationship added to recording 1");

        relationship.remove();

        QUnit.equal(recordings[0].relationships()[1], undefined, "relationship removed from recording 0");
        QUnit.equal(recordings[1].relationships()[0], undefined, "relationship removed from recording 1");

        // EditDialog

        relationship = source.relationships()[0];

        UI.EditDialog.show({relationship: relationship, source: source});
        var dialogAttrs = UI.Dialog.attrs();

        var solo = _.find(dialogAttrs, function(attr) {
            return attr.data.name == "solo";
        });

        solo.value(true);
        UI.EditDialog.accept();

        QUnit.deepEqual(
            ko.toJS(relationship.attrs),
            {instrument: [229], additional: false, guest: false, solo: true},
            "EditDialog"
        );

        UI.EditDialog.show({relationship: relationship, source: source});

        var instrument = _.find(dialogAttrs, function(attr) {
            return attr.data.name == "instrument";
        });

        instrument.value([229, 277]);

        var newTarget = RE.Entity({type: "artist"});
        UI.Dialog.targetField()(newTarget);

        // cancel should revert the change
        UI.EditDialog.hide();

        QUnit.deepEqual(relationship.attrs().instrument(), [229], "attributes changed back");
        QUnit.equal(relationship.entity[0](), target, "target changed back");

        // BatchRecordingRelationshipDialog

        UI.BatchRelationshipDialog.show(recordings);

        newTarget = RE.Entity({type: "artist", gid: "00000000-0000-0000-0000-000000000004"});

        relationship = UI.Dialog.relationship();

        UI.Dialog.targetField()(newTarget);
        relationship.link_type(154);
        relationship.attrs().additional(true);

        UI.BatchRelationshipDialog.accept();

        var attrs = {additional: true, instrument: []},
            relationships = recordings[0].relationships();

        QUnit.equal(relationships[1].entity[0](), newTarget, "recording 0 target");
        QUnit.deepEqual(ko.toJS(relationships[1].attrs), attrs, "recording 0 attributes");

        relationships = recordings[1].relationships();
        QUnit.equal(relationships[0].entity[0](), newTarget, "recording 0 target");
        QUnit.deepEqual(ko.toJS(relationships[0].attrs), attrs, "recording 0 attributes");

        // BatchWorkRelationshipDialog

        var works = [RE.Entity({type: "work", gid: "00000000-0000-0000-0000-000000000005"})];
        UI.BatchRelationshipDialog.show(works);

        relationship = UI.Dialog.relationship();

        relationship.entity[0](newTarget);
        relationship.link_type(167);
        relationship.attrs().additional(true);

        UI.BatchRelationshipDialog.accept();

        relationships = works[0].relationships();
        QUnit.equal(relationships[0].entity[0](), newTarget, "work target");
        QUnit.deepEqual(ko.toJS(relationships[0].attrs), {additional: true}, "work attributes");
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
