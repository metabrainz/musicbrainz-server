// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

var test = require('tape');

test("MB.i18n.expand", function (t) {
    t.plan(6);

    t.equal(
        MB.i18n.expand("An {apple_fruit}", { apple_fruit: "apple" }),
        "An apple",
        "Simple replacement"
    );

    t.equal(
        MB.i18n.expand("An {apple_fruit|Apple}", { apple_fruit: "http://www.apple.com" }),
        "An <a href=\"http://www.apple.com\">Apple</a>",
        "Replacement with links"
    );

    t.equal(
        MB.i18n.expand("A {apple_fruit|apple}", { apple_fruit: "http://www.apple.com", apple: "pear" }),
        "A <a href=\"http://www.apple.com\">pear</a>",
        "Replacement with link description evaluation"
    );

    t.equal(
        MB.i18n.expand("A {apple_fruit|apple}", { apple_fruit: { href: "http://www.apple.com", target: "_blank" }, apple: "pear" }),
        "A <a href=\"http://www.apple.com\" target=\"_blank\">pear</a>",
        "Replacement with link description evaluation and object argument"
    );

    t.equal(
        MB.i18n.expand("A {apple_fruit|apple}", {
            apple_fruit: "http://www.apple.com",
            apple: "<pears are=\"yellow, green & red\">"
        }),
        "A <a href=\"http://www.apple.com\">&lt;pears are=&quot;yellow, green &amp; red&quot;&gt;</a>",
        "Replacement with HTML-escaped characters"
    );

    t.equal(
        MB.i18n.expand("A {apple_fruit|^(apple|pear)[sz.]?$}", {
            apple_fruit: "http://www.apple.com",
            "^(apple|pear)[sz.]?$": "pear"
        }),
        "A <a href=\"http://www.apple.com\">pear</a>",
        "Replacement with RegExp-escaped characters"
    );
});

test("MB.i18n.commaList", function (t) {
    t.plan(5);

    t.equal(MB.i18n.commaList([]), "", "empty list");
    t.equal(MB.i18n.commaList(["a"]), "a", "list with one item");
    t.equal(MB.i18n.commaList(["a", "b"]), "a and b", "list with two items");
    t.equal(MB.i18n.commaList(["a", "b", "c"]), "a, b and c", "list with three items");
    t.equal(MB.i18n.commaList(["a", "b", "c", "d"]), "a, b, c and d", "list with four items");
});
