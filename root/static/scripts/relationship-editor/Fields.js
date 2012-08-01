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

var Fields = RE.Fields = RE.Fields || {}, Util = RE.Util = RE.Util || {},
    daysInMonth, validationHandlers;

daysInMonth = {
    "true":  [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
    "false": [0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
};

validationHandlers = {

    link_type: function(field, value) {
        var typeInfo = RE.typeInfo[value];

        if (!typeInfo) {
            field.error(MB.text.PleaseSelectARType);
        } else if (!typeInfo.descr) {
            field.error(MB.text.PleaseSelectARSubtype);
        }
    },

    begin_date: function(field, value) {
        var y = value.year(), m = value.month(), d = value.day(), leapYear;

        if (y !== null || m !== null || d !== null) {
            leapYear = (y % 400 ? (y % 100 ? !Boolean(y % 4) : false) : true).toString();

            if (y === null || (d !== null && m === null) || y < 1 || (m !== null &&
                (m < 1 || m > 12 || (d !== null && (d < 1 || d > daysInMonth[leapYear][m]))))) {

                field.error(MB.text.InvalidDate);
                return;
            }
        }
        field.error("");
    },

    ended: function(field, value) {
        typeof value == "boolean" ? field.error("") : field.error(MB.text.InvalidValue);
    },

    direction: function(field, value) {
        (value == "forward" || value == "backward")
            ? field.error("") : field.error(MB.text.InvalidValue);
    },

    attributes: function(field, value, relationship) {
        var linkType = relationship.link_type(), typeInfo = RE.typeInfo[linkType];
        if (!typeInfo) return;

        $.each(value, function(name, observable) {
            var root = RE.attrRoots[name], attrInfo = typeInfo.attrs[root.id],
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

    target: function(field, value, relationship) {
        // currently the only thing we're validating is that the name's not empty.
        // given that the target can be attached to multiple relationships,
        // nameSubs is added to the observable to keep track of subscriptions to
        // the target's name for each relationship, and for disposing them if the
        // target changes. this isn't ideal if validation is expanded to other fields.

        var checkName = function(name) {
            name ? field.error("") : field.error(MB.text.RequiredField);
        };
        checkName(value.name());

        (field.nameSubs = field.nameSubs || {})[relationship.id] =
            value.name.subscribe(checkName);
    }
};

validationHandlers.end_date = function(field, value, relationship) {
    validationHandlers.begin_date(field, value);

    var begin_date = relationship.begin_date;

    if (!field.error.peek() && !begin_date.error.peek()) {

        var b = field(), a = begin_date(),
            y1 = a.year(), m1 = a.month(), d1 = a.day(),
            y2 = b.year(), m2 = b.month(), d2 = b.day();

        if ((y1 && y2 && y2 < y1) || (y1 == y2 && (m2 < m1 || (m1 == m2 && d2 < d1))))
            field.error(MB.text.InvalidEndDate);
    }
}

var compareDates, compareAttr, compareAttrs;

compareDates = function(a, b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
};

compareAttr = function(a, b) {
    if (typeof a == "boolean" && a != b) return false;
    if ($.isArray(a) && ($(a).not(b).length > 0 || $(b).not(a).length > 0)) return false;
    return true;
};

compareAttrs = function(a, b) {
    var name;
    // we can assume they have the same keys, since we use attrsForLinkType to
    // make sure a relationship has all attributes for their link type
    for (name in a) if (!compareAttr(a[name], b[name])) return false;
    return true;
};

// used to track changes, handle validation, and update "action" accordingly

ko.extenders.field = function(target, options) {

    var relationship = options[0], name = options[1], fullName = options[2] || name,
        id = relationship.id, type = relationship.type;

    target.error = ko.observable((relationship.serverErrors &&
        relationship.serverErrors[fullName]) || "");
    target.hasError = Boolean(target.error());

    target.errorSub = target.error.subscribe(function(error) {
        var hasError = Boolean(error);

        if (hasError != target.hasError) {
            relationship.errorCount += (hasError ? 1 : -1);
            relationship.hasErrors(relationship.errorCount > 0);
        }
        target.hasError = hasError;
    })
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

        var origValue, changed;
        // properties might not have been defined originally
        try {origValue = RE.serverFields[type()][id][name]} catch (err) {};

        // dates/attributes are special cases since they're compound fields
        if (name == "attributes") {
            changed = !compareAttrs(origValue, newValue);
        } else if (name == "begin_date" || name == "end_date") {
            changed = !compareDates(origValue, newValue);
        } else {
            changed = (newValue !== origValue);
        }
        if (changed != target.changed) {
            relationship.changeCount += (changed ? 1 : -1);
        }
        target.changed = changed;
        relationship.action(relationship.changeCount > 0 ? "edit" : "");
    });

    return target;
};


Fields.Integer = function(value) {
    function convert(val) {
        val = parseInt(ko.utils.unwrapObservable(val), 10);
        return isNaN(val) ? null : val;
    };
    value = ko.observable(convert(value));

    return ko.computed({
        read:  value,
        write: function(newValue) {value(convert(newValue))}
    });
};


Fields.PartialDate = function(obj) {

    var value = ko.observable({
        year:  Fields.Integer(obj.year),
        month: Fields.Integer(obj.month),
        day:   Fields.Integer(obj.day)
    });

    delete obj;
    var date = value(), partChanged = function() {value.notifySubscribers(date)};

    date.year.subscribe(partChanged);
    date.month.subscribe(partChanged);
    date.day.subscribe(partChanged);

    value.render = function() {
        var year = date.year(), month = date.month(), day = date.day();
        return year ? year + (month ? "-" + month + (day ? "-" + day : "") : "") : "";
    }

    return value;
};


Fields.Attribute = function(name, value, attr, relationship) {
    value = ko.observable(Util.convertAttr(attr, value));

    return ko.computed({
        read: value,
        write: function(newValue) {
            newValue = Util.convertAttr(attr, ko.utils.unwrapObservable(newValue));

            if (!compareAttr(value(), newValue)) {
                value(newValue);
                relationship.attributes.notifySubscribers(relationship.attributes());
            }
        }
    }).extend({field: [relationship, null, "attrs." + name, true]});
};

return RE;

}(MB.RelationshipEditor || {}));
