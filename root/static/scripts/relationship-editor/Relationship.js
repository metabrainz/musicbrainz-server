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

var UI = RE.UI = RE.UI || {}, Util = RE.Util = RE.Util || {},
    Fields = RE.Fields = RE.Fields || {}, cache = {};


RE.Relationship = function(obj) {
    var type0 = obj.entity[0].type, type1 = obj.entity[1].type, relationship, key;

    if (!obj.link_type) obj.link_type = defaultLinkType(type0, type1);
    if (!obj.id) obj.id = _.uniqueId("new-");

    key = [type0, type1, obj.id].join("-");
    return cache[key] || (cache[key] = new Relationship(obj));
};


var Relationship = function(obj) {
    var self = this;

    this.visible = false;
    this.id = obj.id;
    this.changeCount = 0;
    this.errorCount = 0;
    this.hasErrors = ko.observable(false);
    this.loadingWork = ko.observable(false);
    this.edits_pending = Boolean(obj.edits_pending);
    this.validateEntities = true;

    this.action = ko.observable(obj.action || "");
    this.link_type = new Fields.Integer(obj.link_type);
    this.attrs = new Fields.Attributes(this);
    this.period = {
        begin_date: new Fields.PartialDate(),
        end_date:   new Fields.PartialDate(),
        ended:      ko.observable(false)
    };

    var entity0 = RE.Entity(obj.entity[0]), entity1 = RE.Entity(obj.entity[1]);
    this.entity = [new Fields.Entity(entity0, this), new Fields.Entity(entity1, this)];
    this.type = entity0.type + "-" + entity1.type;

    this.fromJS(obj);
    this.dateRendering = ko.computed({read: this.renderDate, owner: this});
    this.original_fields = this.toJS();

    this.entity[0].extend({field: [this, "entity.0"]});
    this.entity[1].extend({field: [this, "entity.1"]});
    this.link_type.extend({field: [this, "link_type"]});
    this.attrs.extend({field: [this, "attrs"]});
    this.period.begin_date.extend({field: [this, "period.begin_date"]});
    this.period.end_date.extend({field: [this, "period.end_date"]});
    this.period.ended.extend({field: [this, "period.ended"]});
};


var defaultLinkType = function(type0, type1) {
    var linkType = Util.typeInfoByEntities(type0 + "-" + type1);
    if (!linkType) return null; else linkType = linkType[0];
    return linkType.descr ? linkType.id : linkType.children[0].id;
};


Relationship.prototype.toJS = function() {
    var entity0 = this.entity[0].peek(), entity1 = this.entity[1].peek();
    return {
        id:        this.action.peek() == "action" ? undefined : this.id,
        link_type: this.link_type.peek(),
        action:    this.action.peek(),
        period: {
            begin_date: ko.toJS(this.period.begin_date),
            end_date:   ko.toJS(this.period.end_date),
            ended:      this.period.ended.peek()
        },
        attrs:  ko.toJS(this.attrs),
        entity: [this.entity[0].peek().toJS(), this.entity[1].peek().toJS()]
    };
};


Relationship.prototype.fromJS = function(obj) {
    this.link_type(obj.link_type);
    this.period.begin_date((obj.period || {}).begin_date || "");
    this.period.end_date((obj.period || {}).end_date || "");
    this.period.ended(Boolean((obj.period || {}).ended));
    this.attrs(obj.attrs || {});
    this.entity[0](obj.entity[0]);
    this.entity[1](obj.entity[1]);
};


Relationship.prototype.target = function(source) {
    var entity0 = this.entity[0](), entity1 = this.entity[1]();
    return source === entity0 ? entity1 : entity0;
};


Relationship.prototype.entityChanged = function(oldEntity, newEntity) {
    var entity0 = this.entity[0].peek(), entity1 = this.entity[1].peek(), self = this;

    if (oldEntity !== entity0 && oldEntity !== entity1)
        oldEntity.relationships.remove(this);

    if (entity0.type == "recording" && entity1.type == "work" && newEntity === entity1) {
        oldEntity.performanceCount -= 1;
        newEntity.performanceCount += 1;

        this.loadingWork(true);

        $.get("/ws/js/entity/" + newEntity.gid + "?inc=rels")
            .success(function(data) {
                Util.parseRelationships(data);
            })
            .complete(function() {
                self.loadingWork(false);
            });

    } else if (this.visible && newEntity.relationships.indexOf(this) == -1)
        newEntity.relationships.push(this);

    if (oldEntity.type == "recording" && entity1.type == "work")
        oldEntity.performanceRelationships.remove(this);
};


Relationship.prototype.show = function() {
    if (this.type == "recording-work") {
        this.entity[0].peek().performanceRelationships.push(this);
        this.entity[1].peek().performanceCount += 1;
    } else {
        this.entity[0].peek().relationships.push(this);
        this.entity[1].peek().relationships.push(this);
    }
    this.visible = true;
};


Relationship.prototype.remove = function() {
    if (this.removed === true) return;
    var entity0 = this.entity[0].peek(), entity1 = this.entity[1].peek();

    if (this.type == "recording-work") {
        entity0.performanceRelationships.remove(this);
        entity1.performanceCount -= 1;

        if (entity1.performanceCount <= 0) {
            var relationships = entity1.relationships.slice(0);

            for (var i = 0; i < relationships.length; i++) {
                var relationship = relationships[i],
                    target = relationship.target(entity1);

                if (target.type != "work" || target.performanceCount <= 0)
                    relationship.remove();
            }
        }
    } else {
        entity0.relationships.remove(this);
        entity1.relationships.remove(this);
    }

    delete cache[this.type + "-" + this.id];
    this.removed = true;
    this.visible = false;
};

// Constructs the link phrase to display for this relationship

Relationship.prototype.linkPhrase = function (source) {
    var typeInfo = Util.typeInfo(this.link_type());
    var phrase = (source === this.entity[0]()) ?
        typeInfo.phrase : typeInfo.reverse_phrase;
    var attrs = {};

    _.each(this.attrs(), function(observable, name) {
        var value = observable();

        if (_.isArray(value) && value.length) {
            attrs[name] = _.map(value, function(v) {
                return Util.attrInfo(v).l_name;
            });
        } else if (value) {
            attrs[name] = [Util.attrRoot(name).l_name];
        }
    });

    return _.clean(phrase.replace(/\{(.*?)(?::(.*?))?\}/g,
            function (match, name, alts) {
        var values = attrs[name];
        if (alts) {
            alts = alts.split("|");
            if (values === undefined) {
                return alts[1] || "";
            } else {
                return alts[0].replace(/%/g, MB.utility.joinList(values));
            }
        } else {
            return values === undefined ? "" : MB.utility.joinList(values);
        }
    }));
};


function renderDate(date) {
    var year = date.year(), month = date.month(), day = date.day();

    month = month && _.pad(month, 2, "0");
    day = day && _.pad(day, 2, "0");

    return year ? year + (month ? "-" + month + (day ? "-" + day : "") : "") : "";
}

Relationship.prototype.renderDate = function() {
    var begin_date = renderDate(this.period.begin_date.peek()),
        end_date = renderDate(this.period.end_date.peek()),
        ended = this.period.ended();

    if (!begin_date && !end_date) return "";
    if (begin_date == end_date) return begin_date;

    return begin_date + " \u2013 " + (end_date || (ended ? "????" : ""));
};

// Construction of form fields

var buildField = function(prefix, obj, result) {
    if (_.isObject(obj) || _.isArray(obj)) {
        _.each(obj, function(value, name) {
            buildField(prefix + "." + name, value, result);
        });
    } else if (_.isBoolean(obj)) {
        result[prefix] = obj ? 1 : 0;
    } else if (_.isString(obj) || _.isNumber(obj)) {
        result[prefix] = obj;
    }
};

Relationship.prototype.buildFields = function(num, result) {
    var prefix = "rel-editor.rels." + num;
    buildField(prefix, this.toJS(), result);
    if (this.action.peek() == "add") delete result[prefix + ".id"];
};

// returns true if this relationship is a "duplicate" of the other.

Relationship.prototype.isDuplicate = function(other) {
    return (this.link_type.peek() == other.link_type.peek() &&
            this.entity[0].peek() === other.entity[0].peek() &&
            this.entity[1].peek() === other.entity[1].peek() &&
            Util.mergeDates(this.period.begin_date, other.period.begin_date) &&
            Util.mergeDates(this.period.end_date, other.period.end_date) &&
            _.isEqual(ko.toJS(this.attrs), ko.toJS(other.attrs)));
};


Relationship.prototype.openEdits = function() {
    var entity0 = RE.Entity(this.original_fields.entity[0]),
        entity1 = RE.Entity(this.original_fields.entity[1]);

    return _.sprintf(
        '/search/edits?auto_edit_filter=&order=desc&negation=0&combinator=and' +
        '&conditions.0.field=%s&conditions.0.operator=%%3D&conditions.0.name=%s' +
        '&conditions.0.args.0=%s&conditions.1.field=%s&conditions.1.operator=%%3D' +
        '&conditions.1.name=%s&conditions.1.args.0=%s&conditions.2.field=type' +
        '&conditions.2.operator=%%3D&conditions.2.args=90%%2C233&conditions.2.args=91' +
        '&conditions.2.args=92&conditions.3.field=status&conditions.3.operator=%%3D' +
        '&conditions.3.args=1&field=Please+choose+a+condition',
        encodeURIComponent(entity0.type),
        encodeURIComponent(entity0.name),
        encodeURIComponent(entity0.id),
        encodeURIComponent(entity1.type),
        encodeURIComponent(entity1.name),
        encodeURIComponent(entity1.id)
    );
};


Relationship.prototype.css = function() {
    var action = this.action();
    return _.trim((this.hasErrors() ? "error-field" : "") + " " + (action ? "rel-" + action : ""));
};

return RE;

}(MB.RelationshipEditor || {}));
