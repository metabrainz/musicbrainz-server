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

var Entity, Source, Artist, Label, Recording, Release, ReleaseGroup, Work, URL,
    entities, mapping, cache = {};

mapping = {
    copy:    ["type", "gid", "id", "artistCredit", "number", "position", "length"],
    ignore:  ["refcount", "relationships", "artist", "artists", "label", "value", "isrcs", "artist_credit"],
    include: ["type", "gid", "id", "name", "sortname", "newWork", "comment", "work_type", "work_language"]
};

// represents a core entitiy, either existing or newly-created.
// Entity is private - modules use RE.Entity to find or create an entity.

Entity = function() {};

Entity.prototype.init = function() {
    this.refcount = 0;
    this.name = ko.observable("");

    this.rendering = ko.computed({
        read: renderEntity,
        owner: this,
        deferEvaluation: true
    });
};

Entity.prototype.render = function(name, options) {
    options = $.extend({
        href: "/" + this.type + "/" + this.gid,
        target: "_blank"
    }, options);
    return MB.html.a(options, name);
};

function renderEntity() {
    return this.render(this.name());
}

Entity.prototype.remove = function() {
    if (--this.refcount == 0) delete cache[this.gid];
};

Source = function() {};

Source.prototype = new Entity;

Source.prototype.init = function() {
    Entity.prototype.init.call(this);
    this.relationships = ko.observableArray([]);
};

// searches this entity's relationships for potential duplicate "rel"
// if it is a duplicate, remove and merge it

Source.prototype.mergeRelationship = function(rel) {
    var relationships = rel.type.peek() == "recording-work"
            ? this.performanceRelationships() : this.relationships(),
        obj = ko.mapping.toJS(rel);

    delete obj.id;
    delete obj.action;

    // XXX figure out a faster/nicer way to merge relationship attributes
    var attrs = $.extend({}, obj.attributes),
        attrNames = MB.utility.keys(obj.attributes), name, value;

    for (var i = 0; i < relationships.length; i++) {
        var other = relationships[i];

        if (rel !== other && rel.isDuplicate(other)) {

            obj.attributes = {};
            for (var i = 0; name = attrNames[i]; i++) {
                value = obj.attributes[name] = attrs[name];

                if (!value || ($.isArray(value) && !value.length))
                    obj.attributes[name] = other.attributes.peek()[name].peek();
            }

            // Merge the dates here, otherwise ko.mapping.fromJS would overwrite
            // them with whatever is in obj.begin_date and obj.end_date.
            other.begin_date(RE.Util.mergeDates(rel.begin_date, other.begin_date));
            other.end_date(RE.Util.mergeDates(rel.end_date, other.end_date));
            delete obj.begin_date;
            delete obj.end_date;

            ko.mapping.fromJS(obj, other);
            rel.remove();
            return true;
        }
    }
    return false;
};

Artist = function() {
    this.init();
    this.sortname = ko.observable("");

    this.rendering = ko.computed({
        read: renderArtist,
        owner: this,
        deferEvaluation: true
    });
};

function renderArtist() {
    return this.render(this.name(), {title: this.sortname()});
}

Label = function() {
    this.init();
};

Recording = function() {
    this.init();
    this.performanceRelationships = ko.observableArray([]);
};

Release = function() {
    this.init();
};

ReleaseGroup = function() {
    this.init();
};

Work = function() {
    this.init();
    this.performanceRefcount = 0;
    this.comment = ko.observable("");
    this.work_type = ko.observable(null);
    this.work_language = ko.observable(null);
};

URL = function() {
    this.init();

    this.rendering = ko.computed({
        read: renderURL,
        owner: this,
        deferEvaluation: true
    });
};

function renderURL() {
    var name = _.prune(this.name(), 50);
    return this.render(name, {href: this.name()});
}

Artist.prototype = new Entity;
Label.prototype = new Entity;
Recording.prototype = new Source;
Release.prototype = new Source;
ReleaseGroup.prototype = new Source;
Work.prototype = new Source;
URL.prototype = new Entity;

entities = {
    artist:        Artist,
    label:         Label,
    recording:     Recording,
    release:       Release,
    release_group: ReleaseGroup,
    work:          Work,
    url:           URL
};

RE.Entity = function(obj, type) {
    if (obj instanceof Entity) return obj;
    obj.type = obj.type || type;

    var ent;
    if ((ent = cache[obj.gid]) === undefined)
        ent = cache[obj.gid] = new entities[obj.type];

    ko.mapping.fromJS(obj, mapping, ent);
    return ent;
};

RE.Entity.isInstance = function(obj) {
    return obj instanceof Entity;
};

return RE;

}(MB.RelationshipEditor || {}));
