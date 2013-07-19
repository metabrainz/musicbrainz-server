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

// represents a core entitiy, either existing or newly-created.
// Entity is private - modules use RE.Entity to find or create an entity.

var Entity = function() {};

Entity.prototype.init = function(obj) {
    obj = obj || {};
    this.gid = obj.gid;
    this.id = obj.id;
    this.name = obj.name || "";
    this.relationships = ko.observableArray([]);

    var options = {href: "/" + this.type + "/" + this.gid, target: "_blank"};
    if (obj.sortname) options.title = obj.sortname;
    this.rendering = MB.html.a(options, this.name);

    if (obj.comment) {
        this.rendering += " <span class=\"comment\">(" +
            _.escape(obj.comment) + ")</span>";
    }
};

Entity.prototype.toJS = function() {
    return {gid: this.gid, type: this.type};
};

// searches this entity's relationships for potential duplicate "rel"
// if it is a duplicate, remove and merge it

Entity.prototype.mergeRelationship = function(rel) {
    var relationships = (rel.type == "recording-work")
            ? this.performanceRelationships() : this.relationships();

    for (var i = 0; i < relationships.length; i++) {
        var other = relationships[i];

        if (rel !== other && rel.isDuplicate(other)) {
            var obj = rel.toJS();
            delete obj.id;
            delete obj.action;

            obj.period.begin_date = RE.Util.mergeDates(rel.period.begin_date, other.period.begin_date);
            obj.period.end_date = RE.Util.mergeDates(rel.period.end_date, other.period.end_date);

            other.fromJS(obj);
            rel.remove();

            return true;
        }
    }
    return false;
};

Artist = function(obj) {
    obj = obj || {};
    this.init(obj);
    this.sortname = ko.observable(obj.sortname);
};

Artist.prototype = new Entity;
Artist.prototype.type = "artist";

Label = function(obj) {
    this.init(obj);
};

Label.prototype = new Entity;
Label.prototype.type = "label";

Recording = function(obj) {
    obj = obj || {};
    this.init(obj);
    this.number = obj.number;
    this.position = obj.position;
    this.length = obj.length;
    this.artistCredit = obj.artistCredit;
    this.performanceRelationships = ko.observableArray([]);
};

Recording.prototype = new Entity;
Recording.prototype.type = "recording";

Release = function(obj) {
    this.init(obj);
};

Release.prototype = new Entity;
Release.prototype.type = "release";

ReleaseGroup = function(obj) {
    this.init(obj);
};

ReleaseGroup.prototype = new Entity;
ReleaseGroup.prototype.type = "release_group";

Work = function(obj) {
    obj = obj || {};
    this.init(obj);
    this.performanceCount = 0;
    this.comment = ko.observable(obj.comment || "");
    this.work_type = ko.observable(obj.work_type || null);
    this.work_language = ko.observable(obj.work_language || null);
};

Work.prototype = new Entity;
Work.prototype.type = "work";

RE.Entity = (function() {
    var entities = {
        artist:        Artist,
        label:         Label,
        recording:     Recording,
        release:       Release,
        release_group: ReleaseGroup,
        work:          Work
    }, cache = {};

    return function(obj, type) {
        if (obj instanceof Entity) return obj;
        if (obj.gid) return cache[obj.gid] || (cache[obj.gid] = new entities[type || obj.type](obj));
        return new entities[type || obj.type](obj);
    };
}());

RE.Entity.isInstance = function(obj) {
    return obj instanceof Entity;
};

return RE;

}(MB.RelationshipEditor || {}));
