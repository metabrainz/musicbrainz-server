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
    var ret = [];
    for (var key in obj) {
        if (obj.hasOwnProperty (key))
        {
            ret.push (key);
        }
    }

    return ret;
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
    if (_.isString (obj) || _.isNumber (obj))
    {
        return obj;
    }
    else if (_.isArray (obj))
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

    $(form).prepend (
        $(button).clone ().removeAttr ('id').css ({
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
        $(id).attr ('checked', 'checked');
    }
    else if ($.cookie (name) === "0")
    {
        $(id).removeAttr ('checked');
    }

    $(id).bind ('change.mb', function () {
        $.cookie (name, $(id).is(':checked') ? "1" : "0", { path: '/', expires: 365 });
    });

};

MB.utility.formatTrackLength = function (duration)
{
    var length_str = '';

    if (duration === null)
    {
        length_str = '?:??';
    }
    else
    {
        var length_in_secs = (duration / 1000 + 0.5);
        length_str = String (Math.floor (length_in_secs / 60)) + ":" +
            ("00" + String (Math.floor (length_in_secs % 60))).slice (-2);
    }

    return length_str;
};


MB.utility.unformatTrackLength = function (duration)
{
    var parts = duration.split (":");
    if (parts.length != 2)
    {
        return null;
    }

    if (parts[1] == '??')
    {
        return null;
    }

    return parseInt (parts[0], 10) * 60000 + parseInt (parts[1], 10) * 1000;
};
