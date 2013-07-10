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

var Fields = RE.Fields = RE.Fields || {}, Util = RE.Util = RE.Util || {};

var validationHandlers = {

    link_type: function(field, value) {
        var typeInfo = Util.typeInfo(value);

        if (!typeInfo) {
            field.error(MB.text.PleaseSelectARType);
        } else if (!typeInfo.descr) {
            field.error(MB.text.PleaseSelectARSubtype);
        }
        else if (typeInfo.deprecated) {
            field.error(MB.text.RelationshipTypeDeprecated);
        }
    },

    "period.begin_date": function(field, value, relationship) {
        validateDatePeriod(field, relationship.period.end_date, validateDate(field, value));
    },

    "period.end_date": function(field, value, relationship) {
        validateDatePeriod(relationship.period.begin_date, field, null, validateDate(field, value));
    },

    "period.ended": function(field, value) {
        _.isBoolean(value) ? field.error("") : field.error(MB.text.InvalidValue);
    },

    attrs: function(field, value, relationship) {
        var linkType = relationship.link_type(), typeInfo = Util.typeInfo(linkType);
        if (!typeInfo) return;

        $.each(value, function(name, observable) {
            var root = Util.attrRoot(name), attrInfo = typeInfo.attrs[root.id],
                attrField = value[name];

            if (attrInfo === undefined) {
                attrField.error(MB.text.AttributeNotSupported);
                return;
            }
            var values = observable(), isArray = $.isArray(values);

            if (attrInfo[0] > 0 && (!isArray || values.length < attrInfo[0])) {
                attrField.error(MB.text.AttributeRequired);
                return;
            }
            if (attrInfo[1] && isArray && values.length > attrInfo[1]) {
                var str = MB.text.AttributeTooMany
                    .replace("{max}", attrInfo[1])
                    .replace("{n}", values.length);

                attrField.error(str);
                return;
            }
            attrField.error("");
        });
    },

    "entity.0": function(field, value, relationship) {
        var entity0 = relationship.entity[0](), entity1 = relationship.entity[1]();

        if (!Util.isMBID(value.gid)) {
            field.error(MB.text.RequiredField);
        } else if ((relationship.validateEntities) && (entity0 === entity1)) {
            field.error(MB.text.DistinctEntities);
        } else {
            field.error("");
        }
    }
};

validationHandlers["entity.1"] = validationHandlers["entity.0"];


function validateDate(field, value) {
    if (field.error === undefined) return false;

    var y = value.year(), m = value.month(), d = value.day(),
        valid = (y === null && m === null && d === null) || MB.utility.validDate(y, m, d);

    field.error(valid ? "" : MB.text.InvalidDate);
    return valid;
}

function validateDatePeriod(begin, end, beginValid, endValid) {
    beginValid = beginValid || validateDate(begin, begin.peek());
    endValid = endValid || validateDate(end, end.peek());

    if (beginValid && endValid) {

        var a = begin(), b = end(),
            y1 = a.year(), m1 = a.month(), d1 = a.day(),
            y2 = b.year(), m2 = b.month(), d2 = b.day();

        if ((y1 && y2 && y2 < y1) || (y1 == y2 && (m2 < m1 || (m1 == m2 && d2 < d1))))
            end.error(MB.text.InvalidEndDate);
    }
}

// used to track changes, handle validation, and update "action" accordingly

ko.extenders.field = function(observable, options) {
    var self = {
        observable: observable,
        relationship: options[0],
        name: options[1]
    }, validateAndCompare = options[2];

    observable.error = ko.observable("");
    observable.error.subscribe(errorChanged, self);
    observable.hasError = false;
    observable.changed = false;

    if (validateAndCompare !== false) {
        fieldChanged.call(self, observable());
        observable.subscribe(fieldChanged, self);
    }
    return observable;
};

var errorChanged = function(error) {
    var hasError = Boolean(error);

    if (hasError != this.observable.hasError)
        this.relationship.hasErrors(
            (this.relationship.errorCount += (hasError ? 1 : -1)) > 0);

    this.observable.hasError = hasError;
};

var fieldChanged = function(newValue) {
    newValue = ko.utils.unwrapObservable(newValue);
    var observable = this.observable, relationship = this.relationship, name = this.name;

    validationHandlers[name](observable, newValue, relationship);

    if (relationship.action.peek() == "add") return;

    var origValue = relationship.original_fields, fields = name.split("."), changed;
    for (var i = 0; i < fields.length; i++) origValue = origValue[fields[i]];

    // entities are unique, we compare them directly.
    /^entity/.test(name)
        ? (origValue = RE.Entity(origValue))
        : (newValue = ko.toJS(newValue));

    changed = !_.isEqual(origValue, newValue);

    if (changed != observable.changed)
        relationship.changeCount += (changed ? 1 : -1);

    observable.changed = changed;
    relationship.action(relationship.changeCount > 0 ? "edit" : "");
};


Fields.Integer = function(value) {
    this.value = ko.observable(this.convert(value));
    return ko.computed({read: this.value, write: this.write, owner: this});
};

Fields.Integer.prototype.write = function(newValue) {
    this.value(this.convert(newValue));
};

Fields.Integer.prototype.convert = function(value) {
    value = parseInt(ko.utils.unwrapObservable(value), 10);
    return isNaN(value) ? null : value;
};


Fields.PartialDate = function(obj) {
    obj = this.convert(obj);
    obj = {
        year:  new Fields.Integer(obj.year),
        month: new Fields.Integer(obj.month),
        day:   new Fields.Integer(obj.day)
    };
    obj.year.subscribe(this.partChanged, this);
    obj.month.subscribe(this.partChanged, this);
    obj.day.subscribe(this.partChanged, this);

    this.date = ko.observable(obj);
    delete obj;

    return ko.computed({read: this.date, write: this.write, owner: this});
};

Fields.PartialDate.prototype.write = function(obj) {
    obj = this.convert(obj);
    var date = this.date.peek();
    date.year(obj.year);
    date.month(obj.month);
    date.day(obj.day);
};

Fields.PartialDate.prototype.convert = function(obj) {
    obj = ko.utils.unwrapObservable(obj);
    obj = _.isString(obj) ? Util.parseDate(obj) : obj;
    obj = _.isObject(obj) ? obj : {};
    return obj;
};

Fields.PartialDate.prototype.partChanged = function() {
    this.date.notifySubscribers(this.date.peek());
};


Fields.Attribute = function(attr, value, relationship) {
    this.attr = attr;
    this.value = ko.observable(this.convert(value));
    this.relationship = relationship;

    return (ko.computed({read: this.value, write: this.write, owner: this})
        .extend({field: [relationship, "attrs." + attr.name, false]}));
};

Fields.Attribute.prototype.write = function(newValue) {
    newValue = this.convert(ko.utils.unwrapObservable(newValue));

    if (!_.isEqual(this.value(), newValue)) {
        this.value(newValue);
        var attrs = this.relationship.attrs;
        attrs.notifySubscribers(attrs.peek());
    }
};

Fields.Attribute.prototype.convert = function(value) {
    if (this.attr.children) {
        if (!_.isArray(value)) value = [value];

        return (_.chain(value)
            .map(function(n) {return parseInt(n, 10)})
            .compact().uniq().value()
            .sort(function(a, b) {return a - b}));
    } else {
        return Boolean($.isNumeric(value) ? parseInt(value, 10) : value);
    }
};

// if the relationship's link type changes (in the edit dialog, for example),
// it's convenient to be able to write directly to any attribute that's valid
// for the link type. the computed observable below (specifically,
// updateAttributes) makes sure that they exist.

Fields.Attributes = function(relationship) {
    this.value = {};
    this.relationship = relationship;
    return ko.computed({read: this.read, write: this.update, owner: this, deferEvaluation: true});
};

Fields.Attributes.prototype.read = function() {
    this.update({});
    return this.value;
};

Fields.Attributes.prototype.update = function(value) {
    var target = this.value, validAttrs = {}, self = this,
        typeInfo = Util.typeInfo(this.relationship.link_type()) || {};

    _.each(typeInfo.attrs || {}, function(info, id) {
        var attr = Util.attrInfo(id), name = attr.name;

        if (target[name] === undefined) {
            target[name] = new Fields.Attribute(attr, value[name], self.relationship);

        } else if (value[name] !== undefined) {
            target[name](value[name]);
        }
        validAttrs[name] = 1;
    });

    var allAttrs = MB.utility.keys(target), name, attr;

    for (var i = 0; name = allAttrs[i]; i++) {
        attr = target[name];

        if (validAttrs[name] === undefined) {
            if (attr.hasError) attr.error("");
            delete target[name];
        }
    }
};

Fields.Entity = function(entity, relationship) {
    this.entity = ko.observable(entity);
    this.relationship = relationship;
    return ko.computed({read: this.entity, write: this.write, owner: this});
};

Fields.Entity.prototype.write = function(entity) {
    var currentEntity = this.entity.peek();
    entity = RE.Entity(entity);

    if (currentEntity !== entity && currentEntity.type == entity.type) {
        this.entity(entity);
        this.relationship.entityChanged(currentEntity, entity);
    }
};

return RE;

}(MB.RelationshipEditor || {}));
