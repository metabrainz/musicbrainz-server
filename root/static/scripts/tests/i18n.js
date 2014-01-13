MB.tests.i18n = function () {
    QUnit.module("i18n");

    QUnit.test("MB.i18n.expand", function() {

        QUnit.equal(
            MB.i18n.expand("An {apple_fruit}", { apple_fruit: "apple" }),
            "An apple",
            "Simple replacement"
        );

        QUnit.equal(
            MB.i18n.expand("An {apple_fruit|Apple}", { apple_fruit: "http://www.apple.com" }),
            "An <a href=\"http://www.apple.com\">Apple</a>",
            "Replacement with links"
        );

        QUnit.equal(
            MB.i18n.expand("A {apple_fruit|apple}", { apple_fruit: "http://www.apple.com", apple: "pear" }),
            "A <a href=\"http://www.apple.com\">pear</a>",
            "Replacement with link description evaluation"
        );

        QUnit.equal(
            MB.i18n.expand("A {apple_fruit|apple}", {
                apple_fruit: "http://www.apple.com",
                apple: "<pears are=\"yellow, green & red\">"
            }),
            "A <a href=\"http://www.apple.com\">&lt;pears are=&quot;yellow, green &amp; red&quot;&gt;</a>",
            "Replacement with HTML-escaped characters"
        );

        QUnit.equal(
            MB.i18n.expand("A {apple_fruit|^(apple|pear)[sz.]?$}", {
                apple_fruit: "http://www.apple.com",
                "^(apple|pear)[sz.]?$": "pear"
            }),
            "A <a href=\"http://www.apple.com\">pear</a>",
            "Replacement with RegExp-escaped characters"
        );
    });
};
