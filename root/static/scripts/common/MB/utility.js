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

MB.utility.keys = function (obj) {
    if (null === obj) {
        return [];
    }
    else if (Object.keys) {
        return Object.keys(obj);
    }
    else {
        var ret = [];
        for (var key in obj) {
            if (obj.hasOwnProperty (key))
            {
                ret.push (key);
            }
        }

        return ret;
    }
};

/* Convert fullwidth characters to standard halfwidth Latin. */
MB.utility.fullWidthConverter = function (inputString) {
    if (inputString === "") {
        return "";
    }

    i = inputString.length;
    newString = [];

    do {
        newString.push (
            inputString[i-1].replace (/([\uFF01-\uFF5E])/g, function (str, p1) {
                return String.fromCharCode (p1.charCodeAt(0) - 65248);
            })
        );
    } while (--i);

    return newString.reverse ().join("");
};

MB.utility.isNullOrEmpty = function(o) { return (!o || o == ""); };
MB.utility.is_latin = function (str) { return ! /[^\u0000-\u02ff\u1E00-\u1EFF\u2000-\u207F]/.test(str); };

MB.utility.clone = function (input) { return jQuery.extend (true, {}, input); }

/* Set a particular button to be the default submit action for a form. */
MB.utility.setDefaultAction = function (form, button) {

    var withDataAndEvents = true;
    $(form).prepend (
        $(button).clone (withDataAndEvents).removeAttr ('id').css ({
           position: 'absolute',
           left: "-999px", top: "-999px", height: 0, width: 0
        }));

};

/* Remember the state of a checkbox, using a persistent cookie. */
MB.utility.rememberCheckbox = function (id, name) {

    /* only change the checkbox if the cookie is set, otherwise use the default
       value from the html. */
    if ($.cookie (name) === "1")
    {
        $(id).prop('checked', true);
    }
    else if ($.cookie (name) === "0")
    {
        $(id).prop('checked', false);
    }

    $(id).bind ('change.mb', function () {
        $.cookie (name, $(id).is(':checked') ? "1" : "0", { path: '/', expires: 365 });
    });

};

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


MB.utility.unformatTrackLength = function (duration)
{
    if (!duration) {
        return null;
    }

    if (duration.slice (-2) == 'ms')
    {
        return parseInt (duration, 10);
    }

    var parts = duration.replace(/[:\.]/, ':').split (':');
    if (parts[0] == '?' || parts[0] == '??' || duration === '')
    {
        return null;
    }

    var seconds = parseInt (parts.pop (), 10);
    var minutes = parseInt (parts.pop () || 0, 10) * 60;
    var hours = parseInt (parts.pop () || 0, 10) * 3600;

    return (hours + minutes + seconds) * 1000;
};

/* This takes a list of asynchronous functions (i.e. functions which
   return a jquery promise) and runs them in sequence.  It in turn
   returns a promise which is only resolved when all promises in the
   queue have been resolved.  If one of the promises is rejected, the
   rest of the queue is still processed (but the returned promise will
   be rejected).

   Note that any results are currently ignored, it is assumed you are
   interested in the side effects of the functions executed.
*/
MB.utility.iteratePromises = function (promises) {
    var deferred = $.Deferred ();
    var queue = promises;
    var iterate = null;
    var failed = false;

    iterate = function () {
        if (queue.length > 0)
        {
            queue.shift ()().then (iterate, function () {
                failed = true;
                iterate ();
            });
        }
        else
        {
            if (failed)
            {
                deferred.reject ();
            }
            else
            {
                deferred.resolve ();
            }
        }
    };

    iterate ();
    return deferred.promise ();
};

// Based on http://javascript.crockford.com/prototypal.html
MB.utility.beget = function(o) {
    function F() {};
    F.prototype = o;
    return new F;
};

MB.utility.validDate = (function() {
    var daysInMonth = {
        "true":  [0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
        "false": [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    };

    function empty(value) {
        return value === null || value === undefined || value === "";
    }

    return function(y, m, d) {
        y = empty(y) ? null : parseInt(y, 10);
        m = empty(m) ? null : parseInt(m, 10);
        d = empty(d) ? null : parseInt(d, 10);

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
        if (d < 1 || d > daysInMonth[isLeapYear.toString()][m]) return false;

        // The date is assumed to be valid.
        return true;
    };
}());

MB.utility.parseDate = (function () {
    var dateRegex = /^(\d{4})(?:-(\d{2})(?:-(\d{2}))?)?$/;

    return function (str) {
        var match = str.match(dateRegex) || [];
        return {
            year:  match[1] || null,
            month: match[2] || null,
            day:   match[3] || null
        };
    };
}());

MB.utility.joinList = function (items) {
    if (items.length > 1) {
        var a = items.pop();
        var b = items.join(MB.text.EnumerationComma);
        return MB.i18n.expand(MB.text.EnumerationAnd, { b: b, a: a });
    } else if (items.length === 1) {
        return items[0];
    }
    return "";
};


MB.utility.filesize = function (size) {
    /* 1 decimal place.  false disables bit sizes. */
    return filesize (size, 1, false);
};

MB.utility.percentOf = function(x, y) {
    return x * y / 100;
};

MB.utility.callbackQueue = function (targets, callback) {
    var next = function (index) {
        return function () {
            var target = targets[index];
            if (target) {
                callback(target);
                _.defer(next(index + 1));
            }
        };
    };
    next(0)();
};

MB.utility.request = (function () {
    var nextAvailableTime = new Date().getTime(),
        prevDeferred = null,
        timeout = 1000;

    function makeRequest(args, context, deferred) {
        deferred.jqXHR = $.ajax(_.extend({ dataType: "json" }, args))
            .done(function () { deferred.resolveWith(context, arguments) })
            .fail(function () { deferred.rejectWith(context, arguments) });

        deferred.jqXHR.sentData = args.data;
    }

    return function (args, context) {
        var deferred = $.Deferred(),
            now = new Date().getTime();

        if (nextAvailableTime - now <= 0) {
            makeRequest(args, context, deferred);

            // nextAvailableTime is in the past.
            nextAvailableTime = now + timeout;
        } else {
            var later = function () {
                if (!deferred.aborted && !deferred.complete) {
                    makeRequest(args, context, deferred);

                } else if (deferred.next) {
                    deferred.next();
                }
                deferred.complete = true;
            };

            prevDeferred && (prevDeferred.next = later);
            prevDeferred = deferred;

            _.delay(later, nextAvailableTime - now);

            // nextAvailableTime is in the future.
            nextAvailableTime += timeout;
        }

        var promise = deferred.promise();

        promise.abort = function () {
            if (deferred.jqXHR) {
                deferred.jqXHR.abort();
            } else {
                deferred.aborted = true;
            }
        };
        return promise;
    }
}());

MB.utility.formatDate = function (date) {
    var y = ko.unwrap(date.year);
    var m = ko.unwrap(date.month);
    var d = ko.unwrap(date.day);

    if (!y && !m && !d) {
        return "";
    }

    y = y ? _.pad(y, 4, "0") : "????";
    m = m ? _.pad(m, 2, "0") : "??";
    d = d ? _.pad(d, 2, "0") : "??";

    return y + "-" + m + "-" + d;
};
