// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

module("i18n");


test("MB.i18n.expand", function () {

    equal(
        MB.i18n.expand("An {apple_fruit}", { apple_fruit: "apple" }),
        "An apple",
        "Simple replacement"
    );

    equal(
        MB.i18n.expand("An {apple_fruit|Apple}", { apple_fruit: "http://www.apple.com" }),
        "An <a href=\"http://www.apple.com\">Apple</a>",
        "Replacement with links"
    );

    equal(
        MB.i18n.expand("A {apple_fruit|apple}", { apple_fruit: "http://www.apple.com", apple: "pear" }),
        "A <a href=\"http://www.apple.com\">pear</a>",
        "Replacement with link description evaluation"
    );

    equal(
        MB.i18n.expand("A {apple_fruit|apple}", { apple_fruit: { href: "http://www.apple.com", target: "_blank" }, apple: "pear" }),
        "A <a href=\"http://www.apple.com\" target=\"_blank\">pear</a>",
        "Replacement with link description evaluation and object argument"
    );

    equal(
        MB.i18n.expand("A {apple_fruit|apple}", {
            apple_fruit: "http://www.apple.com",
            apple: "<pears are=\"yellow, green & red\">"
        }),
        "A <a href=\"http://www.apple.com\">&lt;pears are=&quot;yellow, green &amp; red&quot;&gt;</a>",
        "Replacement with HTML-escaped characters"
    );

    equal(
        MB.i18n.expand("A {apple_fruit|^(apple|pear)[sz.]?$}", {
            apple_fruit: "http://www.apple.com",
            "^(apple|pear)[sz.]?$": "pear"
        }),
        "A <a href=\"http://www.apple.com\">pear</a>",
        "Replacement with RegExp-escaped characters"
    );
});
