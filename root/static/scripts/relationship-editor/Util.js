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

var Util = RE.Util, CGI = Util.CGI = {}, cgi_regex,
    added_rels = {}, edited_rels = {}, removed_rels = {};

// parseParams makes a lot of assumptions about how the params look (i.e. valid).
// the regex is used to skip any invalid ones

cgi_regex = new RegExp(
    "^rel-editor\\.rels\\.\\d+\\.(?:id|action|link_type|entity\\.[01]\\.(?:id|" +
    "type|name|gid|sortname|work_comment|work_type_id|work_language_id)|ended|" +
    "begin_date\\.(?:year|month|day)|end_date\\.(?:year|month|day)|attrs\\.(?:" +
    "[a-z_]+(?:\\.\\d+)?)|direction)$"
);


CGI.parseParams = function(params, error_fields) {
    var result = {}, keys = MB.utility.keys(params), key, part, errors;

    for (var i = 0; key = keys[i]; i++) {
        if (!cgi_regex.test(key)) continue;
        errors = false;

        var value = params[key], parts = key.split("."), num = parts[2],
            ckey = 'rel-editor.rels.' + num, field = result[num] = result[num] || {};

        if ($.isArray(value)) value = value[0];
        if (/^\d+$/.test(value)) value = parseInt(value, 10);

        for (var j = 3; part = parts[j]; j++) {
            ckey += "." + part;
            if (error_fields[ckey] !== undefined) {
                (field.errors = field.errors || {})[part] = error_fields[ckey];
                errors = true;
            }
            if (j == parts.length - 1) field[part] = value;

            field = field[part] = field[part] ||
                ((part == "entity" || parts[j - 1] == "attrs") ? [] : {});
        }
        if (errors) result[num].has_errors = true;
    }
    /* form state is preserved using three variables, each representing
       a separate action:
       - edited_rels and removed_rels are origanized by their id
       - added_rels are organized into lists based on the source entity's gid
     */
    var relnums = MB.utility.keys(result);

    for (i = 0; i < relnums.length; i++) {try {
        var num = relnums[i], fields = result[num];

        var entity0 = fields.entity[0] = RE.Entity(fields.entity[0]),
            entity1 = fields.entity[1] = RE.Entity(fields.entity[1]),
            type_info = RE.type_info[fields.link_type], typestr,
            removed, added, edited;

        // the link type field is invalid, let's try to set it to something
        if (!type_info) {
            typestr = entity0.type + "-" + entity1.type;
            var type_info = RE.type_info_by_entities[typestr];
            if (type_info === undefined) continue;

            fields.link_type = type_info[0].descr
                ? type_info[0].id : type_info[0].children[0];
        } else {
            typestr = type_info.types.join("-");
        }

        if (fields.action == "remove") {
            if ((removed = removed_rels[typestr]) === undefined) {
                removed = removed_rels[typestr] = {};
            }
            removed[fields.id] = fields;
        } else {
            fields.attrs = fields.attrs || {};

            if (fields.action == "add") {
                var source = fields.entity[Util.src(fields.link_type, fields.direction)];

                if ((added = added_rels[source.gid]) === undefined) {
                    added = added_rels[source.gid] = [];
                }
                added.push(fields);
            } else if (fields.action == "edit") {
                if ((edited = edited_rels[typestr]) === undefined) {
                    edited = edited_rels[typestr] = {};
                }
                edited[fields.id] = fields;
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
        date = {year: parseInt(match[1], 10)};
        if (match[2]) date.month = parseInt(match[2], 10);
        if (match[3]) date.day = parseInt(match[3], 10);
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


var entity_relations = {
    'artist-recording': 1, 'artist-release': 1, 'artist-work': 1,
    'label-recording':  1, 'label-release':  1, 'label-work':  1,
    'recording-url':    0, 'recording-work': 0, 'release-url': 0, 'url-work': 1,
};
// given a link type and a direction, tells us what the source is

Util.src = function(link_type, direction) {
    var types = RE.type_info[link_type].types, str = types.join("-");

    return ((types[0] == types[1] || str == "recording-release")
        ? (direction == "backward" ? 1 : 0) : entity_relations[str]);
};


Util.typestr = function(link_type) {
    var info = RE.type_info[link_type];
    return info ? info.types.join("-") : null;
};

})();
