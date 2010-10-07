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

MB.utility.isArray  = function(o) { return (o instanceof Array    || typeof o == "array"); };
MB.utility.isString = function(o) { return (o instanceof String   || typeof o == "string"); };


MB.utility.autocomplete = {};
MB.utility.autocomplete.options = {
    "minChars": 1,
    "highlight": false,
    "width": "20em",
    "formatItem": function(row, i, max) {
        return row.name +
            (row.comment ? ' <span class="autocomplete-comment">(' + row.comment + ")</span>" : "")
    },
    "formatMatch": function(row, i, max) {
        return row.name;
    },
    "parse": function (rows) {
        var parsed = [];
        for (var i=0; i < rows.length; i++) {
            var row = rows[i];
            parsed[parsed.length] = {
                data: row,
                value: row.gid,
                result: row
            };
        }
    return parsed;
    }
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

/* A simpler autocomplete, this autocompleter just returns the json 
   results to the callback instead of displaying an autocomplete box itself. 

   - input      the <input> element to watch.  
                NOTE: the input element should have a unique 'id' or 'name' attribute.
   - query      callback which should transform the input value to a hash which will
                be used as a query_string.
   - results    callback which will be called when results come in.
   - options    optional hash with settings, currently only 'delay' is recognized.

*/
MB.utility.AutoComplete = function (input, query, results, options) {
    var self = MB.Object();

    var defaults = { 'delay': 10 };

    self.input = input;
    self.query = query;
    self.results = results;
    self.timeout = null;
    self.options = $.extend({}, defaults, options);
    self.port_name = self.input.attr('name') || self.input.attr('id');

    var onChange = function () {

        var q = self.query (self.input.val ());

        if (q)
        {
            self.request (q.url, q.data, self.results);
        }
        else
        {
            self.results ([]);
        }
    };

    var request = function (url, query_string, results) {
 	$.ajax({
 	    // try to leverage ajaxQueue plugin to abort previous requests
 	    mode: "abort",
 	    // limit abortion to this input
 	    port: "MB.utility.AutoComplete." + self.port_name,
            url: url,
            data: query_string,
            success: results
        });
    };

    self.onChange = onChange;
    self.request = request;

    self.input.bind (($.browser.opera ? "keypress" : "keydown") + " paste", function (event) {
	clearTimeout(self.timeout);
	self.timeout = setTimeout(self.onChange, self.options.delay);
    });

    return self;
};

