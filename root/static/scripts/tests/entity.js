MB.tests.entity = function() {
    QUnit.module("MB.entity");

    QUnit.test("CoreEntity", function() {
        var source = MB.entity({gid: 123, type: "recording", name: "a recording"}),
            target = MB.entity({gid: 456, type: "artist", name: "foo", sortname: "bar"});

        QUnit.equal(
            source.html(),
            '<a href="/recording/123" target="_blank">a recording</a>',
            "recording link"
        );

        QUnit.equal(
            target.html(),
            '<a href="/artist/456" target="_blank" title="bar">foo</a>',
            "artist link"
        );
    });

    QUnit.test("ArtistCredit", function() {
        var data = [
            [{artist: {gid: 1, name: "a"}, join_phrase: "/"}],
            [{artist: {gid: 1, name: "a"}, name: "b", join_phrase: "/"}],
            [{artist: {gid: 1, name: "a"}, join_phrase: "/"}, {artist: {gid: 2, name: "b"}}]
        ];

        var acs = [
            new MB.entity.ArtistCredit(data[0]),
            new MB.entity.ArtistCredit(data[1]),
            new MB.entity.ArtistCredit(data[2])
        ];

        QUnit.equal(acs[0].isEqual(acs[1]), false,
            JSON.stringify(data[0]) + " !== " + JSON.stringify(data[1]));

        QUnit.equal(acs[0].isEqual(acs[2]), false,
            JSON.stringify(data[0]) + " !== " + JSON.stringify(data[2]));

        QUnit.equal(acs[2].isEqual(acs[2]), true,
            JSON.stringify(data[2]) + " === " + JSON.stringify(data[2]));

        // test artist credit rendering
        var ac = [
            {
                artist: {
                    sortname: "Sheridan, Tony",
                    name: "Tony Sheridan",
                    id: 117906,
                    gid: "7f9a3245-df19-4681-8314-4a4c1281dc74"
                },
                join_phrase: " & "
            },
            {
                artist: {
                    sortname: "Beatles, The",
                    name: "The Beatles",
                    id: 303,
                    gid: "b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d"
                },
                join_phrase: ""
            }
        ];

        QUnit.equal(new MB.entity.ArtistCredit(ac).html(),
            '<a href="/artist/7f9a3245-df19-4681-8314-4a4c1281dc74" ' +
            'target="_blank" title="Sheridan, Tony">Tony Sheridan</a> &amp; ' +
            '<a href="/artist/b10bbbfc-cf9e-42e0-be17-e2c3e1d2600d" ' +
            'target="_blank" title="Beatles, The">The Beatles</a>',
            "artist credit rendering"
        );
    });
};
