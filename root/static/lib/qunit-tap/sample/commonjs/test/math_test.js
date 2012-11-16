var q = require("../test_helper").QUnit,
    add = require("../lib/math").add;

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
