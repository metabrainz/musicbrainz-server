// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import ko from 'knockout';
import _ from 'lodash';

import {hex_sha1} from '../../../lib/sha1/sha1';
import {VIDEO_ATTRIBUTE_GID} from '../../common/constants';
import * as TYPES from '../../common/constants/editTypes';
import linkedEntities from '../../common/linkedEntities';
import MB from '../../common/MB';
import clean from '../../common/utility/clean';
import nonEmpty from '../../common/utility/nonEmpty';
import request from '../../common/utility/request';

(function (edit) {
    edit.TYPES = TYPES;


    function value(arg) { return typeof arg === "function" ? arg() : arg }
    function string(arg) { return clean(value(arg)) }
    function number(arg) { var num = parseInt(value(arg), 10); return isNaN(num) ? null : num }
    function array(arg, type) { return _.map(value(arg), type) }
    function nullableString(arg) { return string(arg) || null }


    var fields = edit.fields = {

        annotation: function (entity) {
            return {
                entity: nullableString(entity.gid),

                // Don't clean()!
                text: String(value(entity.annotation) || '').trim(),
            };
        },

        artistCredit: function (ac) {
            ac = value(ac);

            if (!ac) {
                return {names: []};
            }

            const names = _.map(ac.names, function (credit, index) {
                var artist = value(credit.artist) || {};

                var name = {
                    artist: {
                        name: string(artist.name),
                        id: number(artist.id),
                        gid: nullableString(artist.gid),
                    },
                    name: string(credit.name),
                };

                var joinPhrase = value(credit.joinPhrase) || "";

                // Collapse whitespace, but don't strip leading/trailing.
                name.join_phrase = joinPhrase.replace(/\s{2,}/g, " ");

                // Trim trailing whitespace for the final join phrase only.
                if (index === ac.names.length - 1) {
                    name.join_phrase = _.trimEnd(name.join_phrase);
                }

                name.join_phrase = name.join_phrase || null;

                return name;
            });
            return {names};
        },

        externalLinkRelationship: function (link, source) {
            var editData = {
                id: number(link.relationship),
                linkTypeID: number(link.type),
                attributes: [],
                entities: [
                    this.relationshipEntity(source),
                    {entityType: 'url', name: string(link.url)},
                ],
            };

            if (source.entityType > 'url') {
                editData.entities.reverse();
            }

            if (link.video) {
                editData.attributes = [{type: {gid: VIDEO_ATTRIBUTE_GID}}];
            }

            return editData;
        },

        medium: function (medium) {
            return {
                name:       string(medium.name),
                format_id:  number(medium.formatID),
                position:   number(medium.position),
                tracklist:  array(medium.tracks, fields.track),
            };
        },

        partialDate: function (data) {
            data = data || {};

            return {
                year:   number(data.year),
                month:  number(data.month),
                day:    number(data.day),
            };
        },

        recording: function (recording) {
            return {
                to_edit:        string(recording.gid),
                name:           string(recording.name),
                artist_credit:  fields.artistCredit(recording.artistCredit),
                length:         number(recording.length),
                comment:        string(recording.comment),
                video:          Boolean(value(recording.video)),
            };
        },

        relationship: function (relationship) {
            var data = {
                id:             number(relationship.id),
                linkTypeID:     number(relationship.linkTypeID),
                entities:       array(relationship.entities, this.relationshipEntity),
                entity0_credit: string(relationship.entity0_credit),
                entity1_credit: string(relationship.entity1_credit),
            };

            data.attributes = _(ko.unwrap(relationship.attributes))
                .invokeMap('toJS')
                .sortBy(function (a) { return a.type.id })
                .value();

            if (_.isNumber(data.linkTypeID)) {
                if (linkedEntities.link_type[data.linkTypeID].orderable_direction !== 0) {
                    data.linkOrder = number(relationship.linkOrder) || 0;
                }
            }

            if (relationship.hasDates()) {
                data.begin_date = fields.partialDate(relationship.begin_date);
                data.end_date = fields.partialDate(relationship.end_date);

                if (data.end_date && _(data.end_date).values().some(nonEmpty)) {
                    data.ended = true;
                } else {
                    data.ended = Boolean(value(relationship.ended));
                }
            }

            return data;
        },

        relationshipEntity: function (entity) {
            var data = {
                entityType: entity.entityType,
                gid:        nullableString(entity.gid),
                name:       string(entity.name),
            };

            // We only use URL gids on the edit-url form.
            if (entity.entityType === "url" && !data.gid) {
                delete data.gid;
            }

            return data;
        },

        release: function (release) {
            var releaseGroupID = (release.releaseGroup() || {}).id;

            var events = _(value(release.events)).map(function (data) {
                var event = {
                    date:       fields.partialDate(data.date),
                    country_id: number(data.countryID),
                };

                if (_(event.date).values().some(nonEmpty) || event.country_id !== null) {
                    return event;
                }
            }).compact().value();

            return {
                name:               string(release.name),
                artist_credit:      fields.artistCredit(release.artistCredit),
                release_group_id:   number(releaseGroupID),
                comment:            string(release.comment),
                barcode:            value(release.barcode.value),
                language_id:        number(release.languageID),
                packaging_id:       number(release.packagingID),
                script_id:          number(release.scriptID),
                status_id:          number(release.statusID),
                events:             events,
            };
        },

        releaseGroup: function (rg) {
            return {
                gid:                string(rg.gid),
                primary_type_id:    number(rg.typeID),
                name:               string(rg.name),
                artist_credit:      fields.artistCredit(rg.artistCredit),
                comment:            string(rg.comment),
                secondary_type_ids: _.compact(array(rg.secondaryTypeIDs, number)),
            };
        },

        releaseLabel: function (releaseLabel) {
            var label = value(releaseLabel.label) || {};

            return {
                release_label:  number(releaseLabel.id),
                label:          number(label.id),
                catalog_number: nullableString(releaseLabel.catalogNumber),
            };
        },

        track: function (track) {
            var recording = value(track.recording) || {};

            return {
                id:             number(track.id),
                name:           string(track.name),
                artist_credit:  fields.artistCredit(track.artistCredit),
                recording_gid:  nullableString(recording.gid),
                position:       number(track.position),
                number:         string(track.number),
                length:         number(track.length),
                is_data_track:  !!ko.unwrap(track.isDataTrack),
            };
        },

        work: function (work) {
            return {
                name:           string(work.name),
                comment:        string(work.comment),
                type_id:        number(work.typeID),
                languages:      array(work.languages, number),
            };
        },
    };


    function editHash(edit) {
        var keys = _.keys(edit).sort();

        function keyValue(memo, key) {
            var value = edit[key];

            return memo + key + (_.isObject(value) ? editHash(value) : value);
        }
        return hex_sha1(_.reduce(keys, keyValue, ""));
    }


    function removeEqual(newData, oldData, required) {
        _(newData)
            .keys()
            .intersection(_.keys(oldData))
            .difference(required)
            .each(function (key) {
                if (_.isEqual(newData[key], oldData[key])) {
                    delete newData[key];
                }
            });
    }


    function editConstructor(type, callback) {
        return function (args, ...rest) {
            args = {...args, edit_type: type};

            callback && callback.apply(null, [args].concat(rest));
            args.hash = editHash(args);

            return args;
        };
    }


    edit.releaseGroupCreate = editConstructor(
        TYPES.EDIT_RELEASEGROUP_CREATE,

        function (args) {
            delete args.gid;

            if (!_.some(args.secondary_type_ids)) {
                delete args.secondary_type_ids;
            }
        },
    );


    edit.releaseGroupEdit = editConstructor(
        TYPES.EDIT_RELEASEGROUP_EDIT,
        _.partialRight(removeEqual, ['gid']),
    );


    edit.releaseCreate = editConstructor(
        TYPES.EDIT_RELEASE_CREATE,

        function (args) {
            if (args.events && !args.events.length) {
                delete args.events;
            }
        },
    );


    edit.releaseEdit = editConstructor(
        TYPES.EDIT_RELEASE_EDIT,
        _.partialRight(removeEqual, ['to_edit']),
    );


    edit.releaseAddReleaseLabel = editConstructor(
        TYPES.EDIT_RELEASE_ADDRELEASELABEL,

        function (args) { delete args.release_label },
    );


    edit.releaseAddAnnotation = editConstructor(
        TYPES.EDIT_RELEASE_ADD_ANNOTATION,
    );


    edit.releaseDeleteReleaseLabel = editConstructor(
        TYPES.EDIT_RELEASE_DELETERELEASELABEL,
    );


    edit.releaseEditReleaseLabel = editConstructor(
        TYPES.EDIT_RELEASE_EDITRELEASELABEL,
    );


    edit.workCreate = editConstructor(TYPES.EDIT_WORK_CREATE);


    edit.mediumCreate = editConstructor(
        TYPES.EDIT_MEDIUM_CREATE,

        function (args) {
            if (args.format_id === null) {
                delete args.format_id;
            }
        },
    );


    edit.mediumEdit = editConstructor(
        TYPES.EDIT_MEDIUM_EDIT,
        _.partialRight(removeEqual, ['to_edit']),
    );


    edit.mediumDelete = editConstructor(TYPES.EDIT_MEDIUM_DELETE);


    edit.mediumAddDiscID = editConstructor(TYPES.EDIT_MEDIUM_ADD_DISCID);


    edit.recordingEdit = editConstructor(
        TYPES.EDIT_RECORDING_EDIT,
        _.partialRight(removeEqual, ['to_edit']),
    );


    edit.relationshipCreate = editConstructor(
        TYPES.EDIT_RELATIONSHIP_CREATE,
        function (args) { delete args.id },
    );


    edit.relationshipEdit = editConstructor(
        TYPES.EDIT_RELATIONSHIP_EDIT,
        function (args, orig, relationship) {
            var newAttributes = {};
            var origAttributes = relationship ? relationship.attributes.original : {};
            var changedAttributes = [];

            _.each(args.attributes, function (hash) {
                var gid = hash.type.gid;

                newAttributes[gid] = hash;

                if (!origAttributes[gid] || !_.isEqual(origAttributes[gid], hash)) {
                    changedAttributes.push(hash);
                 }
            });

            _.each(origAttributes, function (value, gid) {
                if (!newAttributes[gid]) {
                    changedAttributes.push({type: {gid: gid}, removed: true});
                }
            });

            args.attributes = changedAttributes;
            removeEqual(args, orig, ['id', 'linkTypeID']);
        },
    );


    edit.relationshipDelete = editConstructor(
        TYPES.EDIT_RELATIONSHIP_DELETE,
    );


    edit.releaseReorderMediums = editConstructor(
        TYPES.EDIT_RELEASE_REORDER_MEDIUMS,
    );


    function editEndpoint(endpoint) {
        function omitHash(edit) { return _.omit(edit, "hash") }

        return function (data, context) {
            data.edits = _.map(data.edits, omitHash);

            return request({
                type: "POST",
                url: endpoint,
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
            }, context || null);
        };
    }

    edit.preview = editEndpoint("/ws/js/edit/preview");
    edit.create = editEndpoint("/ws/js/edit/create");
}(MB.edit = {}));

export default MB.edit;
