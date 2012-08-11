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

MB.RelationshipEditor = (function(RE) {

var Util = RE.Util = RE.Util || {}, CGI = Util.CGI = {}, CGIRegex;


Util.parseRelationships = function(obj, checkCGIParams) {
    var source = RE.Entity(obj),
        args = {source: source, checkCGIParams: checkCGIParams, result: []};

    $.each(obj.relationships, function(target_type, rel_types) {
        if (obj.type == "work" && target_type == "recording") return;
        if (target_type == "url") return; // no url support yet
        args.target_type = target_type;

        $.each(rel_types, function(rel_type, rels) {

            for (var i = 0; i < rels.length; i++) {
                args.obj = rels[i];
                parseRelationship(args);
            }
        });
    });

    var added = CGI.actions.add[source.gid];
    if (checkCGIParams && added) {
        var obj;

        for (var i = 0; i < added.length; i++) {
            obj = added[i];
            obj.source = source;
            obj.target = RE.Entity(obj.target);

            args.result.push(RE.Relationship(obj));
        }
    }

    Util.renderRelationships(args.result, _.identity);
};


var parseRelationship = function(args) {
    var obj = args.obj, target, relationship, type, orig;
    type = RE.Util.type(obj.link_type);
    orig = RE.serverFields[type] = RE.serverFields[type] || {};

    if (orig[obj.id]) return;

    Util.attrsForLinkType(obj.link_type, function(attr) {
        var name = attr.name;
        obj.attributes[name] = Util.convertAttr(attr, obj.attributes[name]);
    });

    obj.begin_date = Util.parseDate(obj.begin_date || "");
    obj.end_date = Util.parseDate(obj.end_date || "");
    obj.ended = Boolean(obj.ended);
    obj.direction = obj.direction || "forward";

    orig = orig[obj.id] = $.extend(true, {}, obj);
    orig.target.type = args.target_type;
    orig.target = RE.Entity(orig.target);
    orig.attributes = ko.toJS(obj.attributes);

    if (args.checkCGIParams) {
        try {
            $.extend(true, obj, CGI.actions.edit[type][obj.id]);
        } catch (e) {};

        try {
            $.extend(true, obj, CGI.actions.remove[type][obj.id]);
        } catch (e) {};
    }
    target = obj.target;
    target.type = args.target_type;

    if (args.target_type == "url") {
        target.name = target.url;
        delete target.url;
    }
    obj.source = args.source;
    obj.target = RE.Entity(target);

    args.result.push(RE.Relationship(obj, !args.checkCGIParams));

    if (target.relationships) Util.parseRelationships(target, args.checkCGIParams);
};

// trying to render a ton of relationships all at once is *slow*. this helper
// function is designed to not do that. each relationship promises to create
// the next one once it's done rendering itself. the promise is called back in
// RelationshipEditor.js -> release.addRelationship.

Util.renderRelationships = function(targets, callback) {
    function next(index) {

        return function() {
            var target = targets[index], nextTarget = targets[index + 1],
                promise = nextTarget ? next(index + 1) : undefined,
                relationship = callback(target);

            if (relationship) {

                relationship.promise = promise;
                relationship.show();

            } else if (promise) promise();
        };
    }
    next(0)();
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

    return ((types[0] == types[1] || str == "recording-release" || str == "recording-work")
        ? (direction == "backward" ? 1 : 0) : entityRelations[str]);
};


Util.type = function(linkType) {
    var info = RE.typeInfo[linkType];
    return info ? info.types.join("-") : null;
};


Util.tempEntity = function(type) {
    var id = _.uniqueId("new-");
    return RE.Entity({type: type, id: id, gid: id});
};


Util.convertAttr = function(root, value) {
    if (root.children) {
        if (!_.isArray(value)) value = [value];

        return (_.chain(value)
            .map(function(n) {return parseInt(n, 10)})
            .compact().uniq().value()
            .sort(function(a, b) {return a - b}));
    } else {
        return Boolean(_.isNumber(value) ? parseInt(value, 10) : value);
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


var newWorkRegex = /^new-\d+$/;

Util.isNewWork = function(gid) {
    return newWorkRegex.test(gid);
};

return RE;

}(MB.RelationshipEditor || {}));
