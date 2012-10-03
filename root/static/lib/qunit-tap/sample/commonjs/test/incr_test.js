var q = require("../test_helper").QUnit,
    inc = require("../lib/incr").increment;

q.module("incr module");

q.test('increment' , function() {
    q.equal(inc(1), 2);
    q.equal(inc(-3), -2);
});
