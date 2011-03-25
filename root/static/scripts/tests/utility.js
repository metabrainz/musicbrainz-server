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
};

MB.tests.utility.Run = function() {
    MB.tests.utility.All ();
};


