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

MB.utility.filesize = function (size) {
    /* 1 decimal place.  false disables bit sizes. */
    return filesize(size, 1, false);
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
