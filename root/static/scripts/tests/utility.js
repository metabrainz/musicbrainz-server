/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as ReactDOMServer from 'react-dom/server';
import test from 'tape';

import formatDate from '../common/utility/formatDate.js';
import * as age from '../../../utility/age.js';
import formatUserDate from '../../../utility/formatUserDate.js';
import compareDates, {
  compareDatePeriods,
} from '../common/utility/compareDates.js';
import formatDatePeriod from '../common/utility/formatDatePeriod.js';
import formatSetlist from '../common/utility/formatSetlist.js';
import formatTrackLength from '../common/utility/formatTrackLength.js';
import parseDate from '../common/utility/parseDate.js';
import * as dates from '../edit/utility/dates.js';
import * as fullwidthLatin from '../edit/utility/fullwidthLatin.js';

test('age', function (t) {
  t.plan(11);

  t.deepEqual(age.age({
    begin_date: {year: 1976, month: 7, day: 23},
    end_date: {year: 1976, month: 7, day: 24},
    ended: true,
  }), [0, 0, 1], 'age is 1 day');

  t.deepEqual(age.age({
    begin_date: {year: 1976, month: 7, day: 23},
    end_date: {year: 1976, month: 8, day: 1},
    ended: true,
  }), [0, 0, 9], 'age is 9 days');

  t.deepEqual(age.age({
    begin_date: {year: 1976, month: 7, day: 23},
    end_date: {year: 1976, month: 11, day: 1},
    ended: true,
  }), [0, 3, 9], 'age is 3 months');

  t.deepEqual(age.age({
    begin_date: {year: 1553, month: 7, day: 23},
    end_date: {year: 1976, month: 11, day: 1},
    ended: true,
  }), [423, 3, 9], 'age is 423 years');

  t.deepEqual(age.age({
    begin_date: {year: 1553, month: 7, day: 23},
    end_date: {year: 2140, month: 11, day: 1},
    ended: true,
  }), [587, 3, 9], 'age is 587 years');

  t.deepEqual(age.age({
    begin_date: {year: 2008, month: 2, day: 29},
    end_date: {year: 2009, month: 2, day: 1},
    ended: true,
  }), [0, 11, 3], 'age is 11 months');

  t.deepEqual(age.age({
    begin_date: {
      year: (new Date()).getFullYear() - 24,
      month: null,
      day: null,
    },
    end_date: null,
    ended: false,
  })[0], 24, 'age is 24 years');

  t.deepEqual(age.age({
    begin_date: {year: 2010, month: null, day: null},
    end_date: {year: 2012, month: null, day: null},
    ended: true,
  }), [2, 0, 0], 'age with partial dates is 2 years');

  t.deepEqual(age.age({
    begin_date: {year: 2010, month: null, day: null},
    end_date: {year: 2012, month: 12, day: null},
    ended: true,
  }), [2, 11, 0], 'age with partial dates is 2 years, 11 months');

  t.deepEqual(age.age({
    begin_date: {year: 2010, month: 12, day: null},
    end_date: {year: 2012, month: 1, day: null},
    ended: true,
  }), [1, 1, 0], 'age with partial dates is 1 year, 1 month');

  t.deepEqual(age.age({
    begin_date: {year: 2010, month: 12, day: 31},
    end_date: {year: 2012, month: 1, day: null},
    ended: true,
  }), [1, 0, 1], 'age with partial dates is 1 year, 1 day');
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

test('hasAge', function (t) {
  t.plan(4);

  const entity = {
    begin_date: {year: 1970, month: 1, day: 1},
    end_date: {year: null, month: 1, day: 1},
    ended: true,
  };
  t.ok(!age.hasAge(entity), 'no age for ended artist without end year');

  // testing hasAge with negative years
  entity.begin_date = {year: 551, month: 9, day: 28};
  entity.end_date = {year: 479, month: 4, day: 11};
  t.ok(!age.hasAge(entity), 'no age for artists with negative years');

  // testing hasAge with future begin dates
  entity.begin_date = {year: 9998, month: 9, day: 28};
  entity.end_date = {year: 9999, month: 4, day: 11};
  t.ok(!age.hasAge(entity), 'no age for artists with future begin dates');

  // testing hasAge when the begin date is more specific than the end date
  entity.begin_date = {year: 1987, month: 3, day: 7};
  entity.end_date = {year: 1987, month: null, day: null};
  t.ok(
    !age.hasAge(entity),
    'no age for artists with more specific begin than end dates',
  );
});

test('formatTrackLength', function (t) {
  t.plan(6);

  var seconds = 1000;
  var minutes = 60 * seconds;
  var hours = 60 * minutes;

  t.equal(formatTrackLength(23), '23 ms', 'formatTrackLength');
  t.equal(formatTrackLength(260586), '4:21', 'formatTrackLength');
  t.equal(formatTrackLength(23 * seconds), '0:23', 'formatTrackLength');
  t.equal(formatTrackLength(59 * minutes), '59:00', 'formatTrackLength');
  t.equal(formatTrackLength(60 * minutes), '1:00:00', 'formatTrackLength');
  t.equal(
    formatTrackLength(14 * hours + 15 * minutes + 16 * seconds),
    '14:15:16',
    'formatTrackLength',
  );
});

test('parseDate', function (t) {
  t.plan(16);

  var parseDateTests = [
    {date: '', expected: {year: null, month: null, day: null}},
    {date: '0000', expected: {year: 0, month: null, day: null}},
    {date: '1999-01-02', expected: {year: 1999, month: 1, day: 2}},
    {date: '1999-01', expected: {year: 1999, month: 1, day: null}},
    {date: '1999', expected: {year: 1999, month: null, day: null}},
    {date: '????-01-02', expected: {year: null, month: 1, day: 2}},
    {date: '????-??-02', expected: {year: null, month: null, day: 2}},
    {date: '1999-??-02', expected: {year: 1999, month: null, day: 2}},

    // Relationship editor seeding format (via URL query params).
    {date: '-----', expected: {year: null, month: null, day: null}},
    {date: '----02', expected: {year: null, month: null, day: 2}},
    {date: '--01--', expected: {year: null, month: 1, day: null}},
    {date: '--01-02', expected: {year: null, month: 1, day: 2}},
    {date: '1999--', expected: {year: 1999, month: null, day: null}},
    {date: '1999----', expected: {year: 1999, month: null, day: null}},
    {date: '1999---02', expected: {year: 1999, month: null, day: 2}},
    {date: '1999-01--', expected: {year: 1999, month: 1, day: null}},
  ];

  for (const test of parseDateTests) {
    const result = parseDate(test.date);
    t.deepEqual(result, test.expected, test.date);
  }
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

test('validDate', function (t) {
  t.plan(14);

  t.equal(dates.isDateValid('', '', ''), true, 'all empty strings are valid');
  t.equal(
    dates.isDateValid(undefined, undefined, undefined),
    true,
    'all undefined values are valid',
  );
  t.equal(
    dates.isDateValid(null, null, null),
    true,
    'all null values are valid',
  );
  t.equal(dates.isDateValid(2000), true, 'just a year is valid');
  t.equal(dates.isDateValid('', 10), true, 'just a month is valid');
  t.equal(dates.isDateValid('', '', 29), true, 'just a day is valid');
  t.equal(dates.isDateValid(0), false, 'the year 0 is invalid');
  t.equal(dates.isDateValid('', 13), false, 'months > 12 are invalid');
  t.equal(dates.isDateValid('', '', 32), false, 'days > 31 are invalid');
  t.equal(dates.isDateValid(2001, 2, 29), false, '2001-02-29 is invalid');
  t.equal(dates.isDateValid('2000f'), false, 'letters are invalid');
  t.equal(
    dates.isDateValid(1960, 2, 29),
    true,
    'leap years are handled correctly (MBS-5663)',
  );
  t.equal(
    dates.isDateValid(null, null, 10),
    true,
    'just a day with nulls is valid',
  );
  t.equal(
    dates.isDateValid(2010, null, 10),
    true,
    'just a day and year with null month is valid',
  );
});

test('validDatePeriod', function (t) {
  t.plan(8);

  var tests = [
    {
      a: {},
      b: {},
      expected: true,
    },
    {
      a: {year: 2000, month: null, day: 11},
      b: {year: 2000, month: null, day: 10},
      expected: true,
    },
    {
      a: {year: 2000, month: 11, day: 11},
      b: {year: 2000, month: 12, day: 12},
      expected: true,
    },
    {
      a: {year: 2000, month: 11, day: 11},
      b: {year: 1999, month: 12, day: 12},
      expected: false,
    },
    {
      a: {year: 2000, month: 11, day: 11},
      b: {year: 2000, month: 10, day: 12},
      expected: false,
    },
    {
      a: {year: 2000, month: 11, day: 11},
      b: {year: 2000, month: 11, day: 10},
      expected: false,
    },
    {
      a: {year: '2000', month: '3', day: '1'},
      b: {year: '2000', month: '10', day: '1'},
      expected: true,
    },
    {
      a: {year: 1961, month: 2, day: 28},
      b: {year: 1961, month: 2, day: 29},
      expected: false,
    },
  ];

  for (const test of tests) {
    t.equal(dates.isDatePeriodValid(test.a, test.b), test.expected);
  }
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
      '[0eda70b7-c77b-4775-b1db-5b0e5a3ca4c1|artist 2] post-text\n\r\n' +
    '* e [b831b5a4-e1a9-4516-bb50-b6eed446fc9b|work 1] [not a link]\r' +
    '@ plain text artist\n' +
    '# comment [b831b5a4-e1a9-4516-bb50-b6eed446fc9b|not a link]\r\n' +
    '# comment <a href="#">also not a link</a>\r\n' +
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
      '<a href="/artist/0eda70b7-c77b-4775-b1db-5b0e5a3ca4c1">artist 2</a>' +
    '</strong> post-text<br/><br/>' +
    'e <a href="/work/b831b5a4-e1a9-4516-bb50-b6eed446fc9b">work 1</a> ' +
      '[not a link]<br/>' +
    '<strong>Artist: ' +
    'plain text artist' +
    '</strong><br/>' +
    '<span class="comment">' +
      'comment [b831b5a4-e1a9-4516-bb50-b6eed446fc9b|not a link]' +
    '</span><br/>' +
    '<span class="comment">' +
      'comment &lt;a href=&quot;#&quot;&gt;also not a link&lt;/a&gt;' +
    '</span><br/>' +
    '<strong>Artist: ' +
    'nor a link &lt;a href=&quot;#&quot;&gt;here&lt;/a&gt;' +
    '</strong><br/>' +
    'plain text work<br/><br/><br/>',
  );
});
