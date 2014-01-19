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

    return function(y, m, d) {
        y = parseInt(y, 10) || null;
        m = parseInt(m, 10) || null;
        d = parseInt(d, 10) || null;

        if (y === null && m === null && d === null)
            return false;

        var leapYear = (y % 400 ? (y % 100 ? !Boolean(y % 4) : false) : true).toString();

        if (y === null || (d !== null && m === null) || y < 1 || (m !== null &&
            (m < 1 || m > 12 || (d !== null && (d < 1 || d > daysInMonth[leapYear][m]))))) {
            return false;
        }
        return true;
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
