MB.tests.utility = (MB.tests.utility) ? MB.tests.utility : {};

MB.tests.utility.All = function() {
    QUnit.module('utility');
    QUnit.test('All', function() {

        var input = "ＭｕｓｉｃＢｒａｉｎｚ！～２０１１";
        var expected = "MusicBrainz!~2011";
        QUnit.equals (MB.utility.fullWidthConverter (input),
                      expected, "fullWidthConverter (" + input + ")");

        input1 = {
            'length': '4:03',
            'title': 'the Love bug',
            'names': [
                { 'name': 'm-flo', 'id': '135345' },
                { 'name': 'BoA', 'id': '9496' }
            ]
        };

        input2 = {
            'names': [
                { 'id': '135345', 'name': 'm-flo' },
                { 'name': 'BoA', 'id': '9496' }
            ],
            'title': 'the Love bug',
            'length': '4:03'
        };

        input3 = {
            'names': [
                { 'name': 'BoA', 'id': '9496' },
                { 'id': '135345', 'name': 'm-flo' }
            ],
            'title': 'the Love bug',
            'length': '4:03'
        };

        QUnit.equal (MB.utility.structureToString (input1),
                     MB.utility.structureToString (input2),
                     'structureToString equivalent');
        QUnit.notEqual (MB.utility.structureToString (input2),
                        MB.utility.structureToString (input3),
                        'structureToString different');

        var input1sha = b64_sha1 (MB.utility.structureToString (input1));
        QUnit.equal (input1sha, "aIkUXodpaNX7Q1YfttiKMkKCxB0", "SHA-1 of input1");
    });

    QUnit.test('Expand and Collapse Hash', function () {

        var collapsed = {
            'name': 'Planet Mu',
            'lifespan.begin.year': 1995,
            'lifespan.begin.month': 11,
            'lifespan.begin.day': null,
            'lifespan.end.year': null,
            'lifespan.end.month': null,
            'lifespan.end.day': null,
            'medium.1.track.0.name': 'Fuel',
            'medium.1.track.1.name': 'The Memory Remains',
            'medium.1.name': 'Reload',
            'medium.0.name': 'Load'
        };

        var expanded = {
            'name': 'Planet Mu',
            'lifespan': {
                'begin': {
                    'year': 1995,
                    'month': 11,
                    'day': null
                },
                'end': {
                    'year': null,
                    'month': null,
                    'day': null
                }
            },
            'medium': [
                {
                    'name': 'Load'
                },
                {
                    'name': 'Reload',
                    'track': [
                        { 'name': 'Fuel' },
                        { 'name': 'The Memory Remains' },
                    ]
                }
            ]
        };

        QUnit.deepEqual (MB.utility.expand_hash (collapsed), expanded, "expand hash object");
        QUnit.deepEqual (MB.utility.collapse_hash (expanded), collapsed, "collapse hash object");

        expanded = {"lifespan":{"begin":{"month":["Not an integer"]}}};
        collapsed = {"lifespan.begin.month":["Not an integer"]};

        QUnit.deepEqual (MB.utility.collapse_hash (expanded), collapsed, "collapse hash object");
    });
};

MB.tests.utility.Run = function() {
    MB.tests.utility.All ();
};


