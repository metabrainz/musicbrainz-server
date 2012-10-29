var argv = require('optimist').argv,
    qunitVersion = argv.version,
    qunitPath = "../compatibility/" + qunitVersion + "/qunit",
    qunitTap = require("../../lib/qunit-tap").qunitTap,
    util = require("util"),
    assert = require('assert'),
    async = require('async'),
    semver = require('semver'),
    QUnit,
    expected,
    actual = [],
    note = function (str) {},
    log = function (str) {},
    before_1_0_0 = function () {
        return (!semver.valid(qunitVersion) && qunitVersion !== 'stable');
    },
    starter = function () {};

if (argv.verbose) {
    note = function (str) {
        util.puts('# ' + str);
    };
    log = function (str) {
        util.puts('# ' + str);
    };
}

var latestFormat = [
    "# module: incr module",
    "# test: increment",
    "ok 1",
    "ok 2",
    "# module: math module",
    "# test: add",
    "ok 3",
    "ok 4",
    "ok 5 - passing 3 args",
    "ok 6 - just one arg",
    "ok 7 - no args",
    "not ok 8 - expected: '7', got: '1', test: add, module: math module",
    "not ok 9 - with message, expected: '7', got: '1', test: add, module: math module",
    "ok 10",
    "ok 11 - with message",
    "not ok 12 - test: add, module: math module",
    "not ok 13 - with message, test: add, module: math module",
    "# module: TAP spec compliance",
    "# test: Diagnostic lines",
    "ok 14 - with\r\n# multiline\n# message",
    "not ok 15 - with\r\n# multiline\n# message, expected: 'foo\r\n# bar', got: 'foo\n# bar', test: Diagnostic lines, module: TAP spec compliance",
    "not ok 16 - with\r\n# multiline\n# message, expected: 'foo\n# bar', got: 'foo\r\n# bar', test: Diagnostic lines, module: TAP spec compliance",
    "1..16"
];

var midFormat = [
    "# module: incr module",
    "# test: increment",
    "ok 1",
    "ok 2",
    "# module: math module",
    "# test: add",
    "ok 3",
    "ok 4",
    "ok 5 - passing 3 args",
    "ok 6 - just one arg",
    "ok 7 - no args",
    "not ok 8 - expected: '7', got: '1'",
    "not ok 9 - with message, expected: '7', got: '1'",
    "ok 10",
    "ok 11 - with message",
    "not ok 12",
    "not ok 13 - with message",
    "# module: TAP spec compliance",
    "# test: Diagnostic lines",
    "ok 14 - with\r\n# multiline\n# message",
    "not ok 15 - with\r\n# multiline\n# message, expected: 'foo\r\n# bar', got: 'foo\n# bar'",
    "not ok 16 - with\r\n# multiline\n# message, expected: 'foo\n# bar', got: 'foo\r\n# bar'",
    "1..16"
];

var oldFormat = [
    "# module: incr module",
    "# test: increment",
    "ok 1 - okay: 2",
    "ok 2 - okay: -2",
    "# module: math module",
    "# test: add",
    "ok 3 - okay: 5",
    "ok 4 - okay: -1",
    "ok 5 - passing 3 args: 8",
    "ok 6 - just one arg: 2",
    "ok 7 - no args: 0",
    "not ok 8 - failed, expected: 7 result: 1",
    "not ok 9 - with message, expected: 7 result: 1",
    "ok 10",
    "ok 11 - with message",
    "not ok 12",
    "not ok 13 - with message",
    "# module: TAP spec compliance",
    "# test: Diagnostic lines",
    "ok 14 - with\r\n# multiline\n# message",
    "not ok 15 - with\r\n# multiline\n# message, expected: \"foo\r\n# bar\" result: \"foo\n# bar\"",
    "not ok 16 - with\r\n# multiline\n# message, expected: \"foo\n# bar\" result: \"foo\r\n# bar\"",
    "1..16"
];

// require QUnit (in two ways)
if (before_1_0_0() || semver.lt(qunitVersion, '1.3.0')) {
    QUnit = require(qunitPath).QUnit;
} else {
    QUnit = require(qunitPath);
}

// expected output for specific version
if (qunitVersion === '001_two_args') {
    expected = oldFormat;
} else if (before_1_0_0() || semver.lt(qunitVersion, '1.10.0')) {
    expected = midFormat;
} else {
    expected = latestFormat;
}

var outputSpy = function (str) {
    log(str);
    actual.push([str, expected.shift()]);
};

var verifyOutput = function () {
    async.forEach(actual, function (tuple, next){
        try {
            assert.equal(tuple[0], tuple[1]);
            next();
        } catch (e) {
            next(e);
        }
    }, function(err){
        if (err) {
            util.puts('F');
            util.puts(QUnit.tap.explain(err));
        } else  {
            util.print('.');
        }
    });
};

qunitTap(QUnit, outputSpy, {noPlan: true, showSourceOnFailure: false});

// register verifyOutput function
if (before_1_0_0()) {
    QUnit.done = verifyOutput;
} else {
    QUnit.done(verifyOutput);
}

QUnit.init();

if (QUnit.config !== undefined) {
    QUnit.config.updateRate = 0;
}

// starter function (required before 1.3.0)
if (before_1_0_0() || semver.lt(qunitVersion, '1.3.0')) {
    starter = function () {
        QUnit.start();
    };
}

exports.helper = {
    QUnit: QUnit,
    starter: starter
};
