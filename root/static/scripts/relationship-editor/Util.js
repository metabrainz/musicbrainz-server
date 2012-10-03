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


Util.parseRelationships = function(source) {
    var result = [];

    if (source.relationships) $.each(source.relationships, function(target_type, rel_types) {
        if (source.type == "work" && target_type == "recording") return;
        if (target_type == "url") return; // no url support yet

        $.each(rel_types, function(rel_type, rels) {

            for (var i = 0, obj; obj = rels[i]; i++) {
                var target = obj.target;
                result.push(parseRelationship(obj, source, target_type));
                result.push.apply(result, Util.parseRelationships(target));
            }
        });
    });
    return result;
};


var parseRelationship = _.memoize(function(obj, source, target_type) {
    var target, type = RE.Util.types(obj.link_type),
        orig = originalFields[type] = originalFields[type] || {};

    Util.attrsForLinkType(obj.link_type, function(attr) {
        var name = attr.name;
        obj.attributes[name] = Util.convertAttr(attr, obj.attributes[name]);
    });

    obj.begin_date = Util.parseDate(obj.begin_date || "");
    obj.end_date = Util.parseDate(obj.end_date || "");
    obj.ended = Boolean(obj.ended);
    obj.backward = (obj.direction == "backward");

    orig = orig[obj.id] = $.extend(true, {}, obj);
    orig.target.type = target_type;
    orig.target = RE.Entity(orig.target);
    orig.attributes = ko.toJS(obj.attributes);

    target = obj.target;
    target.type = target_type;

    if (target_type == "url") {
        target.name = target.url;
        delete target.url;
    }
    obj.source = RE.Entity(source);
    obj.target = RE.Entity(target);

    return RE.Relationship(obj, false, true);

}, function(obj, source, target_type) {
    return [source.type, target_type, obj.id].join("-");
});


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

    for (var i = 0; i < an; i++) {
        var aac = a[i], bac = b[i];

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

// Attempts to merge two dates, otherwise returns false if they conflict.

Util.mergeDates = function(a, b) {
    var a = ko.toJS(a), b = ko.toJS(b), ay = a.year, am = a.month, ad = a.day,
        by = b.year, bm = b.month, bd = b.day;

    return (((ay && by && ay != by) || (am && bm && am != bm) || (ad && bd && ad != bd)) ?
            false : {year: ay || by, month: am || bm, day: ad || bd});
};


Util.callbackQueue = function(targets, callback) {
    var next = function(index) {
        return function() {
            var target = targets[index];
            if (target) {
                callback(target);
                _.defer(next(index + 1));
            }
        };
    };
    next(0)();
};

return RE;

}(MB.RelationshipEditor || {}));
