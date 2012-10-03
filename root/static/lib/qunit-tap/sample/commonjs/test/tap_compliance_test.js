var q = require("../test_helper").QUnit;

q.module("TAP spec compliance");

q.test('Diagnostic lines' , function() {
    q.ok(true, "with\r\nmultiline\nmessage");
    q.equal("foo\nbar", "foo\r\nbar", "with\r\nmultiline\nmessage");
    q.equal("foo\r\nbar", "foo\nbar", "with\r\nmultiline\nmessage");
});
