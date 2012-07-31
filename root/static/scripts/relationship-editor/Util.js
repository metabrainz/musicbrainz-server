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

var Util = RE.Util, CGI = Util.CGI = {}, CGIRegex;


Util.parseRelationships = function(obj, checkCGIParams) {
    var source = RE.Entity(obj);

    $.each(obj.relationships, function(target_type, rel_types) {
        if (obj.type == "work" && target_type == "recording") return;
        if (target_type == "url") return; // no url support yet

        $.each(rel_types, function(rel_type, rels) {

            for (var i = 0; i < rels.length; i++) {
                var rel = rels[i], target, relationship, type, orig;
                type = RE.Util.type(rel.link_type);
                orig = RE.serverFields[type] = RE.serverFields[type] || {};

                if (orig[rel.id] !== undefined) continue;

                Util.attrsForLinkType(rel.link_type, function(attr) {
                    var name = attr.name;
                    rel.attributes[name] = Util.convertAttr(attr, rel.attributes[name]);
                });
                rel.begin_date = Util.parseDate(rel.begin_date || "");
                rel.end_date = Util.parseDate(rel.end_date || "");
                rel.ended = Boolean(rel.ended);
                rel.direction = rel.direction || "forward";

                orig = orig[rel.id] = $.extend(true, {}, rel);
                orig.target.type = target_type;
                orig.target = RE.Entity(orig.target);
                orig.attributes = ko.toJS(rel.attributes);

                if (checkCGIParams) {
                    try {
                        $.extend(true, rel, CGI.actions.edit[type][rel.id]);
                    } catch (e) {};

                    try {
                        $.extend(true, rel, CGI.actions.remove[type][rel.id]);
                    } catch (e) {};
                }
                target = rel.target;
                target.type = target_type;

                if (target_type == "url") {
                    target.name = target.url;
                    delete target.url;
                }
                rel.source = source;
                rel.target = RE.Entity(target);

                RE.Relationship(rel, !checkCGIParams).show();

                if (target.relationships) Util.parseRelationships(target, checkCGIParams);
            }
        });
    });

    if (checkCGIParams) {
        var added = CGI.actions.add[source.gid], obj, src, target;
        if (added === undefined) return;

        for (var i = 0; i < added.length; i++) {
            var obj = added[i];

            obj.source = source;
            obj.target = RE.Entity(obj.target);

            RE.Relationship(obj).show();
        }
    }
};


// form state is preserved using three variables, one for each action.

CGI.actions = {add: {}, edit: {}, remove: {}};

// parseParams makes a lot of assumptions about how the params look (i.e. valid).
// the regex is used to skip any invalid ones

CGIRegex = eval(
    "/^rel-editor.rels.\\d+." +          // rel-editor.rels.n, where n = the rel num.
    "(?:" +
        "id|action|link_type|direction|ended|" +
        "(?:begin|end)_date." +          // date fields.
            "(?:year|month|day)|" +

        "attrs.(?:[a-z_]+(?:.\\d+)?)|" + // matches attr.foo for boolean attrs, or
                                         // attrs.foo.n for select attrs.
        "entity.[01]." +                 // entity fields.
        "(?:" +
            "id|type|name|gid|sortname|" +
            "comment|work_type|work_language)" +
    ")$/"
);

CGI.parseParams = function(params, errorFields) {
    var result = {};

    $.each(params, function(key, value) {
        if (!CGIRegex.test(key)) return;

        var parts = key.split("."), num = parts[2],
            field = result[num] = result[num] || {};

        if ($.isArray(value)) value = value[0];
        if (/^\d+$/.test(value)) value = parseInt(value, 10);

        for (var j = 3; part = parts[j]; j++) {
            if (j == parts.length - 1) field[part] = value;

            field = field[part] = field[part] ||
                ((part == "entity" || parts[j - 1] == "attrs") ? [] : {});
        }
    });

    $.each(result, function(num, fields) {try {
        if (errorFields[fields.id]) fields.serverErrors = errorFields[fields.id];

        var entity0 = fields.entity[0], entity1 = fields.entity[1],
            typeInfo = RE.typeInfo[fields.link_type], types, src, source;

        if (typeInfo) {
            types = typeInfo.types.join("-");
        } else {
            // the link type field is invalid, let's try to set it to something
            fields.link_type = Util.defaultLinkType(entity0.type, entity1.type);
            typeInfo = RE.typeInfo[fields.link_type];
            types = typeInfo.types.join("-");
        }

        src = Util.src(fields.link_type, fields.direction);
        source = fields.entity[src];
        fields.target = fields.entity[1 - src];
        delete fields.entity;
        fields.attributes = {};

        if (fields.attrs) {
            Util.attrsForLinkType(fields.link_type, function(attr) {
                var name = attr.name;
                fields.attrs[name] = Util.convertAttr(attr, fields.attrs[name]);
            });
            fields.attributes = fields.attrs;
            delete fields.attrs;
        }

        var actions = CGI.actions[fields.action], gid = source.gid;

        fields.action == "add"
            ? (actions[gid] = actions[gid] || []).push(fields)
            : ((actions[types] = actions[types] || {})[fields.id] = fields);

    } catch (e) {}});
};


var dateRegex = /^(\d{4})(?:-(\d{2})(?:-(\d{2}))?)?$/;

Util.parseDate = function(str) {
    var match = str.match(dateRegex) || [];
    return {
        year:  match[1] || null,
        month: match[2] || null,
        day:   match[3] || null
    };
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


var MBIDRegex = /^[\da-f]{8}-[\da-f]{4}-[\da-f]{4}-[\da-f]{4}-[\da-f]{12}$/;

Util.isMBID = function(str) {
    return str.match(MBIDRegex) !== null;
};


var entityRelations = {
    'artist-recording': 1, 'artist-release': 1, 'artist-work': 1,
    'label-recording':  1, 'label-release':  1, 'label-work':  1,
    'recording-url':    0, 'recording-work': 0, 'release-url': 0, 'url-work': 1,
};
// given a link type and a direction, tells us what the source is

Util.src = function(linkType, direction) {
    if (!linkType) return null;
    var types = RE.typeInfo[linkType].types, str = types.join("-");

    return ((types[0] == types[1] || str == "recording-release")
        ? (direction == "backward" ? 1 : 0) : entityRelations[str]);
};


Util.type = function(linkType) {
    var info = RE.typeInfo[linkType];
    return info ? info.types.join("-") : null;
};


Util.ID = function() {
    var alphabet = "0123456789abcdef", id = "";
    while (id.length < 10)
        id += alphabet[Math.floor(Math.random() * 16)];
    return "new-" + id;
};


Util.tempEntity = function(type) {
    var id = Util.ID();
    return RE.Entity({type: type, id: id, gid: id});
};


Util.convertAttr = function(root, value) {
    if (root.children) {
        if (!$.isArray(value)) value = [value];

        return $.map(value, function(v) {
            return parseInt(v, 10) || null;
        });
    } else {
        if ($.isNumeric(value)) value = parseInt(value, 10);
        return Boolean(value);
    }
};


Util.attrsForLinkType = function(linkType, callback) {
    var typeInfo = RE.typeInfo[linkType];
    if (!typeInfo || !typeInfo.attrs) return {};

    $.each(typeInfo.attrs, function(id, info) {
        callback(RE.attrMap[id]);
    });
};


Util.defaultLinkType = function(sourceType, targetType) {
    var type = sourceType + "-" + targetType, linkType;

    if (!RE.typeInfoByEntities[type])
        type = targetType + "-" + sourceType;

    linkType = RE.typeInfoByEntities[type][0];
    return linkType.descr ? linkType.id : linkType.children[0];
};

})();
