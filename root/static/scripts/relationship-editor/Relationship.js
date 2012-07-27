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

var UI = RE.UI, Util = RE.Util, Fields = RE.Fields, mapping, cache = {}, relcount = 0;


ko.bindingHandlers.action = {
    update: function(element, valueAccessor) {
        var relationship = ko.utils.unwrapObservable(valueAccessor()),
            action = relationship.action(), $element = $(element);

        $element
            .toggleClass("rel-remove disabled", action == "remove")
            .toggleClass("rel-add", action == "add")
            .toggleClass("rel-edit", action == "edit");
    }
};


var updateAttributes = function(relationship, target, value) {
    var validAttrs = {};

    Util.attrsForLinkType(relationship.link_type(), function(attr) {
        var name = attr.name;

        if (target[name] === undefined) {
            target[name] = Fields.Attribute(name, value[name], attr, relationship);

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


mapping = {
    // entities (source, target) have their own mapping options in Entity.js
    ignore:  ["source", "target", "num", "visible"],
    copy:    ["edits_pending", "id", "serverErrors"],
    include: ["link_type", "num", "action", "direction", "ended", "begin_date",
              "end_date", "attributes"],
    attributes: {
        update: function(options) {return $.extend(true, {}, options.data)}
    },
    begin_date: {
        update: function(options) {
            var data = options.data, date = options.target;
            data = typeof data == "string" ? Util.parseDate(data) : data;
            date.year(data.year);
            date.month(data.month);
            date.day(data.day);
            return date;
        }
    },
    ended: {
        update: function(options) {return Boolean(options.data)}
    }
};

mapping.end_date = mapping.begin_date;


RE.Relationship = function(obj, tryToMerge) {
    obj.link_type = obj.link_type || Util.defaultLinkType(obj.source.type, obj.target.type);
    var type = Util.type(obj.link_type), relationship, _cache;

    if ((_cache = cache[type]) === undefined) _cache = cache[type] = {};
    if (obj.id === undefined) obj.id = Util.ID();

    if ((relationship = _cache[obj.id]) === undefined)
        relationship = _cache[obj.id] = new Relationship(obj);

    if (tryToMerge && relationship.source.mergeRelationship(relationship)) {
        delete _cache[obj.id];
        return null;
    }
    return relationship;
};


var Relationship = function(obj) {
    var self = this;

    this.exists = false; // new relationships still being edited don't exist

    this.id = obj.id;
    this.num = relcount += 1;
    this.changeCount = 0;
    this.errorCount = 0;
    this.action = ko.observable(obj.action || "");
    this.hasErrors = ko.observable(Boolean(obj.serverErrors));

    if (this.hasErrors())
        this.errorCount = MB.utility.keys(obj.serverErrors).length;

    this.link_type = Fields.Integer(obj.link_type).extend({field: [this, "link_type"]});
    this.begin_date = Fields.PartialDate(Util.parseDate(""));
    this.end_date = Fields.PartialDate(Util.parseDate(""));
    this.ended = ko.observable(false);
    this.direction = ko.observable("forward");

    // computed observables alert their subscribers even when the value doesn't
    // change, which we don't want, so this is mainly boilerplate to prevent that.
    this.type = (function() {
        var value = ko.observable(null);

        ko.computed(function() {
            value(Util.type(self.link_type()));
        });
        return value;
    })();

    this.dateRendering = ko.computed(function() {
        return self.renderDate();
    }).extend({throttle: 10});

    // entities have a refcount so that they can be deleted when they aren't
    // referenced by any relationship. we use a computed observable for the target,
    // so that we don't have to remember to decrement the refcount each time the
    // target changes.

    obj.source.refcount += 1;
    this.source = obj.source; // source can't change

    obj.target.refcount += 1;
    var target = ko.observable(obj.target);

    this.target = ko.computed({
        read: target,
        write: function(newValue) {
            var oldTarget = target(),
                newTarget = RE.Entity(ko.utils.unwrapObservable(newValue));

            if (oldTarget !== newTarget) {
                // we no longer want validation notifications for this entity's name
                self.target.nameSubs[self.id].dispose();
                delete self.target.nameSubs[self.id];

                self.changeTarget(oldTarget, newTarget, target);
            }
        }
    }).extend({field: [self, "target"]});

    // XXX trigger the validation subscription's callback, so that validation
    // on the target's name is registered as well. that'll get added to
    // target.nameSub.
    this.target.validationSub.callback(obj.target);

    // if the relationship's link type changes (in the edit dialog, for example),
    // it's convenient to be able to write directly to any attribute that's valid
    // for the link type. the computed observable below makes sure that they exist.

    this.attributes = (function() {
        var value = {};
        return ko.computed({
            read: function() {
                updateAttributes(self, value, {});
                return value;
            },
            write: function(newValue) {
                updateAttributes(self, value, newValue);
            },
            deferEvaluation: true
        });
    })();

    ko.mapping.fromJS(obj, mapping, this);

    // add these *after* pulling in the obj mapping, otherwise they'll mark the
    // relationship as having changes.
    this.begin_date.extend({field: [this, "begin_date"]});
    this.end_date.extend({field: [this, "end_date"]});
    this.ended.extend({field: [this, "ended"]});
    this.direction.extend({field: [this, "direction"]});
    this.attributes.extend({field: [this, "attributes"]});

    this.entity = ko.computed(function() {
        var src = Util.src(self.link_type(), self.direction());
        return src == 0 ? [self.source, self.target()] : [self.target(), self.source];
    });

    this.linkPhrase = ko.computed(self.buildLinkPhrase, this).extend({throttle: 10});
    this.hiddenFields = ko.computed(this.buildFields, this).extend({throttle: 100});
    this.loadingWork = ko.observable(false);

    this.edits_pending
        ? (this.openEdits = ko.computed(this.buildOpenEdits, this))
        : (this.edits_pending = false);

    delete this.serverErrors;
    delete obj;
};


Relationship.prototype.changeTarget = function(oldTarget, newTarget, observable) {
    if (oldTarget) oldTarget.remove();

    observable(newTarget);
    newTarget.refcount += 1;

    if (oldTarget.type != newTarget.type) {
        // the type changed. our relationship cache is organized by type, so we
        // have to move the position of this relationship in the cache.
        var oldType = Util.type(this.link_type()), newType;

        this.link_type(Util.defaultLinkType(this.source.type, newTarget.type));
        newType = Util.type(this.link_type());

        (cache[newType] = cache[newType] || {})[this.id] = cache[oldType][this.id];
        delete cache[oldType][this.id];
    }

    if (this.type() == "recording-work")
        this.workChanged(newTarget);
};

// if the user changed a work, we need to request its relationships.

var worksLoading = {};

Relationship.prototype.workChanged = function(work) {
    var gid = work.gid, self = this;
    if (!Util.isMBID(gid) || worksLoading[gid]) return;

    this.loadingWork(true);
    worksLoading[gid] = 1;

    $.get("/ws/js/entity/" + gid + "?inc=rels")
        .success(function(data) {
            Util.parseRelationships(data, false);
        })
        .complete(function() {
            self.loadingWork(false);
            delete worksLoading[gid];
        });
};


Relationship.prototype.show = function() {
    var source = this.source;
    if (this.type.peek() == "recording-work") {
        if (source.performanceRelationships.peek().indexOf(this) == -1) {
            source.performanceRelationships.push(this);
            this.target.peek().performanceRefcount += 1;
        }
    } else {
        if (source.relationships.peek().indexOf(this) == -1)
            source.relationships.push(this);
    }
    this.exists = true;
};


Relationship.prototype.reset = function(obj) {
    this.hasErrors(false);
    var fields = RE.serverFields[this.type()][this.id];

    if (fields) {
        ko.mapping.fromJS(fields, this);
        this.target(fields.target);
    }
};


Relationship.prototype.remove = function() {
    var recordingWork = (this.type() == "recording-work"), target = this.target();

    if (recordingWork) {
        this.source.performanceRelationships.remove(this);
        target.performanceRefcount -= 1;
    } else {
        this.source.relationships.remove(this);
    }

    this.source.remove();
    target.remove();

    if (recordingWork && target.performanceRefcount <= 0) {
        var relationships = target.relationships.slice(0);

        for (var i = 0; i < relationships.length; i++)
            relationships[i].remove();
    }
    delete cache[this.type()][this.id];
    this.exists = false;
};

// Constructs the link phrase to display for this relationship

Relationship.prototype.buildLinkPhrase = function() {
    var typeInfo = RE.typeInfo[this.link_type()];
    if (!typeInfo) return "";

    var attrs = {}, m, phrase = this.source === this.entity()[0]
        ? typeInfo.link_phrase : typeInfo.reverse_link_phrase;

    $.each(this.attributes(), function(name, observable) {
        var value = observable(), str = name, isArray = $.isArray(value);

        if (!value || isArray && !value.length) return;
        if (isArray) {
            value = $.map(value, function(v) {return RE.attrMap[v].name});

            var list = value.slice(0, -1).join(", ");
            str = (list && list + " & ") + (value.pop() || "");
        }
        attrs[name] = str;
    });
    while (m = phrase.match(/\{(.*?)(?::(.*?))?\}/)) {
        var replace = attrs[m[1]] !== undefined
            ? (m[2] && m[2].split("|")[0]) || attrs[m[1]]
            : (m[2] && m[2].split("|")[1]) || "";
        phrase = phrase.replace(m[0], replace).replace("  ", " ");
    }
    return $.trim(phrase);
};


Relationship.prototype.renderDate = function() {
     var begin_date = this.begin_date.render(), end_date = this.end_date.render(),
        ended = this.ended();

    if (!begin_date && !end_date) return "";
    if (begin_date == end_date) return MB.text.Date.on + " " + begin_date;

    return (begin_date ? MB.text.Date.from + " " + begin_date + " \u2013" : MB.text.Date.until) + " " +
           (end_date ? end_date : (ended ? "????" : MB.text.Date.present));
};

// Contruction of hidden input fields

var simpleFields, dateFields, entityFields, fieldHTML, buildField;

simpleFields = ["id", "link_type", "action", "direction", "ended"];
dateFields   = ["year", "month", "day"];
entityFields = ["id", "gid", "name", "type", "sortname", "comment", "work_type", "work_language"];

fieldHTML = function(num, name, value) {
    var name = "rel-editor.rels." + num + "." + name;
    return MB.html.input({type: "hidden", name: name, value: value});
};

buildField = function(num, obj, name, fields) {
    var field, value, prefix = name && name + ".", result = "";

    for (var i = 0; field = fields[i]; i++) {
        value = ko.utils.unwrapObservable(obj[field]);

        if (value) {
            field = prefix + field;

            if ($.isArray(value)) {
                for (var j = 0; j < value.length; j++)
                    result += fieldHTML(num, field + "." + j, value[j]);

            } else {
                if (typeof value == "boolean") value = value ? "1" : "0";
                result += fieldHTML(num, field, value);
            }
        }
    }
    return result;
};

Relationship.prototype.buildFields = function() {
    if (!this.action()) return "";
    var result = "", attrs = MB.utility.keys(this.attributes()), n = this.num;

    result += buildField(n, this, "", simpleFields);
    result += buildField(n, this.begin_date(), "begin_date", dateFields);
    result += buildField(n, this.end_date(), "end_date", dateFields);
    result += buildField(n, this.attributes(), "attrs", attrs);
    result += buildField(n, this.entity()[0], "entity.0", entityFields);
    result += buildField(n, this.entity()[1], "entity.1", entityFields);

    return result;
};

// returns true if this relationship is a "duplicate" of the other.
// doesn't compare attributes

Relationship.prototype.isDuplicate = function(other) {
    var thisent = this.entity(), otherent = other.entity();
    return (this.link_type() == other.link_type() &&
            thisent[0] === otherent[0] && thisent[1] === otherent[1]);
};


Relationship.prototype.buildOpenEdits = function() {
    var orig = RE.serverFields[this.type()][this.id],
        source = this.source, target = orig.target;

    return '/search/edits?auto_edit_filter=&order=desc&negation=0&combinator=and' +
        '&conditions.0.field=' + encodeURIComponent(source.type) +
        '&conditions.0.operator=%3D' +
        '&conditions.0.name=' + encodeURIComponent(source.name()) +
        '&conditions.0.args.0=' + encodeURIComponent(source.id) +
        '&conditions.1.field=' + encodeURIComponent(target.type) +
        '&conditions.1.operator=%3D' +
        '&conditions.1.name=' + encodeURIComponent(target.name()) +
        '&conditions.1.args.0=' + encodeURIComponent(target.id) +
        '&conditions.2.field=type&conditions.2.operator=%3D&conditions.2.args=90%2C233' +
        '&conditions.2.args=91&conditions.2.args=92&conditions.3.field=status' +
        '&conditions.3.operator=%3D&conditions.3.args=1&field=Please+choose+a+condition';
};

})();
