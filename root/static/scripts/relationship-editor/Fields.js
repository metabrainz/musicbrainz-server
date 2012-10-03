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
    },

    begin_date: function(field, value, relationship) {
        validateDatePeriod(field, relationship.end_date, validateDate(field, value));
    },

    end_date: function(field, value, relationship) {
        validateDatePeriod(relationship.begin_date, field, null, validateDate(field, value));
    },

    ended: function(field, value) {
        _.isBoolean(value) ? field.error("") : field.error(MB.text.InvalidValue);
    },

    backward: function(field, value) {
        field.error(_.isBoolean(value) ? "" : MB.text.InvalidValue);
    },

    attributes: function(field, value, relationship) {
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

    target: function(field, value) {
        field.error(Util.isMBID(value.gid) ? "" : MB.text.RequiredField);
    }
};

function validateDate(field, value) {
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

ko.extenders.field = function(target, options) {
    var relationship = options[0], name = options[1], fullName = options[2] || name;

    target.error = ko.observable("");
    target.hasError = false;

    target.errorSub = target.error.subscribe(function(error) {
        var hasError = Boolean(error);

        if (hasError != target.hasError) {
            relationship.errorCount += (hasError ? 1 : -1);
            relationship.hasErrors(relationship.errorCount > 0);
        }
        target.hasError = hasError;
    });

    delete fullName;
    var noValidationOrComparison = options[3];

    if (!noValidationOrComparison)
        target.validationSub = target.subscribe(function(value) {
            validationHandlers[name](target, value, relationship);
        });

    if (relationship.action.peek() == "add" || noValidationOrComparison) return target;

    target.changed = false;

    target.subscribe(function(newValue) {
        newValue = ko.utils.unwrapObservable(newValue);
        // entities are unique, we compare them directly.
        if (name != "target") newValue = ko.mapping.toJS(newValue);

        var origValue = Util.originalFields(relationship, name),
            changed = !_.isEqual(origValue, newValue);

        if (changed != target.changed)
            relationship.changeCount += (changed ? 1 : -1);

        target.changed = changed;
        relationship.action(relationship.changeCount > 0 ? "edit" : "");
    });

    return target;
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
}

Fields.PartialDate.prototype.convert = function(obj) {
    obj = ko.utils.unwrapObservable(obj);
    obj = _.isString(obj) ? Util.parseDate(obj) : obj;
    obj = _.isObject(obj) ? obj : {};
    return obj;
};

Fields.PartialDate.prototype.partChanged = function() {
    this.date.notifySubscribers(this.date.peek());
};


var Attribute = function(name, value, attr, relationship) {
    this.value = ko.observable(Util.convertAttr(attr, value));
    this.attr = attr;
    this.relationship = relationship;

    return (ko.computed({read: this.value, write: this.write, owner: this})
        .extend({field: [relationship, null, "attrs." + name, true]}));
};


Attribute.prototype.write = function(newValue) {
    newValue = Util.convertAttr(this.attr, ko.utils.unwrapObservable(newValue));

    if (!_.isEqual(this.value(), newValue)) {
        this.value(newValue);
        var attrs = this.relationship.attributes;
        attrs.notifySubscribers(attrs());
    }
};

// if the relationship's link type changes (in the edit dialog, for example),
// it's convenient to be able to write directly to any attribute that's valid
// for the link type. the computed observable below (specifically,
// updateAttributes) makes sure that they exist.

Fields.Attributes = function(relationship) {
    this.value = {};
    this.relationship = relationship;
    return ko.computed({read: this.read, write: this.write, owner: this, deferEvaluation: true});
};

Fields.Attributes.prototype.read = function() {
    this.update({});
    return this.value;
};

Fields.Attributes.prototype.write = function(newValue) {
    this.update(newValue);
};

Fields.Attributes.prototype.update = function(value) {
    var target = this.value, validAttrs = {}, self = this;

    Util.attrsForLinkType(this.relationship.link_type(), function(attr) {
        var name = attr.name;

        if (target[name] === undefined) {
            target[name] = new Attribute(name, value[name], attr, self.relationship);

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

            attr.errorSub.dispose();
            delete target[name];
        }
    }
};


Fields.Target = function(target, relationship) {
    this.target = ko.observable(target);
    this.relationship = relationship;

    this.computed = ko.computed({read: this.target, write: this.write, owner: this})
        .extend({field: [relationship, "target"]});

    return this.computed
};

Fields.Target.prototype.write = function(newTarget) {
    var relationship = this.relationship, oldTarget = this.target(),
        newTarget = RE.Entity(ko.utils.unwrapObservable(newTarget));

    if (oldTarget !== newTarget)
        relationship.changeTarget(oldTarget, newTarget, this.target);
}

return RE;

}(MB.RelationshipEditor || {}));
