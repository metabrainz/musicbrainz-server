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

var Util = RE.Util = RE.Util || {}, originalFields = {};


Util.init = function(typeInfo, attrInfo) {

    var findItem = function(roots, id, i, c) {
        if (roots && (i = roots.length)) while (c = roots[--i])
            if ((c.id == id) || (c = findItem(c.children, id)))
                return c;
    };

    Util.typeInfo = _.memoize(function(linkType, info) {
        for (var key in typeInfo)
            if (info = findItem(typeInfo[key], linkType)) return info;
    });

    Util.types = _.memoize(function(linkType) {
        for (var key in typeInfo)
            if (findItem(typeInfo[key], linkType)) return key;
    });

    Util.typeInfoByEntities = function(types) {return typeInfo[types]};

    Util.attrRoot = function(name) {return attrInfo[name]};

    var attrValues = _.values(attrInfo);
    Util.attrInfo = _.memoize(function(id) {return findItem(attrValues, id)});
};


Util.parseRelationships = function(obj) {
    var source = RE.Entity(obj), args = {source: source, result: []};

    if (obj.relationships)
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
    Util.renderRelationships(args.result, _.identity);
};


var parseRelationship = function(args) {
    var obj = args.obj, target, type = RE.Util.types(obj.link_type),
        orig = originalFields[type] = originalFields[type] || {};

    Util.attrsForLinkType(obj.link_type, function(attr) {
        var name = attr.name;
        obj.attributes[name] = Util.convertAttr(attr, obj.attributes[name]);
    });

    obj.begin_date = Util.parseDate(obj.begin_date || "");
    obj.end_date = Util.parseDate(obj.end_date || "");

    orig = orig[obj.id] = $.extend(true, {}, obj);
    orig.target.type = args.target_type;
    orig.target = RE.Entity(orig.target);
    orig.attributes = ko.toJS(obj.attributes);

    target = obj.target;
    target.type = args.target_type;

    if (args.target_type == "url") {
        target.name = target.url;
        delete target.url;
    }
    obj.source = args.source;
    obj.target = RE.Entity(target);

    args.result.push(RE.Relationship(obj));
    if (target.relationships) Util.parseRelationships(target);
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

        if (aac.artist.gid != bac.artist.gid) return false;
        if (aac.artist.name != bac.artist.name) return false;
        if (aac.joinphrase != bac.joinphrase) return false;
    }
    return true;
};


var MBIDRegex = /^[\da-f]{8}-[\da-f]{4}-[\da-f]{4}-[\da-f]{4}-[\da-f]{12}$/;

Util.isMBID = function(str) {
    return MBIDRegex.test(str);
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
    var typeInfo = Util.typeInfo(linkType);
    if (!typeInfo || !typeInfo.attrs) return {};

    $.each(typeInfo.attrs, function(id, info) {
        callback(Util.attrInfo(id));
    });
};


Util.originalFields = function(relationship, field) {
    var type = relationship.type.peek(), fields;

    if (!(fields = originalFields[type])) return null;
    if (!(fields = fields[relationship.id])) return null;

    return field ? fields[field] : fields;
};

return RE;

}(MB.RelationshipEditor || {}));
