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
    server_fields: {},
    relationships: {},
    works_loading: {},
}, RE = RelationshipEditor;

// "source" is the entity on the page the user is adding the
// relationship to, not the technical source of the relationship.
// (e.g. for an artist-recording rel, it's the recording.)

RE.processRelationship = function(obj, source, check_post, compare) {
    var id = obj.fields.id, rel, update = false, $c, type, relationships;

    type = RE.Util.typestr(obj.fields.link_type);
    if ((relationships = RE.relationships[type]) === undefined) {
        relationships = RE.relationships[type] = {};
    }

    if (id && (rel = relationships[id]) !== undefined) {
        update = true;
    } else {
        rel = new RE.Relationship(obj, source, compare);

        if (id) {
            relationships[id] = rel;
        } else if (source.mergeRelationship(rel)) {
            return;
        }
        if (check_post && !RE.Util.isMBID(rel.target.gid)) {
            RE.processAddedRelationships(rel.target);
        }
    }
    $c = type == "recording-work" ? rel.source.$work_ars : rel.source.$ars;

    // if our source has undefined AR containers, it must be a phantom rel
    // e.g. a work rel via a recording<->work rel where the work was changed
    // by edited_rels in parseRelationships

    if ($c !== undefined) {
        rel.cloneInto($c);
        if (update && !rel.fields.action) rel.update(obj, compare);
        return rel;
    } else {
        rel.remove();
    }
};

// check_post is a flag indicating that we're checking for posted
// relationships for source in edited_rels, added_rels, and removed_rels.
// this is only set on page load.

RE.parseRelationships = function(source, check_post) {
    if (!source.relationships) return;

    var source_entity = RE.Entity(source),
        entity_types = MB.utility.keys(source.relationships);

    for (var i = 0; i < entity_types.length; i++) {
        var entity_type = entity_types[i];

        if (entity_type == "url") continue; // skip URLs for now
        if (source.type == "work" && entity_type == "recording") continue;

        var rels_by_type = source.relationships[entity_type],
            rel_types = MB.utility.keys(rels_by_type);

        for (var j = 0; j < rel_types.length; j++) {
            var rel_type = rel_types[j], rels = rels_by_type[rel_type];

            for (var k = 0; k < rels.length; k++) {
                var obj = rels[k], target_entity, types = RE.type_info[obj.link_type].types;

                obj.target.type = entity_type;
                target_entity = RE.Entity(obj.target);

                var rel = {target: target_entity, direction: obj.direction},
                    fields = rel.fields = {
                    id:        obj.id,
                    link_type: obj.link_type,
                    attrs:     obj.attributes,
                    entity:    []
                };
                if (obj.begin_date) {
                    fields.begin_date = this.Util.parseDate(obj.begin_date);
                }
                if (obj.end_date) {
                    fields.end_date = this.Util.parseDate(obj.end_date);
                }
                if (obj.ended == 1) fields.ended = 1;

                var typestr = RE.Util.typestr(obj.link_type), server;

                server = (RE.server_fields[typestr] = RE.server_fields[typestr] || {})
                    [fields.id] = $.extend(true, {}, fields);

                if (RE.Util.src(types[0], types[1], obj.direction) === 0) {
                    fields.entity[0] = server.entity[0] = source_entity;
                    fields.entity[1] = server.entity[1] = target_entity;
                } else {
                    fields.entity[0] = server.entity[0] = target_entity;
                    fields.entity[1] = server.entity[1] = source_entity;
                }

                var compare = false,
                    work_rels = entity_type == "work" && obj.target.relationships;

                if (check_post) {
                    var edited = RE.Util.CGI.edited(fields);

                    if (edited !== undefined) {
                        if (edited.errors) {
                            rel.errors = true;
                            delete edited.errors;
                        }
                        $.extend(true, rel.fields, edited);
                        if (edited.target) rel.target = edited.target;
                        if (edited.direction) rel.direction = edited.direction;
                        compare = true;
                    }
                }
                if (work_rels) RE.works_loading[target_entity.gid] = 1;
                rel = RE.processRelationship(rel, source_entity, check_post, compare);

                if (check_post) {
                    var removed = RE.Util.CGI.removed(fields);
                    if (rel && removed && !compare) {
                        if (removed.errors) {
                            rel.errors = true;
                            delete removed.errors;
                        }
                        if (rel.fields.action != "remove") {
                            var button = rel.$container.eq(0).children("a.remove-button")[0];
                            RE.UI.Buttons.Remove.clicked.call(button, null);
                        }
                    }
                }
                if (work_rels) {
                    delete RE.works_loading[target_entity.gid];
                    RE.parseRelationships(obj.target, check_post);
                }
            }
        }
    }
    if (check_post) RE.processAddedRelationships(source_entity);
};


RE.processAddedRelationships = function(source) {
    var added = RE.Util.CGI.added(source.gid);
    if (added === undefined) return;

    for (var i = 0; i < added.length; i++) {
        var fields = added[i], rel = {}, types = RE.type_info[fields.link_type].types;

        if (fields.errors) {
            rel.errors = true;
            delete fields.errors;
        }
        rel.fields = fields;
        rel.target = RE.Util.src(types[0], types[1], fields.direction) == 0
            ? fields.entity[1] : fields.entity[0];
        rel.direction = fields.direction;

        RE.processRelationship(rel, source, true, false);
    }
};
