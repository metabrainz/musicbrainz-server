// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const test = require('tape');

const MB_entity = require('../common/entity');

test("CoreEntity", function (t) {
    t.plan(2);

    var source = MB_entity({ gid: 123, entityType: "recording", name: "a recording" }),
        target = MB_entity({ gid: 456, entityType: "artist", name: "foo", sort_name: "bar" });

    t.equal(
        source.html(),
        '<a href="/recording/123"><bdi>a recording</bdi></a>',
        "recording link"
    );

    t.equal(
        target.html({ "target": "_blank" }),
        '<a href="/artist/456" target="_blank" title="bar"><bdi>foo</bdi></a>',
        "artist link"
    );
});
