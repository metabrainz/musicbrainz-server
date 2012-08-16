MB.tests.RelationshipEditor = (MB.tests.RelationshipEditor) ? MB.tests.RelationshipEditor : {};

var typeInfo = {"recording-release":[{"attrs":{"1":[0,1],"14":[0,null]},"reverse_phrase":"{additional:additionally} {instrument} sampled by","id":69,"phrase":"{additional} {instrument} samples from","descr":"Indicates that a track contains samples from an album. (<a href=\"http://musicbrainz.org/doc/Samples_Relationship_Type\">Details</a>)"}],"artist-recording":[{"reverse_phrase":"performance","children":[{"attrs":{"1":[0,1],"194":[0,1],"596":[0,1]},"reverse_phrase":"{additional} {guest} {solo} performer","children":[{"attrs":{"1":[0,1],"14":[1,null],"194":[0,1],"596":[0,1]},"reverse_phrase":"{additional} {guest} {solo} {instrument}","id":148,"phrase":"{additional} {guest} {solo} {instrument}","descr":"Indicates an artist that performed a particular instrument on this work. (<a href=\"http://musicbrainz.org/doc/Performer_Relationship_Type\">Details</a>)"},{"attrs":{"1":[0,1],"3":[0,null],"194":[0,1],"596":[0,1]},"reverse_phrase":"{additional} {guest} {solo} {vocal} vocals","id":149,"phrase":"{additional} {guest} {solo} {vocal} vocals","descr":"Indicates an artist performed in a particular voice on this work. (<a href=\"http://musicbrainz.org/doc/Performer_Relationship_Type\">Details</a>)"}],"id":156,"phrase":"{additional:additionally} {guest} {solo} performed","descr":"Indicates an artist that performed on this work. (<a href=\"http://musicbrainz.org/doc/Performer_Relationship_Type\">Details</a>)"}],"id":122,"phrase":"performance"},{"reverse_phrase":"remixes","children":[{"attrs":{"1":[0,1],"14":[0,null]},"reverse_phrase":"contains {additional} {instrument} samples by","id":154,"phrase":"produced {instrument} material that was {additional:additionally} sampled in","descr":"Indicates that the track contains samples from material that was originally performed by another artist. Use this only if you really cannot figure out the particular track that has been sampled. (<a href=\"http://musicbrainz.org/doc/Samples_Artist_Relationship_Type\">Details</a>)"}],"id":157,"phrase":"remixes"},{"reverse_phrase":"production","children":[{"attrs":{"1":[0,1],"424":[0,1],"425":[0,1],"526":[0,1],"527":[0,1]},"reverse_phrase":"{additional} {assistant} {associate} {co:co-}{executive:executive }producer","id":141,"phrase":"{additional:additionally} {assistant} {associate} {co:co-}{executive:executive }produced","descr":"Indicates the producer, co-producer, executive producer or co-executive producer for this work. (<a href=\"http://musicbrainz.org/doc/Producer_Relationship_Type\">Details</a>)"}],"id":160,"phrase":"production"}],"recording-work":[{"reverse_phrase":"covers or other versions","children":[{"attrs":{"567":[0,1],"578":[0,1],"579":[0,1],"580":[0,1]},"reverse_phrase":"{partial} {live} {instrumental} {cover} recordings","id":278,"phrase":"{partial} {live} {instrumental} {cover} recording of","descr":"This is used to link works to their recordings. (<a href=\"http://musicbrainz.org/doc/Performance_Relationship_Type\">Details</a>)"}],"id":245,"phrase":"covers or other versions"}]},
    attrInfo = {"partial":{"name":"partial","id":579},"cover":{"name":"cover","id":567},"executive":{"name":"executive","id":425},"co":{"name":"co","id":424},"solo":{"name":"solo","id":596},"instrumental":{"name":"instrumental","id":580},"instrument":{"name":"instrument","children":[{"name":"strings","children":[{"name":"plucked string instruments","children":[{"name":"guitars","children":[{"name":"guitar","id":229},{"name":"bass guitar","id":277}],"id":75},{"name":"lyre","id":109},{"name":"zither","id":123}],"id":302}],"id":69}],"id":14},"associate":{"name":"associate","id":527},"assistant":{"name":"assistant","id":526},"additional":{"name":"additional","id":1},"live":{"name":"live","id":578},"guest":{"name":"guest","id":194}};

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
                source: Util.tempEntity("artist"),
                target: Util.tempEntity("recording"),
                expected: function() {
                    return [this.target, this.source];
                }
            },
            // recording-release
            {
                source: Util.tempEntity("recording"),
                target: Util.tempEntity("release"),
                backward: false,
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
                backward: false,
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
        ];

        $.each(tests, function(i, test) {
            var relationship = RE.Relationship({source: test.source, target: test.target});

            if (test.backward !== undefined)
                relationship.backward(test.backward);

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
            QUnit.deepEqual(result, test.expected, test.value);
        });
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
            QUnit.equals(field(), test.expected, test.input);
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

            QUnit.equals(result, test.expected, [test.linkType, JSON.stringify(test.attrs)].join(", "));
        });

        // test date rendering

        tests = [
            {
                begin_date: {year: 2001, month: 5, day: 13},
                end_date: {},
                expected: "from 2001-5-13 – ????"
            },
            {
                begin_date: {year: 2001, month: 5, day: 13},
                end_date: {year: 2002, month: 8, day: 12},
                expected: "from 2001-5-13 – 2002-8-12"
            },
            {
                begin_date: {year: 2001, month: 5, day: 13},
                end_date: {year: 2001, month: 5, day: 13},
                expected: "on 2001-5-13"
            },
            {
                begin_date: {},
                end_date: {year: 2002, month: 8, day: 12},
                expected: "until 2002-8-12"
            },
            {
                begin_date: {},
                end_date: {},
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

            var result = relationship.renderDate();

            QUnit.equals(result, test.expected, [
                JSON.stringify(test.begin_date),
                JSON.stringify(test.end_date)
            ].join(", "));
        });

        // test errors

        // the target has an invalid gid to start with, so errorCount = 1
        QUnit.equals(relationship.errorCount, 1, "relationship.errorCount");

        // backward must be either true or false
        relationship.backward("foo");
        QUnit.equals(relationship.errorCount, 2, "relationship.errorCount");

        // date must exist
        relationship.begin_date("2001-01-32");
        QUnit.equals(relationship.errorCount, 3, "relationship.errorCount");

        relationship.begin_date("2001-01-31");
        QUnit.equals(relationship.errorCount, 2, "relationship.errorCount");

        // end date must be after begin date
        relationship.end_date("2000-01-31");
        QUnit.equals(relationship.errorCount, 3, "relationship.errorCount");

        relationship.end_date("2002-01-31");
        QUnit.equals(relationship.errorCount, 2, "relationship.errorCount");

        relationship.target().gid = "00000000-0000-0000-0000-000000000000";
        relationship.target.notifySubscribers(relationship.target());
        QUnit.equals(relationship.errorCount, 1, "relationship.errorCount");

        relationship.backward(true);
        QUnit.equals(relationship.errorCount, 0, "relationship.errorCount");
    });
};


MB.tests.RelationshipEditor.Run = function() {
    var RE = MB.RelationshipEditor;

    RE.Util.init(typeInfo, attrInfo);
    RE.UI.Dialog.init();

    MB.tests.RelationshipEditor.Util();
    MB.tests.RelationshipEditor.Fields();
    MB.tests.RelationshipEditor.Relationship();
};
