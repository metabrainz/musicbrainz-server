#!/usr/bin/env node

var helper = require("./test_helper").helper,
    q = helper.QUnit,
    starter = helper.starter;
var inc = require("../../sample/commonjs/lib/incr").increment,
    math = require("../../sample/commonjs/lib/math"),
    add = math.add;

q.module("incr module");
q.test('increment' , function() {
    q.equal(inc(1), 2);
    q.equal(inc(-3), -2);
});

q.module("math module");
q.test('add' , function() {
    q.equal(add(1, 4), 5);
    q.equal(add(-3, 2), -1, '');
    q.equal(add(1, 3, 4), 8, 'passing 3 args');
    q.equal(add(2), 2, 'just one arg');
    q.equal(add(), 0, 'no args');

    q.equal(add(-3, 4), 7);
    q.equal(add(-3, 4), 7, 'with message');

    q.ok(true);
    q.ok(true, 'with message');
    q.ok(false);
    q.ok(false, 'with message');
});

q.module("TAP spec compliance");
q.test('Diagnostic lines' , function() {
    q.ok(true, "with\r\nmultiline\nmessage");
    q.equal("foo\nbar", "foo\r\nbar", "with\r\nmultiline\nmessage");
    q.equal("foo\r\nbar", "foo\nbar", "with\r\nmultiline\nmessage");
});

starter();
