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

var Entity, cache = {}, fields = ["name", "id", "gid", "type", "sortname",
    "work_comment", "work_type_id", "work_language_id"];

// represents a core entitiy, either existing or newly-created.
// only "source" entities have relationships (recordings, works, the release).
// there's no need to keep track of relationships for target entities.
// Entity is private - modules use RE.Entity to find or create an entity.

Entity = function() {
    this.relationships = [];
};

// searches this entity's relationships for potential duplicate "rel"
// if it is a duplicate, remove and merge it

Entity.prototype.mergeRelationship = function(rel) {

    for (var i = 0; i < this.relationships.length; i++) {
        var other = this.relationships[i];

        if (rel !== other && rel.isDuplicate(other.fields)) {
            delete rel.fields.action;
            delete rel.fields.entity;
            $.extend(true, other.fields, rel.fields);
            rel.remove();
            other.update(null, true);
            return true;
        }
    }
    return false;
};

// used to clean up this.relationships, checking for orphaned rels that were
// removed from the page but still have internal representations

Entity.prototype.removeOrphans = function() {
    var rels = this.relationships.slice(0);

    for (var i = 0; i < rels.length; i++) {
        var rel = rels[i],
            // relationships that have no parent() aren't in the DOM
            $removed = rel.$container.filter(function() {
                return $(this).parent().length == 0;
            });
        // the relationship can still exist, e.g. a composer AR that
        // appeared under two different recording<->work ARs to the same work
        rel.$container = rel.$container.not($removed);
        if (rel.$container.length == 0) {
            this.relationships.splice(i, 1);
            rel.remove();
        } else {
            rel.resetARContainers();
        }
    }
};

// entities contain other cruft like relationships, $ars, etc.
// this gets the essential fields, used by RE.Relationship.createFields.
// like RE.Relationship, stuffing these in a fields attribute would work, but
// makes access far less convenient

Entity.prototype.getFields = function() {
    var foo = {}, field;
    for (var i = 0; field = fields[i]; i++)
        if (this[field]) foo[field] = this[field];
    return foo;
};


RE.Entity = function(obj) {
   if (!obj.gid) return;

    var ent, field;
    if ((ent = cache[obj.gid]) === undefined) {
        ent = cache[obj.gid] = new Entity;
    }
    // obj is usually passed in from json, and has its own relationships obj
    var rels = ent.relationships;
    $.extend(true, ent, obj);
    if (rels) ent.relationships = rels;
    return ent;
};


RE.Entity.isInstance = function(obj) {
    return obj instanceof Entity;
};

})();
