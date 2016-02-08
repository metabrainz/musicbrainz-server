// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const React = require('react');
const ReactDOMServer = require('react-dom/server');
const test = require('tape');

const i18n = require('../common/i18n');
const commaList = require('../common/i18n/commaList');
const commaOnlyList = require('../common/i18n/commaOnlyList');

test("i18n.expand", function (t) {
    t.plan(6);

    t.equal(
        i18n.expand("An {apple_fruit}", { apple_fruit: "apple" }),
        "An apple",
        "Simple replacement"
    );

    t.equal(
        i18n.expand("An {apple_fruit|Apple}", { apple_fruit: "http://www.apple.com" }),
        "An <a href=\"http://www.apple.com\">Apple</a>",
        "Replacement with links"
    );

    t.equal(
        i18n.expand("A {apple_fruit|apple}", { apple_fruit: "http://www.apple.com", apple: "pear" }),
        "A <a href=\"http://www.apple.com\">pear</a>",
        "Replacement with link description evaluation"
    );

    t.equal(
        i18n.expand("A {apple_fruit|apple}", { apple_fruit: { href: "http://www.apple.com", target: "_blank" }, apple: "pear" }),
        "A <a href=\"http://www.apple.com\" target=\"_blank\">pear</a>",
        "Replacement with link description evaluation and object argument"
    );

    t.equal(
        i18n.expand("A {apple_fruit|apple}", {
            apple_fruit: "http://www.apple.com",
            apple: "<pears are=\"yellow, green & red\">"
        }),
        "A <a href=\"http://www.apple.com\">&lt;pears are=&quot;yellow, green &amp; red&quot;&gt;</a>",
        "Replacement with HTML-escaped characters"
    );

    t.equal(
        i18n.expand("A {apple_fruit|^(apple|pear)[sz.]?$}", {
            apple_fruit: "http://www.apple.com",
            "^(apple|pear)[sz.]?$": "pear"
        }),
        "A <a href=\"http://www.apple.com\">pear</a>",
        "Replacement with RegExp-escaped characters"
    );
});

test("commaList", function (t) {
    t.plan(5);

    t.equal(commaList([]), "", "empty list");
    t.equal(commaList(["a"]), "a", "list with one item");
    t.equal(commaList(["a", "b"]), "a and b", "list with two items");
    t.equal(commaList(["a", "b", "c"]), "a, b and c", "list with three items");
    t.equal(commaList(["a", "b", "c", "d"]), "a, b, c and d", "list with four items");
});

test("commaOnlyList", function (t) {
    t.plan(5);

    t.equal(commaOnlyList([]), "", "empty list");
    t.equal(commaOnlyList(["a"]), "a", "list with one item");
    t.equal(commaOnlyList(["a", "b"]), "a, b", "list with two items");
    t.equal(commaOnlyList(["a", "b", "c"]), "a, b, c", "list with three items");
    t.equal(commaOnlyList(["a", "b", "c", "d"]), "a, b, c, d", "list with four items");
});

test('Expanding links for React components', function (t) {
    t.plan(1);

    let href = 'http://www.apple.com/';
    let someElement = <span key={'span'}>{'some element'}</span>;

    function toString(children) {
        return ReactDOMServer.renderToStaticMarkup(<div>{children}</div>);
    }

    t.equal(
        toString(i18n.l('An {apple_fruit|Apple}, plus {some_element}', {
            __react: true,
            apple_fruit: href,
            some_element: someElement,
        })),
        toString(['An ', <a href={href} key={href}>{'Apple'}</a>, ', plus ', someElement]),
        'Replacement returns React links'
    );
});
