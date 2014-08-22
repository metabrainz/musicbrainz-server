// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

module('utility');


test('All', function () {

    var input = "ＭｕｓｉｃＢｒａｉｎｚ！～２０１１";
    var expected = "MusicBrainz!~2011";
    equal(MB.utility.fullWidthConverter(input),
                  expected, "fullWidthConverter (" + input + ")");

    var seconds = 1000;
    var minutes = 60 * seconds;
    var hours = 60 * minutes;

    equal(MB.utility.formatTrackLength(23), '23 ms', 'formatTrackLength');
    equal(MB.utility.formatTrackLength(260586), '4:21', 'formatTrackLength');
    equal(MB.utility.formatTrackLength(23 * seconds), '0:23', 'formatTrackLength');
    equal(MB.utility.formatTrackLength(59 * minutes), '59:00', 'formatTrackLength');
    equal(MB.utility.formatTrackLength(60 * minutes), '1:00:00', 'formatTrackLength');
    equal(MB.utility.formatTrackLength(14 * hours + 15 * minutes + 16 * seconds), '14:15:16', 'formatTrackLength');

    equal(MB.utility.unformatTrackLength('?:??'), null, 'MBS-5086: unformatTrackLength(?:??) should be null');
    equal(MB.utility.unformatTrackLength('23 ms'), 23, 'unformatTrackLength');
    equal(MB.utility.unformatTrackLength('00:23'), 23 * seconds, 'unformatTrackLength');
    equal(MB.utility.unformatTrackLength(':57'), 57 * seconds, 'MBS-3352: Handle the case of ":57"');
    equal(MB.utility.unformatTrackLength('59:00'), 59 * minutes, 'unformatTrackLength');
    equal(MB.utility.unformatTrackLength('01:00:00'), 60 * minutes, 'unformatTrackLength');
    equal(MB.utility.unformatTrackLength('14:15:16'), 14 * hours + 15 * minutes + 16 * seconds, 'unformatTrackLength');

    var parseDateTests = [
        { date: "", expected: { year: null, month: null, day: null} },
        { date: "1999-01-02", expected: { year: 1999, month: 1, day: 2 } },
        { date: "1999-01", expected: { year: 1999, month: 1, day: null } },
        { date: "1999", expected: { year: 1999, month: null, day: null } },
        { date: "????-01-02", expected: { year: null, month: 1, day: 2 } },
        { date: "????-??-02", expected: { year: null, month: null, day: 2 } },
        { date: "1999-??-02", expected: { year: 1999, month: null, day: 2 } }
    ];

    $.each(parseDateTests, function (i, test) {
        var result = MB.utility.parseDate(test.date);
        deepEqual(result, test.expected, test.date);
    });
});


test('filesize.js wrapper', function () {

    equal(MB.utility.filesize(857372), "837.3KB");
    equal(MB.utility.filesize(1235783), "1.2MB");
    equal(MB.utility.filesize(7440138), "7.1MB");
    equal(MB.utility.filesize(2379302), "2.3MB");
    equal(MB.utility.filesize(159985050), "152.5MB");

});


test("formatDate", function () {
    equal(MB.utility.formatDate({}), "");
    equal(MB.utility.formatDate({ year: 0 }), "0000");
    equal(MB.utility.formatDate({ year: 1999 }), "1999");
    equal(MB.utility.formatDate({ year: 1999, month: 1 }), "1999-01");
    equal(MB.utility.formatDate({ year: 1999, month: 1, day: 1 }), "1999-01-01");
    equal(MB.utility.formatDate({ year: 1999, day: 1 }), "1999-??-01");
    equal(MB.utility.formatDate({ month: 1 }), "????-01");
    equal(MB.utility.formatDate({ month: 1, day: 1 }), "????-01-01");
    equal(MB.utility.formatDate({ day: 1 }), "????-??-01");
});


test("formatDatePeriod", function () {
    var a = { year: 1999 };
    var b = { year: 2000 };

    equal(MB.utility.formatDatePeriod({ beginDate: a, endDate: a, ended: false }), "1999");
    equal(MB.utility.formatDatePeriod({ beginDate: a, endDate: a, ended: true }), "1999");

    equal(MB.utility.formatDatePeriod({ beginDate: a, endDate: b, ended: false }), "1999 \u2013 2000");
    equal(MB.utility.formatDatePeriod({ beginDate: a, endDate: b, ended: true }), "1999 \u2013 2000");

    equal(MB.utility.formatDatePeriod({ beginDate: {}, endDate: b, ended: false }), " \u2013 2000");
    equal(MB.utility.formatDatePeriod({ beginDate: {}, endDate: b, ended: true }), " \u2013 2000");

    equal(MB.utility.formatDatePeriod({ beginDate: a, endDate: {}, ended: false }), "1999 \u2013 ");
    equal(MB.utility.formatDatePeriod({ beginDate: a, endDate: {}, ended: true }), "1999 \u2013 ????");
});


test("validDate", function () {
    equal(MB.utility.validDate("", "", ""), true, "all empty strings are valid");
    equal(MB.utility.validDate(undefined, undefined, undefined), true, "all undefined values are valid");
    equal(MB.utility.validDate(null, null, null), true, "all null values are valid");
    equal(MB.utility.validDate(2000), true, "just a year is valid");
    equal(MB.utility.validDate("", 10), true, "just a month is valid");
    equal(MB.utility.validDate("", "", 29), true, "just a day is valid");
    equal(MB.utility.validDate(0), false, "the year 0 is invalid");
    equal(MB.utility.validDate("", 13), false, "months > 12 are invalid");
    equal(MB.utility.validDate("", "", 32), false, "days > 31 are invalid");
    equal(MB.utility.validDate(2001, 2, 29), false, "2001-02-29 is invalid");
    equal(MB.utility.validDate("2000f"), false, "letters are invalid");
    equal(MB.utility.validDate(1960, 2, 29), true, "leap years are handled correctly (MBS-5663)");
});


test("validDatePeriod", function () {
    var tests = [
        {
            a: {},
            b: {},
            expected: true
        },
        {
            a: { year: 2000, month: null, day: 11 },
            b: { year: 2000, month: null, day: 10 },
            expected: true
        },
        {
            a: { year: 2000, month: 11, day: 11 },
            b: { year: 2000, month: 12, day: 12 },
            expected: true
        },
        {
            a: { year: 2000, month: 11, day: 11 },
            b: { year: 1999, month: 12, day: 12 },
            expected: false
        },
        {
            a: { year: 2000, month: 11, day: 11 },
            b: { year: 2000, month: 10, day: 12 },
            expected: false
        },
        {
            a: { year: 2000, month: 11, day: 11 },
            b: { year: 2000, month: 11, day: 10 },
            expected: false
        },
        {
            a: { year: "2000", month: "3", day: "1" },
            b: { year: "2000", month: "10", day: "1" },
            expected: true
        },
        {
            a: { year: 1961, month: 2, day: 28 },
            b: { year: 1961, month: 2, day: 29 },
            expected: false
        }
    ];

    _.each(tests, function (test) {
        equal(MB.utility.validDatePeriod(test.a, test.b), test.expected);
    });
});
