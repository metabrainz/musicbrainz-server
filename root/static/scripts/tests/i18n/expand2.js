import test from 'tape';
import React from 'react';

import expand2, {expand2html} from '../../common/i18n/expand2';

test('expand2', function (t) {
  t.plan(50);

  let error;
  const consoleError = console.error;
  console.error = function () {
    error = arguments[0];
  };

  function expandText(input, args, output) {
    t.equal(expand2(input, args), output);
  }

  function expandHtml(input, args, output) {
    t.equal(expand2html(input, args), output);
  }

  expandText('', null, '');
  expandText(null, null, '');
  expandText(undefined, null, '');
  expandText('Some plain text', null, 'Some plain text');
  expandText('Some &quot;plain&quot; text', null, 'Some "plain" text');
  expandText('An {apple_fruit}', null, 'An {apple_fruit}');
  expandText('An {apple_fruit}', {apple_fruit: 'apple'}, 'An apple');
  expandText('A {number}', {number: 1}, 'A 1');

  expandHtml(
    'An {apple_fruit}',
    {apple_fruit: React.createElement('b', null, 'apple')},
    'An <b>apple</b>',
  );

  expandText(
    'An &lbrace;apple_fruit&rbrace;',
    {apple_fruit: 'apple'},
    'An {apple_fruit}',
  );

  expandHtml(
    'An {apple_fruit|Apple}',
    {apple_fruit: 'http://www.apple.com'},
    'An <a href="http://www.apple.com">Apple</a>',
  );

  expandHtml(
    'An <a href="/apple">Apple</a>',
    null,
    'An <a href="/apple">Apple</a>',
  );

  expandHtml(
    'A {apple_fruit|darn {apple}}',
    {apple_fruit: 'http://www.apple.com', apple: 'pear'},
    'A <a href="http://www.apple.com">darn pear</a>',
  );

  expandHtml(
    'A {apple_fruit|darn {apple}}',
    {apple_fruit: 'http://www.apple.com', apple: React.createElement('i', null, 'pear')},
    'A <a href="http://www.apple.com">darn <i>pear</i></a>',
  );

  expandHtml(
    'A {apple_fruit|{apple}}',
    {
      apple_fruit: {
        className: 'link',
        href: 'http://www.apple.com',
        target: '_blank',
      },
      apple: 'pear',
    },
    'A <a class="link" href="http://www.apple.com" target="_blank">pear</a>',
  );

  expandHtml(
    'A {apple_fruit|{apple}}',
    {
      apple_fruit: 'http://www.apple.com',
      apple: '<pears are="yellow, green & red">',
    },
    'A <a href="http://www.apple.com">&lt;pears are=&quot;yellow, green &amp; red&quot;&gt;</a>',
  );

  expandHtml(
    'A {apple_fruit|^(apple|pear)[sz.]?$}',
    {apple_fruit: 'http://www.apple.com'},
    'A <a href="http://www.apple.com">^(apple|pear)[sz.]?$</a>',
  );

  expandHtml(
    'A {apple_fruit|<b><strong>{prefix} APPLE!</strong></b>}',
    {apple_fruit: 'http://www.apple.com', prefix: 'dang'},
    'A <a href="http://www.apple.com"><b><strong>dang APPLE!</strong></b></a>',
  );

  expandText('{x:y|}', null, '{x:y|}');
  expandText('{x:y|}', {x: true}, 'y');
  expandText('{x:y|}', {x: false}, '');
  expandHtml('{x:<b>|</b>|}', {x: true}, '<b>|</b>');

  expandText('{x:|y}', null, '{x:|y}');
  expandText('{x:|y}', {x: true}, '');
  expandText('{x:|y}', {x: false}, 'y');
  expandText('{x:|%y%}', {x: ''}, 'y');

  expandText('{x:%|}', {x: ''}, '');
  expandText('{x:%|}', {x: '%'}, '%');
  expandText('{x:%|}', {x: '&percnt;'}, '&percnt;');
  expandText('{x:a%c|}', {x: 'b'}, 'abc');
  expandText('{x:a&percnt;c|}', {x: 'b'}, 'a%c');

  expandHtml('<a href="{x}"></a>', {x: '/&'}, '<a href="/&amp;"></a>');
  expandHtml('<a href="{x:%|}"></a>', {x: '/%'}, '<a href="/%"></a>');
  expandHtml('<a href="/{x:%|}"></a>', {x: '&percnt;'}, '<a href="/&amp;percnt;"></a>');
  expandHtml('<a href="/<{x:&&percnt;|}"></a>', {x: 'b'}, '<a href="/&lt;&amp;%"></a>');

  expandHtml('{x:{y|% :)}|{z|:(}}', {x: 'hi', y: 'www'}, '<a href="www">hi :)</a>');
  expandHtml(
    '{x:{y|% :)}|{z|<br class="{zz}" />:(}}',
    {x: '', z: 'https://www', zz: '"<>"'},
    '<a href="https://www"><br class="&quot;&lt;&gt;&quot;"/>:(</a>',
  );
  expandText('{a:%{b:%|}%|}', {a: '0', b: ''}, '00');
  expandText('{a:%{b:%|}%|}', {a: '0', b: '1'}, '010');
  expandHtml(
    '<ul>{a:<li key="0">%</li>{b:<li key="1">%</li>|}|}</ul>',
    {a: '0', b: '1'},
    '<ul><li>0</li><li>1</li></ul>',
  );

  expandHtml(
    '<a href="javascript:alert(\'HAx0r\')"></a>',
    null,
    '&lt;a href=&quot;javascript:alert(&#x27;HAx0r&#x27;)&quot;&gt;&lt;/a&gt;',
  );
  t.ok(/bad href value/.test(error));

  expandHtml(
    '<script>alert("HAx0r")</script>',
    null,
    '&lt;script&gt;alert(&quot;HAx0r&quot;)&lt;/script&gt;',
  );
  t.ok(/bad HTML tag/.test(error));

  expandHtml(
    '<li style="behavior: url(http://hax.0r);"></li>',
    null,
    '&lt;li style=&quot;behavior: url(http://hax.0r);&quot;&gt;&lt;/li&gt;',
  );
  t.ok(/bad HTML attribute/.test(error));

  expandHtml(
    '<span style="background-image: url(javascript:alert(\'HAx0r\'))">',
    null,
    '&lt;span style=&quot;background-image: url(javascript:alert(&#x27;HAx0r&#x27;))&quot;&gt;',
  );
  t.ok(/bad HTML attribute/.test(error));

  expandHtml(
    '{<script>alert("HAx0r")</script>}',
    null,
    '{&lt;script&gt;alert(&quot;HAx0r&quot;)&lt;/script&gt;}',
  );
  t.ok(/unexpected token/.test(error));

  console.error = consoleError;
});
