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

var RelationshipEditor = {
    Util: {},
    server_fields: {},
    relationships: {},
    works_loading: {},
}, RE = RelationshipEditor;

(function() {

var Util = RE.Util;

// "source" is the entity on the page the user is adding the
// relationship to, not the technical source of the relationship.
// (e.g. for an artist-recording rel, it's the recording.)

RE.processRelationship = function(obj, source, check_post, compare) {
    var fields = obj.fields, id = fields.id, rel, update = false, $c,
        relationships, type = Util.typestr(fields.link_type);

    if ((relationships = RE.relationships[type]) === undefined) {
        relationships = RE.relationships[type] = {};
    }
    if (id && (rel = relationships[id]) !== undefined) {
        update = true;
    } else {
        var target = fields.entity[1 - Util.src(fields.link_type, fields.direction)];
        rel = new RE.Relationship(obj, source, target, compare);

        if (id) {
            relationships[id] = rel;
        } else if (source.mergeRelationship(rel)) {
            return;
        }
        if (check_post && !Util.isMBID(rel.target.gid))
            processAddedRelationships(rel.target);
    }
    rel.cloneInto(type == "recording-work" ? rel.source.$work_ars : rel.source.$ars);
    if (update && !rel.fields.action) rel.update(obj, compare);
    return rel;
};

// check_post is a flag indicating that we're checking for posted
// relationships for source in edited_rels, added_rels, and removed_rels.
// this is only set on page load.

RE.parseRelationships = function(source, check_post) {
    if (!source.relationships) return;

    var source_entity = RE.Entity(source),
        entity_types = MB.utility.keys(source.relationships);

    for (var i = 0; entity_type = entity_types[i]; i++) {
        if (entity_type == "url") continue; // skip URLs for now
        if (source.type == "work" && entity_type == "recording") continue;

        var rels_by_type = source.relationships[entity_type],
            rel_types = MB.utility.keys(rels_by_type), rels, obj;

        for (var j = 0; rels = rels_by_type[rel_types[j]]; j++) {
            for (var k = 0; obj = rels[k]; k++) {
                obj.target.type = entity_type;
                parseRelationship(obj, source_entity, check_post);
            }
        }
    }
    if (check_post) processAddedRelationships(source_entity);
};

var parseRelationship = function(obj, source, check_post) {
    var result = {}, fields = result.fields = {
        id: obj.id, link_type: obj.link_type, attrs: obj.attributes, entity: []
    };
    if (obj.direction && source.type == obj.target.type)
        fields.direction = obj.direction;

    if (obj.begin_date) fields.begin_date = Util.parseDate(obj.begin_date);
    if (obj.end_date) fields.end_date = Util.parseDate(obj.end_date);
    if (obj.ended == 1) fields.ended = 1;

    result.edits_pending = Boolean(obj.edits_pending);

    var compare = false, type = Util.typestr(obj.link_type), edited, removed,
        work_rels = type == "recording-work" && obj.target.relationships,
        server = (RE.server_fields[type] = RE.server_fields[type] || {})
                 [fields.id] = $.extend(true, {}, fields), src;

    src = Util.src(obj.link_type, obj.direction);
    fields.entity[src] = server.entity[src] = source;
    fields.entity[1 - src] = server.entity[1 - src] = RE.Entity(obj.target);

    if (check_post && (edited = Util.CGI.edited(fields))) {
        compare = true;

        if (edited.has_errors) {
            result.has_errors = true;
            delete edited.has_errors;
        }
        fields = result.fields = edited;
        src = Util.src(fields.link_type, fields.direction || obj.direction);
        fields.entity[src] = source = fields.entity[src];
        fields.entity[1 - src] = fields.entity[1 - src];

        if (work_rels && fields.entity[1] !== server.entity[1]) work_rels = false;
    }
    var rel = RE.processRelationship(result, source, check_post, compare);

    if (check_post && (removed = Util.CGI.removed(fields))) {
        if (removed.has_errors) rel.has_errors = true;

        if (rel.fields.action != "remove") {
            var button = rel.$container.eq(0).children("a.remove-button")[0];
            RE.UI.Buttons.Remove.clicked.call(button, null);
        }
    }
    if (work_rels) RE.parseRelationships(obj.target, check_post);
};

var processAddedRelationships = function(source) {
    var added = Util.CGI.added(source.gid);
    if (added === undefined) return;

    for (var i = 0; i < added.length; i++) {
        var fields = added[i], rel = {}, types = RE.type_info[fields.link_type].types;

        if (fields.has_errors) {
            rel.has_errors = true;
            delete fields.has_errors;
        }
        rel.fields = fields;
        RE.processRelationship(rel, source, true, false);
    }
};

})();
