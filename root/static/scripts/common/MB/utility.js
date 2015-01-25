/* Copyright (C) 2009 Oliver Charles
   Copyright (C) 2010 MetaBrainz Foundation

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

MB.utility.formatTrackLength = function (duration)
{
    if (!duration)
    {
        return '';
    }

    if (duration < 1000)
    {
        return duration + ' ms';
    }

    var seconds = Math.round(duration / 1000.0);

    var one_minute = 60;
    var one_hour = 60 * one_minute;

    var hours = Math.floor(seconds / one_hour);
    seconds = seconds % one_hour;

    var minutes = Math.floor(seconds / one_minute);
    seconds = seconds % one_minute;

    var ret = '';
    ret = ('00' + seconds).slice(-2);

    if (hours > 0) {
        ret = hours + ':' + ('00' + minutes).slice(-2) + ':' + ret;
    }
    else {
        ret = minutes + ':' + ret;
    }

    return ret;
};

function empty(value) {
    return value === null || value === undefined || value === "";
}

MB.utility.validDate = (function () {
    var daysInMonth = {
        "true":  [0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
        "false": [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    };

    function empty(value) {
        return value === null || value === undefined || value === "";
    }

    var numberRegex = /^[0-9]+$/;

    function parseNumber(num) {
        return numberRegex.test(num) ? parseInt(num, 10) : NaN;
    }

    return function (y, m, d) {
        y = empty(y) ? null : parseNumber(y);
        m = empty(m) ? null : parseNumber(m);
        d = empty(d) ? null : parseNumber(d);

        // We couldn't parse one of the fields as a number.
        if (isNaN(y) || isNaN(m) || isNaN(d)) return false;

        // The year is a number less than 1.
        if (y !== null && y < 1) return false;

        // The month is a number less than 1 or greater than 12.
        if (m !== null && (m < 1 || m > 12)) return false;

        // The day is empty. There's no further validation we can do.
        if (d === null) return true;

        var isLeapYear = y % 400 ? (y % 100 ? !(y % 4) : false) : true;

        // Invalid number of days based on the year.
        if (d < 1 || d > 31 || d > daysInMonth[isLeapYear.toString()][m]) return false;

        // The date is assumed to be valid.
        return true;
    };
}());

MB.utility.validDatePeriod = function (a, b) {
    var y1 = a.year, m1 = a.month, d1 = a.day;
    var y2 = b.year, m2 = b.month, d2 = b.day;

    if (!MB.utility.validDate(y1, m1, d1) || !MB.utility.validDate(y2, m2, d2)) {
        return false;
    }

    if (!y1 || !y2 || +y1 < +y2) return true; else if (+y2 < +y1) return false;
    if (!m1 || !m2 || +m1 < +m2) return true; else if (+m2 < +m1) return false;
    if (!d1 || !d2 || +d1 < +d2) return true; else if (+d2 < +d1) return false;

    return true;
};

MB.utility.parseDate = (function () {
    var dateRegex = /^(\d{4}|\?{4})(?:-(\d{2}|\?{2})(?:-(\d{2}|\?{2}))?)?$/;

    return function (str) {
        var match = str.match(dateRegex) || [];
        return {
            year:  parseInt(match[1], 10) || null,
            month: parseInt(match[2], 10) || null,
            day:   parseInt(match[3], 10) || null
        };
    };
}());

MB.utility.filesize = function (size) {
    /* 1 decimal place.  false disables bit sizes. */
    return filesize(size, 1, false);
};

MB.utility.percentOf = function (x, y) {
    return x * y / 100;
};

// Compares two names, considers them equivalent if there are only case
// changes, changes in punctuation and/or changes in whitespace between
// the two strings.

MB.utility.similarity = (function () {
    var punctuation = /[!"#$%&'()*+,\-.>\/:;<=>?¿@[\\\]^_`{|}~⁓〜\u2000-\u206F\s]/g;

    function clean(str) {
        return (str || "").replace(punctuation, "").toLowerCase();
    }

    return function (a, b) {
        // If a track title is all punctuation, we'll end up with an empty
        // string, so just fall back to the original for comparison.
        a = clean(a) || a || "";
        b = clean(b) || b || "";

        return 1 - (_.str.levenshtein(a, b) / (a.length + b.length));
    };
}());

MB.utility.optionCookie = function (name, defaultValue) {
    var existingValue = $.cookie(name);

    var observable = ko.observable(
        defaultValue ? existingValue !== "false" : existingValue === "true"
    );

    observable.subscribe(function (newValue) {
        $.cookie(name, newValue, { path: "/", expires: 365 });
    });

    return observable;
};

MB.utility.formatDate = function (date) {
    var y = ko.unwrap(date.year);
    var m = ko.unwrap(date.month);
    var d = ko.unwrap(date.day);

    return (
        (!empty(y) ? ( y < 0 ? "-" + _.str.pad(-y, 3, "0") : _.str.pad(y, 4, "0"))
                   : (m || d ? "????" : "")) +
        (m ? "-" + _.str.pad(m, 2, "0") : (d ? "-??" : "")) +
        (d ? "-" + _.str.pad(d, 2, "0") : "")
    );
};

MB.utility.formatDatePeriod = function (period) {
    var beginDate = MB.utility.formatDate(period.beginDate);
    var endDate = MB.utility.formatDate(period.endDate);
    var ended = ko.unwrap(period.ended);

    if (!beginDate && !endDate) return "";
    if (beginDate === endDate) return beginDate;

    return beginDate + " \u2013 " + (endDate || (ended ? "????" : ""));
};

MB.utility.deferFocus = function () {
    var selectorArguments = arguments;
    _.defer(function () { $.apply(null, selectorArguments).focus() });
};

MB.utility.debounce = function (value, delay) {
    if (!ko.isObservable(value)) {
        value = ko.computed(value);
    }
    return value.extend({
        rateLimit: { method: "notifyWhenChangesStop", timeout: delay || 500 }
    });
};
