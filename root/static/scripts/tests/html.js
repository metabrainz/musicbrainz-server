$(document).ready(function() {
    test('MB object exists', function() {
        ok(MB);
    });

    module('.html');
    test('Module exists', function() {
        ok(MB.html);
    });
    test('Tag functions', function() {
        var tags = [ 'div', 'span', 'input' ];
        expect(tags.length);
        for(var i = 0, tag; tag = tags[i]; i++) {
            ok(MB.html[tag], 'can create ' + tag + ' tags');
        }
    });
    test('Can create empty tags', function() {
        same(MB.html.div(), "<div />");
        same(MB.html.input(), "<input />");
    });
    test('Tags with attributes', function() {
        same(MB.html.span({}), '<span />');
        same(MB.html.span({ id: 'foo' }), '<span id="foo" />');
        same(MB.html.span({ id: 'foo', name: 'woo' }), '<span id="foo" name="woo" />');
    });
    test('Tags with child content', function() {
        same(MB.html.span({}, 'Text'), '<span>Text</span>');
        same(MB.html.span({ id: 'foo' }, 'Text'), '<span id="foo">Text</span>');
        same(MB.html.span({}, MB.html.div({}, 'Text')), '<span><div>Text</div></span>');
    });
});