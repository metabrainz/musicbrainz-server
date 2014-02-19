// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

(function (edit) {

    var TYPES = edit.TYPES = {
        EDIT_RELEASEGROUP_CREATE:                   20,
        EDIT_RELEASE_CREATE:                        31,
        EDIT_RELEASE_EDIT:                          32,
        EDIT_RELEASE_ADDRELEASELABEL:               34,
        EDIT_RELEASE_ADD_ANNOTATION:                35,
        EDIT_RELEASE_DELETERELEASELABEL:            36,
        EDIT_RELEASE_EDITRELEASELABEL:              37,
        EDIT_MEDIUM_CREATE:                         51,
        EDIT_MEDIUM_EDIT:                           52,
        EDIT_MEDIUM_DELETE:                         53,
        EDIT_MEDIUM_ADD_DISCID:                     55,
        EDIT_RECORDING_EDIT:                        72,
        EDIT_RELEASE_REORDER_MEDIUMS:               313
    };


    function value(arg) { return typeof arg === "function" ? arg() : arg }
    function string(arg) { return _.str.clean(value(arg)) }
    function number(arg) { return parseInt(value(arg), 10) || null }
    function array(arg, type) { return _.map(value(arg), type) }
    function nullableString(arg) { return string(arg) || null }


    var fields = edit.fields = {

        annotation: function (entity) {
            return {
                entity: number(entity.id),

                // Don't _.str.clean!
                text: _.str.trim(value(entity.annotation))
            };
        },

        artistCredit: function (ac) {
            ac = ac || {};

            var names = value(ac.names);

            names = _.map(names, function (credit, index) {
                var artist = value(credit.artist) || {};

                var name = {
                    artist: {
                        name: string(artist.name),
                        id: number(artist.id),
                        gid: nullableString(artist.gid)
                    },
                    name: string(credit.name)
                };

                var joinPhrase = value(credit.joinPhrase) || "";

                // Collapse whitespace, but don't strip leading/trailing.
                name.join_phrase = joinPhrase.replace(/\s{2,}/g, " ");

                // Trim trailing whitespace for the final join phrase only.
                if (index === names.length - 1) {
                    name.join_phrase = _.str.rtrim(name.join_phrase);
                }

                name.join_phrase = name.join_phrase || null;

                return name;
            });
            return { names: names };
        },

        medium: function (medium) {
            return {
                name:       nullableString(medium.name),
                format_id:  number(medium.formatID),
                position:   number(medium.position),
                tracklist:  array(medium.tracks, fields.track)
            };
        },

        partialDate: function (data) {
            data = data || {};

            var date = {
                year:   number(data.year),
                month:  number(data.month),
                day:    number(data.day)
            };

            return (date.year  === null &&
                    date.month === null &&
                    date.day   === null) ? null : date;
        },

        recording: function (recording) {
            return {
                to_edit:        string(recording.gid),
                name:           string(recording.name),
                artist_credit:  fields.artistCredit(recording.artistCredit),
                length:         number(recording.length),
                comment:        string(recording.comment),
                video:          value(recording.video) ? 1 : 0
            };
        },

        release: function (release) {
            var releaseGroupID = (release.releaseGroup() || {}).id;

            var events = $.map(value(release.events), function (data) {
                var event = {
                    date:       fields.partialDate(data.date),
                    country_id: number(data.countryID)
                };

                if (event.date !== null || event.country_id !== null) {
                    return event;
                }
            });

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
                events:             events
            };
        },

        releaseGroup: function (rg) {
            return {
                primary_type_id:    number(rg.typeID),
                name:               string(rg.name),
                artist_credit:      fields.artistCredit(rg.artistCredit),
                comment:            string(rg.comment),
                secondary_type_ids: _.compact(array(rg.secondaryTypeIDs, number))
            };
        },

        releaseLabel: function (releaseLabel) {
            var label = value(releaseLabel.label) || {};

            return {
                release_label:  number(releaseLabel.id),
                label:          number(label.id),
                catalog_number: nullableString(releaseLabel.catalogNumber)
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
                length:         number(track.length)
            };
        }
    };


    function editHash(edit) {
        var keys = _.keys(edit).sort();

        function keyValue(memo, key) {
            var value = edit[key];

            return memo + key + (_.isObject(value) ? editHash(value) : value);
        }
        return hex_sha1(_.reduce(keys, keyValue, ""));
    }


    function editConstructor(type, callback) {
        return function (args, orig) {
            args = _.extend({ edit_type: type }, args);

            callback && callback(args, orig);
            args.hash = editHash(args);

            return args;
        };
    }


    edit.releaseGroupCreate = editConstructor(
        TYPES.EDIT_RELEASEGROUP_CREATE,

        function (args) {
            if (!_.any(args.secondary_type_ids)) {
                delete args.secondary_type_ids;
            }
        }
    );


    edit.releaseCreate = editConstructor(
        TYPES.EDIT_RELEASE_CREATE,

        function (args) {
            if (args.events && !args.events.length) {
                delete args.events;
            }
        }
    );


    edit.releaseEdit = editConstructor(
        TYPES.EDIT_RELEASE_EDIT,

        function (args, orig) {
            if (args.name === orig.name) {
                delete args.name;
            }
            if (args.comment === orig.comment) {
                delete args.comment;
            }
            if (_.isEqual(args.artist_credit, orig.artist_credit)) {
                delete args.artist_credit;
            }
            if (args.release_group_id === orig.release_group_id) {
                delete args.release_group_id;
            }
            if (_.isEqual(args.events, orig.events)) {
                delete args.events;
            }
        }
    );


    edit.releaseAddReleaseLabel = editConstructor(
        TYPES.EDIT_RELEASE_ADDRELEASELABEL,

        function (args) { delete args.release_label }
    );


    edit.releaseAddAnnotation = editConstructor(
        TYPES.EDIT_RELEASE_ADD_ANNOTATION
    );


    edit.releaseDeleteReleaseLabel = editConstructor(
        TYPES.EDIT_RELEASE_DELETERELEASELABEL
    );


    edit.releaseEditReleaseLabel = editConstructor(
        TYPES.EDIT_RELEASE_EDITRELEASELABEL
    );


    edit.mediumCreate = editConstructor(
        TYPES.EDIT_MEDIUM_CREATE,

        function (args) {
            if (!args.name) {
                delete args.name;
            }
            if (args.format_id === null) {
                delete args.format_id;
            }
        }
    );


    edit.mediumEdit = editConstructor(
        TYPES.EDIT_MEDIUM_EDIT,
        function (args, orig) {
            if (_.isEqual(args.tracklist, orig.tracklist)) {
                delete args.tracklist;
            }
        }
    );


    edit.mediumDelete = editConstructor(
        TYPES.EDIT_MEDIUM_DELETE
    );


    edit.mediumAddDiscID = editConstructor(
        TYPES.EDIT_MEDIUM_ADD_DISCID
    );


    edit.recordingEdit = editConstructor(
        TYPES.EDIT_RECORDING_EDIT,
        function (args, orig) {
            if (args.name === orig.name) {
                delete args.name;
            }
        }
    );


    edit.releaseReorderMediums = editConstructor(
        TYPES.EDIT_RELEASE_REORDER_MEDIUMS
    );


    function editEndpoint(endpoint) {
        function omitHash(edit) { return _.omit(edit, "hash") }

        return function (data) {
            data.edits = _.map(data.edits, omitHash);

            return MB.utility.request({
                type: "POST",
                url: endpoint,
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8"
            });
        };
    }

    edit.preview = editEndpoint("/ws/js/edit/preview");
    edit.create = editEndpoint("/ws/js/edit/create");

}(MB.edit = {}));
