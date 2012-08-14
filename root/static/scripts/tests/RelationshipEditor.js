MB.tests.RelationshipEditor = (MB.tests.RelationshipEditor) ? MB.tests.RelationshipEditor : {};

var typeInfo = {
    "69":{"attrs":{"1":[0,1],"14":[0,null]},"types":["recording","release"],"link_phrase":"{additional} {instrument} samples from","reverse_link_phrase":"{additional:additionally} {instrument} sampled by","id":69,"descr":"Indicates that a track contains samples from an album. (<a href=\"http://musicbrainz.org/doc/Samples_Relationship_Type\">Details</a>)","child_order":0},
    "122":{"types":["artist","recording"],"link_phrase":"performance","children":[156,150,151,152],"reverse_link_phrase":"performance","id":122,"child_order":0},
    "141":{"parent":160,"attrs":{"1":[0,1],"527":[0,1],"526":[0,1],"424":[0,1],"425":[0,1]},"types":["artist","recording"],"descr":"Indicates the producer, co-producer, executive producer or co-executive producer for this work. (<a href=\"http://musicbrainz.org/doc/Producer_Relationship_Type\">Details</a>)","link_phrase":"{additional:additionally} {assistant} {associate} {co:co-}{executive:executive }produced","id":141,"reverse_link_phrase":"{additional} {assistant} {associate} {co:co-}{executive:executive }producer","child_order":0},
    "148":{"parent":156,"attrs":{"596":[0,1],"1":[0,1],"194":[0,1],"14":[1,null]},"types":["artist","recording"],"descr":"Indicates an artist that performed a particular instrument on this work. (<a href=\"http://musicbrainz.org/doc/Performer_Relationship_Type\">Details</a>)","link_phrase":"{additional} {guest} {solo} {instrument}","id":148,"reverse_link_phrase":"{additional} {guest} {solo} {instrument}","child_order":0},
    "154":{"parent":157,"attrs":{"1":[0,1],"14":[0,null]},"types":["artist","recording"],"descr":"Indicates that the track contains samples from material that was originally performed by another artist. Use this only if you really cannot figure out the particular track that has been sampled. (<a href=\"http://musicbrainz.org/doc/Samples_Artist_Relationship_Type\">Details</a>)","link_phrase":"produced {instrument} material that was {additional:additionally} sampled in","id":154,"reverse_link_phrase":"contains {additional} {instrument} samples by","child_order":1},
    "156":{"parent":122,"attrs":{"596":[0,1],"1":[0,1],"194":[0,1]},"types":["artist","recording"],"children":[148,149],"descr":"Indicates an artist that performed on this work. (<a href=\"http://musicbrainz.org/doc/Performer_Relationship_Type\">Details</a>)","link_phrase":"{additional:additionally} {guest} {solo} performed","id":156,"reverse_link_phrase":"{additional} {guest} {solo} performer","child_order":0},
    "245":{"types":["recording","work"],"link_phrase":"covers or other versions","children":[278],"reverse_link_phrase":"covers or other versions","id":245,"child_order":0},
    "278":{"parent":245,"attrs":{"578":[0,1],"567":[0,1],"580":[0,1],"579":[0,1]},"types":["recording","work"],"descr":"This is used to link works to their recordings. (<a href=\"http://musicbrainz.org/doc/Performance_Relationship_Type\">Details</a>)","link_phrase":"{partial} {live} {instrumental} {cover} recording of","id":278,"reverse_link_phrase":"{partial} {live} {instrumental} {cover} recordings","child_order":0},
};

var attrMap = {
    "1":{"name":"additional","id":1,"descr":"This attribute describes if a particular performance role was considered normal or additional.","child_order":0},
    "14":{"name":"instrument","children":["15","69","124","159","185"],"id":14,"descr":"This attribute describes the possible instruments that can be captured as part of a performance. <br/> Can't find an instrument? <a href=\"http://wiki.musicbrainz.org/Advanced_Instrument_Tree\">Request it!</a>","child_order":3},
    "18":{"parent":17,"name":"bagpipe","children":["514","515"],"id":18,"child_order":0},
    "22":{"parent":493,"name":"oboe","children":["581","604","21","261","380"],"id":22,"child_order":0},
    "194":{"name":"guest","id":194,"descr":"This attribute indicates a 'guest' performance where the performer is not usually part of the band.","child_order":0},
    "229":{"parent":75,"name":"guitar","children":["77","522","79","80","377","529","399","400"],"id":229,"child_order":0},
    "424":{"name":"co","id":424,"descr":"co-[role]","child_order":0},
    "425":{"name":"executive","id":425,"descr":"This attribute is to be used if the role was fulfilled in an executive capacity.","child_order":0},
    "427":{"parent":17,"name":"crumhorn","id":427,"child_order":5},
    "526":{"name":"assistant","id":526,"descr":"This typically indicates someone who is either a first-timer, or less experienced, and who is working under the direction of someone who is more experienced.","child_order":0},
    "527":{"name":"associate","id":527,"descr":"This typically indicates someone who is less experienced and who is working under the direction of someone who is more experienced.","child_order":0},
    "567":{"name":"cover","id":567,"descr":"Indicates that one entity is a cover of another entity","child_order":0},
    "578":{"name":"live","id":578,"descr":"This indicates that the recording is of a live performance.","child_order":0},
    "579":{"name":"partial","id":579,"descr":"This indicates that the recording is not of the entire work, e.g. excerpts from, conclusion of, etc.","child_order":0},
    "580":{"name":"instrumental","id":580,"descr":"For works that have lyrics, this indicates that those lyrics are not relevant to this recording. Examples include instrumental arrangements, or \"beats\" from hip-hop songs which may be reused with different lyrics.","child_order":0},
    "595":{"parent":283,"name":"haegeum","id":595,"child_order":0},
    "596":{"name":"solo","id":596,"descr":"This should be used when an artist is credited in liner notes or a similar source as performing a solo part.","child_order":0},
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
            {root: RE.attrMap[424], value: undefined, expected: false},
            {root: RE.attrMap[424], value: null, expected: false},
            {root: RE.attrMap[424], value: 0, expected: false},
            {root: RE.attrMap[424], value: 1, expected: true},
            {root: RE.attrMap[14], value: undefined, expected: []},
            {root: RE.attrMap[14], value: null, expected: []},
            {root: RE.attrMap[14], value: 0, expected: []},
            {root: RE.attrMap[14], value: [0], expected: []},
            {root: RE.attrMap[14], value: ["foo", "bar", "baz"], expected: []},
            {root: RE.attrMap[14], value: 1, expected: [1]},
            {root: RE.attrMap[14], value: [3, 3, 2, 2, 1, 1], expected: [1, 2, 3]},
            {root: RE.attrMap[14], value: ["3", "3", "2", "2", "1", "1"], expected: [1, 2, 3]},
            {root: RE.attrMap[14], value: ["1", 0, "9", 0, "5"], expected: [1, 5, 9]},
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
                attrs: {instrument: [229], solo: true},
                expected: "solo guitar"
            },
            {
                linkType: 141,
                attrs: {co: true, executive: true},
                expected: "co-executive producer"
            },
            {
                linkType: 154,
                attrs: {instrument: [18, 22, 427], additional: true},
                expected: "contains additional bagpipe, oboe & crumhorn samples by"
            }
        ];

        $.each(tests, function(i, test) {
            relationship.link_type(test.linkType);
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

    RE.typeInfo = typeInfo;
    RE.attrMap = attrMap;

    RE.init({}, {});
    RE.UI.Dialog.init();

    MB.tests.RelationshipEditor.Util();
    MB.tests.RelationshipEditor.Fields();
    MB.tests.RelationshipEditor.Relationship();
};
