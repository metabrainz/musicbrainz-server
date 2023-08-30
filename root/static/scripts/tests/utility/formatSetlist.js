/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as ReactDOMServer from 'react-dom/server';
import test from 'tape';

import formatSetlist from '../../common/utility/formatSetlist.js';

test('formatSetlist', function (t) {
  t.plan(1);

  const setlist =
    '@ pre-text [e1af2f0d-c685-4e83-a27d-b27e79787aab|artist 1] mid-text ' +
      '[0eda70b7-c77b-4775-b1db-5b0e5a3ca4c1|artist 2 (:v&#93;&#x5d;&rsqb;&rbrack;] post-text\n\r\n' +
    '* e [b831b5a4-e1a9-4516-bb50-b6eed446fc9b|work 1] [not a link]\r' +
    '* e [b831b5a4-e1a9-4516-bb50-b6eed446fc9c]\r' +
    '@ plain text artist &lbrack;&lsqb;&#x5b;&#91;v:)\n' +
    '# comment [b831b5a4-e1a9-4516-bb50-b6eed446fc9b|not a link]\r\n' +
    '# comment <a href="#">also not a link</a> &#38;amp; &amp;rsqb;\r\n' +
    '@ nor a link <a href="#">here</a>\n\r' +
    '* plain text work\n' +
    'ignored!\r\n';

  t.equal(
    ReactDOMServer.renderToStaticMarkup(formatSetlist(setlist)),
    '<!-- -->' + // empty comment added by React
    'pre-text <strong>' +
      'Artist: ' +
      '<a href="/artist/e1af2f0d-c685-4e83-a27d-b27e79787aab">artist 1</a>' +
    '</strong> mid-text ' +
    '<strong>Artist: ' +
      '<a href="/artist/0eda70b7-c77b-4775-b1db-5b0e5a3ca4c1">artist 2 (:v]]]]</a>' +
    '</strong> post-text<br/><br/>' +
    'e <a href="/work/b831b5a4-e1a9-4516-bb50-b6eed446fc9b">work 1</a> ' +
      '[not a link]<br/>' +
    'e <a href="/work/b831b5a4-e1a9-4516-bb50-b6eed446fc9c">work:b831b5a4-e1a9-4516-bb50-b6eed446fc9c</a><br/>' +
    '<strong>Artist: ' +
    'plain text artist [[[[v:)' +
    '</strong><br/>' +
    '<span class="comment">' +
      'comment [b831b5a4-e1a9-4516-bb50-b6eed446fc9b|not a link]' +
    '</span><br/>' +
    '<span class="comment">' +
      'comment &lt;a href=&quot;#&quot;&gt;also not a link&lt;/a&gt; &amp;amp; &amp;rsqb;' +
    '</span><br/>' +
    '<strong>Artist: ' +
    'nor a link &lt;a href=&quot;#&quot;&gt;here&lt;/a&gt;' +
    '</strong><br/>' +
    'plain text work<br/><br/><br/>',
  );
});
