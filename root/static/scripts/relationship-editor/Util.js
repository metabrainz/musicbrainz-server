/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2012 MetaBrainz Foundation

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

(function() {

var Util = RE.Util = {}, CGI = Util.CGI = {}, cgi_regex,
    added_rels = {}, edited_rels = {}, removed_rels = {};

// parseParams makes a lot of assumptions about how the params look (i.e. valid).
// the regex is used to skip any invalid ones

cgi_regex = new RegExp(
    "^rel-editor\\.rels\\.\\d+\\.(?:id|action|link_type|entity\\.[01]\\.(?:id" +
    "|type|name|gid|sortname|comment|type_id|language_id)|ended|begin_date\\." +
    "(?:year|month|day)|end_date\\.(?:year|month|day)|attrs\\.(?:[a-z_]+(?:\\" +
    ".\\d+)?)|direction)$"
);

var hasError = function(error_keys, key) {
    for (var i = 0; i < error_keys.length; i++) {
        var err_key = error_keys[i];
        if (err_key.lastIndexOf(key, 0) === 0) {
            error_keys.splice(i, 1);
            return err_key;
        }
    }
    return false;
};

CGI.parseParams = function(params, error_fields) {
    var result = {}, keys = MB.utility.keys(params),
        error_keys = MB.utility.keys(error_fields);

    for (var i = 0; i < keys.length; i++) {
        var key = keys[i], field, errors = false;
        if (!key.match(cgi_regex)) continue;
        var value = params[key], parts = key.split("."), num = parts[2];

        if ((field = result[num]) === undefined) {
            field = result[num] = {};
        }
        if ($.isArray(value)) value = value[0];
        if (/^\d+$/.test(value)) value = parseInt(value);

        current_key = 'rel-editor.' + num + '.' + parts[3];
        for (var j = 3; j < parts.length; j++) {

            var err_key;
            if (err_key = hasError(error_keys, current_key)) {
                if (field.errors === undefined) {
                    field.errors = [];
                }
                errors = true;
                field.errors.push(error_fields[err_key]);
            }
            var part = parts[j];

            if (part == "entity") {
                if (field[part] === undefined) field[part] = [];
                field = field[part];
            } else if (parts[j - 2] == "attrs") {
                field.push(value);

            } else if (j == parts.length - 1) {
                field[part] = value;

            } else {
                field = field[part] = (
                    field[part] || (parts[j - 1] == "attrs" ? [] : {})
                );
            }
        }
        if (errors) result[num].errors = true;
    }
    /* form state is preserved using three variables, each representing
       a separate action:
       - edited_rels and removed_rels are origanized by their id
       - added_rels are organized into lists based on the source entity's gid
     */
    var relnums = MB.utility.keys(result);

    for (var i = 0; i < relnums.length; i++) {try {
        var num = relnums[i], field = result[num];

        var entity0 = field.entity[0] = RE.Entity(field.entity[0]),
            entity1 = field.entity[1] = RE.Entity(field.entity[1]),
            types = Util.types(field.link_type),
            typestr = Util.typestr(field.link_type), removed, added, edited;

        if (!typestr) continue;

        if (field.action == "remove") {
            if ((removed = removed_rels[typestr]) === undefined) {
                removed = removed_rels[typestr] = {};
            }
            removed[field.id] = field;
        } else {
            field.attrs = field.attrs || {};

            if (field.action == "add") {
                var source = Util.src(types[0], types[1], field.direction) === 0
                    ? entity0 : entity1;

                if ((added = added_rels[source.gid]) === undefined) {
                    added = added_rels[source.gid] = [];
                }
                added.push(field);
            } else if (field.action == "edit") {
                if ((edited = edited_rels[typestr]) === undefined) {
                    edited = edited_rels[typestr] = {};
                }
                edited[field.id] = field;
            }
        }
    } catch (e) {}}
};


CGI.added = function(gid) {
    return added_rels[gid];
};

CGI.edited = function(fields) {
    var types = Util.typestr(fields.link_type);
    return (edited_rels[types] || {})[fields.id];
};

CGI.removed = function(fields) {
    var types = Util.typestr(fields.link_type);
    return (removed_rels[types] || {})[fields.id];
};


var date_regex = /^(\d{4})(?:-(\d{2})(?:-(\d{2}))?)?$/;

Util.parseDate = function(str) {
    var match = str.match(date_regex);
    if (match) {
        date = {year: parseInt(match[1])};
        if (match[2]) date.month = parseInt(match[2]);
        if (match[3]) date.day = parseInt(match[3]);
        return date;
    }
};


Util.compareArtistCredits = function(a, b) {
    var an = a.length, bn = b.length;
    if (an != bn) return false;

    for (var i = 0; i < an.length; i++) {
        var aac = a[an], bac = b[bn];

        if (aac.artist.id != bac.artist.id) return false;
        if (aac.artist.name != bac.artist.name) return false;
        if (aac.joinphrase != bac.joinphrase) return false;
    }
    return true;
};

// used to generate small ids to identify new works

Util.fakeID = function() {
    var alphabet = "0123456789abcdef", id = "";
    while (id.length < 10)
        id += alphabet[Math.floor(Math.random() * 16)];
    return id;
};


var mbid_regex = /^[\da-f]{8}-[\da-f]{4}-[\da-f]{4}-[\da-f]{4}-[\da-f]{12}$/;

Util.isMBID = function(str) {
    return str.match(mbid_regex) !== null;
};

// given type0, type1 and a direction, tells us what the source is

Util.src = function(t0, t1, direction) {
    if (t0 == t1) return direction == "backward" ? 1 : 0;
    if (t0 == "recording" || t0 == "release") {
        if (t1 == "release") return direction == "backward" ? 1 : 0;
        return 0;
    }
    if (t1 == "recording" || t1 == "work" || t1 == "release") return 1;
    return null;
};


Util.types = function(link_type) {
    var info = RE.type_info[link_type];
    return info ? [info.type0, info.type1] : [];
};

Util.typestr = function(link_type) {
    var info = RE.type_info[link_type];
    return info ? info.type0 + "-" + info.type1 : null;
};

})();
