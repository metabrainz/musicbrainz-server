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

MB.utility.displayedValue = function(element) {
    if(element.is('select')) {
        return element.find(':selected').text();
    }
    else if (element.is('input[type=text]')) {
        return element.val();
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

MB.utility.isArray  = function(o) { return (o instanceof Array    || typeof o == "array"); };
MB.utility.isString = function(o) { return (o instanceof String   || typeof o == "string"); };
MB.utility.isNumber = function(o) { return (o instanceof Number  || typeof o == "number"); };
MB.utility.isNullOrEmpty = function(o) { return (!o || o == ""); };
MB.utility.is_ascii = function (str) { return ! /[^\u0000-\u00ff]/.test(str); };

MB.utility.template = function(str) {
    var self = MB.Object();

    var draw = function (o) {
        return str.replace(/#{([^{}]*)}/g,
            function (a, b) {
                var r = o[b];
                return typeof r === 'string' || typeof r === 'number' ? r : a;
            });
    };

    self.draw = draw;

    return self;
};

MB.utility.load_data = function (files, loaded, callback) {
    var uri = files.pop ();

    if (uri)
    {
        jQuery.get (uri, function (data) {
            loaded[uri] = data;

            MB.utility.load_data (files, loaded, callback);
        });
    }
    else
    {
        callback (loaded);
    }
};

MB.utility.exception = function (name, message) {
    var e = function () { this.name = name,  this.message = message };
    e.prototype = new Error ();

    return new e ();
};

MB.utility.clone = function (input) { return jQuery.extend (true, {}, input); }

MB.utility.escapeHTML = function (str) {
    if (!str) return '';

    return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

/* structureToString renders a structure to a string.  It is similar to
   serializing a structure, but intended as input to a hash function.

   The output string is not easily deserialized.
*/
MB.utility.structureToString = function (obj) {
    if (MB.utility.isString (obj) || MB.utility.isNumber (obj))
    {
        return obj;
    }
    else if (MB.utility.isArray (obj))
    {
        var ret = [];
        $.each (obj, function (idx, item) {
            ret.push (MB.utility.structureToString (item));
        });

        return '[' + ret.join (",") + ']';
    }
    else
    {
        var keys = MB.utility.keys (obj);
        keys.sort ();

        var ret = [];
        $.each (keys, function (idx, key) {
            ret.push (key + ":" + MB.utility.structureToString (obj[key]));
        });

        return '{' + ret.join (",") + '}';
    }
};


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
    if (duration === null)
    {
        return '?:??';
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
    if (duration.slice (-2) == 'ms')
    {
        return parseInt (duration, 10);
    }

    var parts = duration.replace(/[:\.]/, ':').split (':');
    if (parts[0] == '?' || parts[0] == '??')
    {
        return null;
    }

    var seconds = parseInt (parts.pop (), 10);
    var minutes = parseInt (parts.pop () || 0, 10) * 60;
    var hours = parseInt (parts.pop () || 0, 10) * 3600;

    return (hours + minutes + seconds) * 1000;
};

MB.utility.renderArtistCredit = function (ac) {
    var html = '';
    $.each(ac.names, function(name) {
        html += this.name + this.join_phrase
    });

    return html;
}

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
        return MB.text.EnumerationAnd.replace("{b}", b).replace("{a}", a);
    } else if (items.length === 1) {
        return items[0];
    }
    return "";
};

