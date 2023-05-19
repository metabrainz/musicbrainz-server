/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as ReactDOMServer from 'react-dom/server';
import test from 'tape';

import formatUserDate from '../../../utility/formatUserDate.js';
import {
  EMPTY_PARTIAL_DATE,
} from '../common/constants.js';
import areDatesEqual from '../common/utility/areDatesEqual.js';
import compareDates, {
  compareDatePeriods,
} from '../common/utility/compareDates.js';
import formatDate from '../common/utility/formatDate.js';
import formatDatePeriod from '../common/utility/formatDatePeriod.js';
import formatSetlist from '../common/utility/formatSetlist.js';
import * as fullwidthLatin from '../edit/utility/fullwidthLatin.js';
import isShortenedUrl from '../edit/utility/isShortenedUrl.js';

test('areDatesEqual', function (t) {
  t.plan(7);

  const date1 = {year: 2000, month: 1, day: 1};
  const date2 = {year: 2000, month: 11, day: 1};

  t.ok(areDatesEqual(null, null));
  t.ok(areDatesEqual(EMPTY_PARTIAL_DATE, null));
  t.ok(areDatesEqual(null, EMPTY_PARTIAL_DATE));
  t.ok(areDatesEqual(EMPTY_PARTIAL_DATE, EMPTY_PARTIAL_DATE));
  t.ok(areDatesEqual(date1, date1));
  t.ok(areDatesEqual(date2, date2));
  t.ok(!areDatesEqual(date1, date2));
});

test('compareDates', function (t) {
  t.plan(7);

  t.ok(compareDates(null, null) === 0);
  t.ok(compareDates({}, {}) === 0);
  t.ok(compareDates(null, {}) === 0);
  t.ok(compareDates({}, null) === 0);

  const sortedDates = [
    null,
    {day: 1},
    {day: 2},
    {month: 1},
    {month: 1, day: 1},
    {month: 1, day: 2},
    {month: 2},
    {month: 2, day: 1},
    {month: 2, day: 2},
    {year: 0},
    {year: 0, day: 1},
    {year: 0, day: 2},
    {year: 0, month: 1},
    {year: 0, month: 1, day: 1},
    {year: 0, month: 1, day: 2},
    {year: 0, month: 2},
    {year: 0, month: 2, day: 1},
    {year: 0, month: 2, day: 2},
    {year: 2000},
    {year: 2000, day: 1},
    {year: 2000, day: 2},
    {year: 2000, month: 1},
    {year: 2000, month: 1, day: 1},
    {year: 2000, month: 1, day: 2},
    {year: 2000, month: 2},
    {year: 2000, month: 2, day: 1},
    {year: 2000, month: 2, day: 2},
  ];

  let copy = sortedDates.slice(0)
    .sort((a, b) => (a?.year ?? 0) - (b?.year ?? 0));
  copy.sort(compareDates);
  t.deepEqual(copy, sortedDates);

  copy = sortedDates.slice(0)
    .sort((a, b) => (a?.month ?? 0) - (b?.month ?? 0));
  copy.sort(compareDates);
  t.deepEqual(copy, sortedDates);

  copy = sortedDates.slice(0)
    .sort((a, b) => (a?.day ?? 0) - (b?.day ?? 0));
  copy.sort(compareDates);
  t.deepEqual(copy, sortedDates);
});

test('compareDatePeriods', function (t) {
  t.plan(9);

  t.ok(compareDatePeriods(
    null,
    {begin_date: {year: 0}, end_date: {year: 0}, ended: true},
  ) < 0, 'null date periods sort before non-null ones');

  t.ok(compareDatePeriods(
    null,
    {},
  ) === 0, 'empty date period objects are considered null');

  t.ok(compareDatePeriods(
    {
      begin_date: {month: 12, day: 1},
      end_date: {month: 1, day: 1},
      ended: true,
    },
    {
      begin_date: {month: 1, day: 1},
      end_date: {month: 1, day: 1},
      ended: true,
    },
  ) > 0, 'date periods without years are sorted by month, day');

  t.ok(compareDatePeriods(
    {
      begin_date: {month: 1, day: 1},
      end_date: {month: 1, day: 1},
      ended: true,
    },
    {
      begin_date: {month: 1, day: 1},
      end_date: {month: 12, day: 1},
      ended: true,
    },
  ) < 0, 'date periods without years are sorted by month, day');

  t.ok(compareDatePeriods(
    {begin_date: {month: 12, day: 1}, end_date: {year: 1977}, ended: true},
    {begin_date: {month: 1, day: 1}, end_date: {year: 2001}, ended: true},
  ) < 0, 'date periods with no begin years are sorted by end years');

  t.ok(compareDatePeriods(
    {begin_date: {day: 12}, end_date: {month: 1}, ended: true},
    {begin_date: {day: 1}, end_date: {month: 12}, ended: true},
  ) < 0, 'date periods with no begin months are sorted by end months');

  t.ok(compareDatePeriods(
    {begin_date: null, end_date: {day: 12}, ended: true},
    {begin_date: null, end_date: {day: 1}, ended: true},
  ) > 0, 'date periods with only end days are sorted');

  t.ok(compareDatePeriods(
    {
      begin_date: {month: 12, day: 1},
      end_date: {year: 1977},
      ended: true,
    },
    {
      begin_date: {month: 1, day: 1},
      end_date: {month: 1, day: 1},
      ended: true,
    },
  ) > 0, 'date periods with null years are sorted before ones with years');

  t.ok(compareDatePeriods(
    {begin_date: null, end_date: null, ended: true},
    {begin_date: null, end_date: null, ended: false},
  ) < 0, 'ended date periods are sorted before non-ended ones');
});

test('formatDate', function (t) {
  t.plan(13);

  t.equal(formatDate(null), '');
  t.equal(formatDate(undefined), '');
  t.equal(formatDate({}), '');
  t.equal(formatDate({year: 0}), '0000');
  t.equal(formatDate({year: 1999}), '1999');
  t.equal(formatDate({year: 1999, month: 1}), '1999-01');
  t.equal(formatDate({year: 1999, month: 1, day: 1}), '1999-01-01');
  t.equal(formatDate({year: 1999, day: 1}), '1999-??-01');
  t.equal(formatDate({month: 1}), '????-01');
  t.equal(formatDate({month: 1, day: 1}), '????-01-01');
  t.equal(formatDate({day: 1}), '????-??-01');
  t.equal(formatDate({year: 0, month: 1, day: 1}), '0000-01-01');
  t.equal(formatDate({year: -1, month: 1, day: 1}), '-0001-01-01');
});

test('formatDatePeriod', function (t) {
  t.plan(8);

  var a = {year: 1999};
  var b = {year: 2000};

  t.equal(
    formatDatePeriod({begin_date: a, end_date: a, ended: false}),
    '1999',
  );
  t.equal(
    formatDatePeriod({begin_date: a, end_date: a, ended: true}),
    '1999',
  );

  t.equal(
    formatDatePeriod({begin_date: a, end_date: b, ended: false}),
    '1999 \u2013 2000',
  );
  t.equal(
    formatDatePeriod({begin_date: a, end_date: b, ended: true}),
    '1999 \u2013 2000',
  );

  t.equal(
    formatDatePeriod({begin_date: {}, end_date: b, ended: false}),
    '\u2013 2000',
  );
  t.equal(
    formatDatePeriod({begin_date: {}, end_date: b, ended: true}),
    '\u2013 2000',
  );

  t.equal(
    formatDatePeriod({begin_date: a, end_date: {}, ended: false}),
    '1999 \u2013',
  );
  t.equal(
    formatDatePeriod({begin_date: a, end_date: {}, ended: true}),
    '1999 \u2013 ????',
  );
});


test('fullwidthLatin', function (t) {
  t.plan(17);

  t.equal(
    fullwidthLatin.hasFullwidthLatin(undefined),
    false,
    'undefined has no fullwidth Latin',
  );
  t.equal(
    fullwidthLatin.fromFullwidthLatin(undefined),
    '',
    'undefined (fromFullwidthLatin) empty',
  );
  t.equal(
    fullwidthLatin.toFullwidthLatin(undefined),
    '',
    'undefined (toFullwidthLatin) empty',
  );

  t.equal(
    fullwidthLatin.hasFullwidthLatin(null),
    false,
    'null has no fullwidth Latin',
  );
  t.equal(
    fullwidthLatin.fromFullwidthLatin(null),
    '',
    'null (fromFullwidthLatin) empty',
  );
  t.equal(
    fullwidthLatin.toFullwidthLatin(null),
    '',
    'null (toFullwidthLatin) empty',
  );

  t.equal(
    fullwidthLatin.hasFullwidthLatin(''),
    false,
    'empty has no fullwidth Latin',
  );
  t.equal(
    fullwidthLatin.fromFullwidthLatin(''),
    '',
    'empty (fromFullwidthLatin) empty',
  );
  t.equal(
    fullwidthLatin.toFullwidthLatin(''),
    '',
    'empty (toFullwidthLatin) empty',
  );

  t.equal(
    fullwidthLatin.hasFullwidthLatin('　ｆｅａｔ．　'),
    true,
    'fully fullwidth Latin has fullwidth Latin',
  );
  t.equal(
    fullwidthLatin.hasFullwidthLatin(' ｆｅａｔ. '),
    true,
    'fullwidth Latin letters are fullwidth Latin',
  );
  t.equal(
    fullwidthLatin.hasFullwidthLatin('　feat.　'),
    true,
    'ideographic space is fullwidth Latin',
  );
  t.equal(
    fullwidthLatin.hasFullwidthLatin(' feat． '),
    true,
    'fullwidth full stop is fullwidth Latin',
  );
  t.equal(
    fullwidthLatin.fromFullwidthLatin('　ｆｅａｔ．　'),
    ' feat. ',
    'fully converted fromFullwidthLatin',
  );
  t.equal(
    fullwidthLatin.fromFullwidthLatin(' ｆｅａｔ. '),
    ' feat. ',
    'partly converted fromFullwidthLatin',
  );
  t.equal(
    fullwidthLatin.toFullwidthLatin('　feat．　'),
    '　ｆｅａｔ．　',
    'partly converted toFullwidthLatin',
  );
  t.equal(
    fullwidthLatin.toFullwidthLatin(' feat. '),
    '　ｆｅａｔ．　',
    'fully converted toFullwidthLatin',
  );
});

test('formatUserDate', function (t) {
  t.plan(1);

  t.equal(
    formatUserDate(
      {
        stash: {current_language: 'en'},
        user: {
          preferences: {
            datetime_format: '%Y-%m-%d %H:%M %Z',
            timezone: 'Africa/Cairo',
          },
        },
      },
      '2021-05-12T22:05:05.640Z',
    ),
    '2021-05-13 00:05 GMT+2',
    '%H ranges from 00-23',
  );
});

test('formatSetlist', function (t) {
  t.plan(1);

  const setlist =
    '@ pre-text [e1af2f0d-c685-4e83-a27d-b27e79787aab|artist 1] mid-text ' +
      '[0eda70b7-c77b-4775-b1db-5b0e5a3ca4c1|artist 2 (:v&#93;&#x5d;&rsqb;&rbrack;] post-text\n\r\n' +
    '* e [b831b5a4-e1a9-4516-bb50-b6eed446fc9b|work 1] [not a link]\r' +
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

test('isShortenedUrl', function (t) {
  t.plan(17);

  t.ok(isShortenedUrl('https://su.pr/example'));
  t.ok(isShortenedUrl('https://t.co/example'));
  t.ok(isShortenedUrl('https://bit.ly/example'));
  t.ok(isShortenedUrl('http://example.su.pr'));
  t.ok(isShortenedUrl('http://example.t.co'));
  t.ok(isShortenedUrl('http://example.bit.ly'));

  // Allowed host-only shorteners
  t.ok(!isShortenedUrl('https://example.bruit.app/'));
  t.ok(!isShortenedUrl('https://example.distrokid.com'));
  t.ok(!isShortenedUrl('https://example.trac.co'));

  t.ok(isShortenedUrl('https://bruit.app/abc'));
  t.ok(isShortenedUrl('https://example.distrokid.com/abc'));
  t.ok(isShortenedUrl('https://example.trac.co/abc'));

  // MBS-12566
  t.ok(!isShortenedUrl('https://surprisechef.bandcamp.com' +
                       '/album/velodrome-b-w-springs-theme'));
  t.ok(!isShortenedUrl('https://t.co.example'));
  t.ok(!isShortenedUrl('https://taco.example'));
  t.ok(!isShortenedUrl('https://bit.ly.example'));
  t.ok(!isShortenedUrl('https://bitaly.example'));
});
