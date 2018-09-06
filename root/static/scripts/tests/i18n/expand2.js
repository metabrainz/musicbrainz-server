import test from 'tape';
import React from 'react';
import expand2, {expand2html} from '../../common/i18n/expand2';

test('expand2', function (t) {
  t.plan(46);

  let error;
  const consoleError = console.error;
  console.error = function () {
    error = arguments[0];
  };

  function expandTest(input, args, output) {
    t.equal(expand2html(input, args), output);
  }

  expandTest('Some plain text', null, 'Some plain text');
  expandTest('Some &quot;plain&quot; text', null, 'Some &quot;plain&quot; text');

  expandTest('An {apple_fruit}', null, 'An {apple_fruit}');
  expandTest('An {apple_fruit}', {apple_fruit: 'apple'}, 'An apple');

  expandTest(
    'An {apple_fruit}',
    {apple_fruit: React.createElement('b', null, 'apple')},
    'An <b>apple</b>',
  );

  expandTest(
    'An &lbrace;apple_fruit&rbrace;',
    {apple_fruit: 'apple'},
    'An {apple_fruit}',
  );

  expandTest(
    'An {apple_fruit|Apple}',
    {apple_fruit: 'http://www.apple.com'},
    'An <a href="http://www.apple.com">Apple</a>',
  );

  expandTest(
    'An <a href="/apple">Apple</a>',
    null,
    'An <a href="/apple">Apple</a>',
  );

  expandTest(
    'A {apple_fruit|darn {apple}}',
    {apple_fruit: 'http://www.apple.com', apple: 'pear'},
    'A <a href="http://www.apple.com">darn pear</a>',
  );

  expandTest(
    'A {apple_fruit|darn {apple}}',
    {apple_fruit: 'http://www.apple.com', apple: React.createElement('i', null, 'pear')},
    'A <a href="http://www.apple.com">darn <i>pear</i></a>',
  );

  expandTest(
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

  expandTest(
    'A {apple_fruit|{apple}}',
    {
      apple_fruit: 'http://www.apple.com',
      apple: '<pears are="yellow, green & red">',
    },
    'A <a href="http://www.apple.com">&lt;pears are=&quot;yellow, green &amp; red&quot;&gt;</a>',
  );

  expandTest(
    'A {apple_fruit|^(apple|pear)[sz.]?$}',
    {apple_fruit: 'http://www.apple.com'},
    'A <a href="http://www.apple.com">^(apple|pear)[sz.]?$</a>',
  );

  expandTest(
    'A {apple_fruit|<b><strong>{prefix} APPLE!</strong></b>}',
    {apple_fruit: 'http://www.apple.com', prefix: 'dang'},
    'A <a href="http://www.apple.com"><b><strong>dang APPLE!</strong></b></a>',
  );

  expandTest('{x:y|}', null, '{x:y|}');
  expandTest('{x:y|}', {x: true}, 'y');
  expandTest('{x:y|}', {x: false}, '');
  expandTest('{x:<b>|</b>|}', {x: true}, '<b>|</b>');

  expandTest('{x:|y}', null, '{x:|y}');
  expandTest('{x:|y}', {x: true}, '');
  expandTest('{x:|y}', {x: false}, 'y');
  expandTest('{x:|%y%}', {x: ''}, 'y');

  expandTest('{x:%|}', {x: ''}, '');
  expandTest('{x:%|}', {x: '%'}, '%');
  expandTest('{x:%|}', {x: '&percnt;'}, '&amp;percnt;');
  expandTest('{x:a%c|}', {x: 'b'}, 'abc');
  expandTest('{x:a&percnt;c|}', {x: 'b'}, 'a%c');

  expandTest('<a href="{x}"></a>', {x: '/&'}, '<a href="/&amp;"></a>');
  expandTest('<a href="{x:%|}"></a>', {x: '/%'}, '<a href="/%"></a>');
  expandTest('<a href="/{x:%|}"></a>', {x: '&percnt;'}, '<a href="/&amp;percnt;"></a>');
  expandTest('<a href="/<{x:&&percnt;|}"></a>', {x: 'b'}, '<a href="/&lt;&amp;%"></a>');

  expandTest('{x:{y|% :)}|{z|:(}}', {x: 'hi', y: 'www'}, '<a href="www">hi :)</a>');
  expandTest(
    '{x:{y|% :)}|{z|<br class="{zz}" />:(}}',
    {x: '', z: 'https://www', zz: '"<>"'},
    '<a href="https://www"><br class="&quot;&lt;&gt;&quot;"/>:(</a>',
  );
  expandTest('{a:%{b:%|}%|}', {a: '0', b: ''}, '00');
  expandTest('{a:%{b:%|}%|}', {a: '0', b: '1'}, '010');
  expandTest(
    '<ul>{a:<li key="0">%</li>{b:<li key="1">%</li>|}|}</ul>',
    {a: '0', b: '1'},
    '<ul><li>0</li><li>1</li></ul>',
  );

  expandTest(
    '<a href="javascript:alert(\'HAx0r\')"></a>',
    null,
    '&lt;a href=&quot;javascript:alert(&#x27;HAx0r&#x27;)&quot;&gt;&lt;/a&gt;',
  );
  t.ok(/bad href value/.test(error));

  expandTest(
    '<script>alert("HAx0r")</script>',
    null,
    '&lt;script&gt;alert(&quot;HAx0r&quot;)&lt;/script&gt;',
  );
  t.ok(/bad HTML tag/.test(error));

  expandTest(
    '<li style="behavior: url(http://hax.0r);"></li>',
    null,
    '&lt;li style=&quot;behavior: url(http://hax.0r);&quot;&gt;&lt;/li&gt;',
  );
  t.ok(/bad HTML attribute/.test(error));

  expandTest(
    '<span style="background-image: url(javascript:alert(\'HAx0r\'))">',
    null,
    '&lt;span style=&quot;background-image: url(javascript:alert(&#x27;HAx0r&#x27;))&quot;&gt;',
  );
  t.ok(/bad HTML attribute/.test(error));

  expandTest(
    '{<script>alert("HAx0r")</script>}',
    null,
    '{&lt;script&gt;alert(&quot;HAx0r&quot;)&lt;/script&gt;}',
  );
  t.ok(/unexpected token/.test(error));

  console.error = consoleError;
});
