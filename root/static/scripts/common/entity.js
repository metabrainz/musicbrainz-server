// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const _ = require('lodash');
const aclass = require('aclass');
const ReactDOMServer = require('react-dom/server');

const ArtistCreditLink = require('./components/ArtistCreditLink');
const {
    PART_OF_SERIES_LINK_TYPES,
    PROBABLY_CLASSICAL_LINK_TYPES,
    VARTIST_GID,
} = require('./constants');
const i18n = require('./i18n');
const {
        artistCreditFromArray,
        artistCreditsAreEqual,
        isCompleteArtistCredit,
    } = require('./immutable-entities');
const MB = require('./MB');
const clean = require('./utility/clean');
const formatTrackLength = require('./utility/formatTrackLength');

(function () {

    // Base class that both core and non-core entities inherit from. The only
    // purpose this really serves is allowing the `data instanceof Entity`
    // check in MB.entity() to work.
    var Entity = aclass({

        init: function (data) {
            _.assign(this, data);
            this.name = this.name || "";
        },

        toJSON: function () {
            var key, result = {};
            for (key in this) {
                toJSON(result, this[key], key);
            }
            return result;
        },

        renderArtistCredit: function (ac) {
            ac = ko.unwrap(ac);
            // XXX For suggested recording data in the release editor,
            // which root/release/edit/recordings.tt passes into here as plain
            // JSON (can't really "instantiate" things anywhere else).
            if (Array.isArray(ac)) {
                ac = artistCreditFromArray(ac);
            }
            return ReactDOMServer.renderToStaticMarkup(
                <ArtistCreditLink artistCredit={ac} target="_blank" />
            );
        },

        isCompleteArtistCredit: function (ac) {
            ac = ko.unwrap(ac);
            if (Array.isArray(ac)) {
                ac = artistCreditFromArray(ac);
            }
            return isCompleteArtistCredit(ac);
        },
    });

    var primitiveTypes = /^(boolean|number|string)$/;

    function toJSON(result, value, key) {
        while (ko.isObservable(value)) {
            value = value();
        }

        if (!value || primitiveTypes.test(typeof value)) {
            result[key] = value;
        }
    }

    // Usually, this function should be called to create new entities instead
    // of directly instantiating any of the classes below. MB.entity() caches
    // everything with a GID, so if you pass in the same entity twice, you get
    // the same object back (which is ideal, because otherwise there could be a
    // lot of duplication for things like track artists). This also allows
    // comparing entities for equality with a simple `===` instead of having to
    // compare the GIDs.

    MB.entity = function (data, type) {
        if (!data) {
            return null;
        }
        if (data instanceof Entity) {
            return data;
        }
        type = (type || data.entityType || "").replace("-", "_");
        var entityClass = coreEntityMapping[type];

        if (!entityClass) {
            throw "Unknown type of entity: " + type;
        }
        var entity = MB.entityCache[data.gid];

        if (type === "url") {
            entity = entity || MB.entityCache[data.name];
        }

        if (!entity) {
            entity = new entityClass(data);

            if (data.gid) {
                MB.entityCache[data.gid] = entity;
            }

            if (data.name && type === "url") {
                MB.entityCache[data.name] = entity;
            }
        }

        return entity;
    };

    MB.entity.Entity = Entity;

    // Used by MB.entity() above to cache everything with a GID.
    MB.entityCache = {};

    MB.entity.CoreEntity = aclass(Entity, {

        template: _.template(
            "<% if (data.editsPending) { %><span class=\"mp\"><% } %>" +
            "<% if (data.nameVariation) { %><span class=\"name-variation\" title=\"<%- data.name %>\"><% } %>" +
            "<a href=\"/<%= data.entityType %>/<%- data.gid %>\"" +
            "<% if (data.target) { %> target=\"_blank\"<% } %>" +
            "<% if (data.sort_name) { %> title=\"<%- data.sort_name %>\"" +
            "<% } %>><bdi><%- data.creditedAs || data.name %></bdi></a>" +
            "<% if (data.comment) { %> " +
            "<span class=\"comment\">(<%- data.comment %>)</span><% } %>" +
            "<% if (data.video) { %> <span class=\"comment\">" +
            "(<%- data.videoString %>)</span><% } %>" +
            "<% if (data.nameVariation) { %></span><% } %>" +
            "<% if (data.editsPending) { %></span><% } %>",
            {variable: "data"}
        ),

        after$init: function (data) {
            this.relationships = ko.observableArray([]);

            if (data.artistCredit) {
                this.artistCredit = artistCreditFromArray(data.artistCredit);
            }
        },

        html: function (renderParams) {
            var json = this.toJSON();

            json.entityType = json.entityType.replace("_", "-");
            json.nameVariation = json.creditedAs && json.creditedAs !== json.name;

            if (this.gid) {
                return this.template(_.extend(renderParams || {}, json));
            }
            return json.name;
        },

        around$toJSON: function (supr) {
            var json = supr();

            if (this.artistCredit) {
                json.artistCredit = ko.unwrap(this.artistCredit).names.toJS();
            }
            return json;
        },

        canTakeName: function (name) {
            name = clean(name);
            return name && name !== ko.unwrap(this.name);
        },

        canTakeArtist: function (ac) {
            ac = ko.unwrap(ac);
            return isCompleteArtistCredit(ac) && !this.isArtistCreditEqual(ac);
        },

        isArtistCreditEqual: function (ac) {
            ac = ko.unwrap(ac);
            return artistCreditsAreEqual(ko.unwrap(this.artistCredit), ac);
        }
    });

    MB.entity.Editor = aclass(MB.entity.CoreEntity, {
        entityType: "editor",

        template: _.template(
            "<a href=\"/<%= data.entityType %>/<%- data.name %>\">" +
            "<bdi><%- data.name %></bdi></a>",
            {variable: "data"}
        )
    });

    MB.entity.Artist = aclass(MB.entity.CoreEntity, { entityType: "artist" });

    MB.entity.Event = aclass(MB.entity.CoreEntity, { entityType: "event" });

    MB.entity.Instrument = aclass(MB.entity.CoreEntity, { entityType: "instrument" });

    MB.entity.Label = aclass(MB.entity.CoreEntity, { entityType: "label" });

    MB.entity.Area = aclass(MB.entity.CoreEntity, { entityType: "area" });

    MB.entity.Place = aclass(MB.entity.CoreEntity, { entityType: "place" });

    MB.entity.Recording = aclass(MB.entity.CoreEntity, {
        entityType: "recording",

        after$init: function (data) {
            this.formattedLength = formatTrackLength(data.length);

            // Returned from the /ws/js/recording search.
            if (this.appearsOn) {
                // Depending on where we're getting the data from (search
                // server, /ws/js...) we may have either releases or release
                // groups here. Assume the latter by default.
                var appearsOnType = this.appearsOn.entityType || "release_group";

                this.appearsOn.results = _.map(this.appearsOn.results, function (appearance) {
                    return MB.entity(appearance, appearsOnType);
                });
            }

            if (!this.artistCredit) {
                this.artistCredit = artistCreditFromArray([]);
            }

            this.relatedArtists = relatedArtists(data.relationships);
            this.isProbablyClassical = isProbablyClassical(data);
        },

        around$html: function (supr, params) {
            params = params || {};
            params.videoString = i18n.l("video");
            return supr(params);
        },

        around$toJSON: function (supr) {
            return _.assign(supr(), { isrcs: this.isrcs, appearsOn: this.appearsOn });
        }
    });

    MB.entity.Release = aclass(MB.entity.CoreEntity, {
        entityType: "release",

        after$init: function (data) {
            if (data.releaseGroup) {
                this.releaseGroup = MB.entity(data.releaseGroup, "release_group");
            }

            if (data.mediums) {
                this.mediums = _.map(data.mediums, MB.entity.Medium);
            }

            this.relatedArtists = relatedArtists(data.relationships);
            this.isProbablyClassical = isProbablyClassical(data);
        },

        around$toJSON: function (supr) {
            var object = supr();

            if (_.isArray(this.events)) {
                object.events = _.cloneDeep(this.events);
            }

            if (_.isArray(this.labels)) {
                object.labels = _.cloneDeep(this.labels);
            }

            return object;
        }
    });

    MB.entity.ReleaseGroup = aclass(MB.entity.CoreEntity, { entityType: "release_group" });

    MB.entity.Series = aclass(MB.entity.CoreEntity, {
        entityType: "series",

        after$init: function (data) {
            this.type = ko.observable(data.type);
            this.typeID = ko.observable(data.type && data.type.id);
            this.orderingTypeID = ko.observable(data.orderingTypeID);
        },

        getSeriesItems: function (viewModel) {
            var type = this.type();
            if (!type) return [];

            var gid = PART_OF_SERIES_LINK_TYPES[type.series_entity_type];
            var linkTypeID = MB.typeInfoByID[gid].id;

            return _.filter(this.displayableRelationships(viewModel)(), function (r) {
                return r.linkTypeID() === linkTypeID;
            });
        },

        around$toJSON: function (supr) {
            return _.assign(supr(), {
                type: this.type(),
                typeID: this.typeID,
                orderingTypeID: this.orderingTypeID
            });
        }
    });

    MB.entity.Track = aclass(MB.entity.CoreEntity, {
        entityType: "track",

        after$init: function (data) {
            this.formattedLength = formatTrackLength(this.length);

            if (data.recording) {
                this.recording = MB.entity(data.recording, "recording");
            }
        },

        around$html: function (supr, renderParams) {
            var recording = this.recording;

            if (!recording) {
                return supr(renderParams);
            }

            return this.template(
                _.extend(
                    renderParams || {},
                    {
                        entityType: "recording",
                        gid: recording.gid,
                        name: this.name,
                        comment: recording.comment,
                        editsPending: recording.editsPending
                    }
                )
            );
        }
    });

    MB.entity.URL = aclass(MB.entity.CoreEntity, { entityType: "url" });

    MB.entity.Work = aclass(MB.entity.CoreEntity, {
        entityType: "work",

        around$toJSON: function (supr) {
            return _.assign(supr(), { artists: this.artists });
        }
    });

    MB.entity.Medium = aclass(Entity, {
        after$init: function (data) {
            this.tracks = _.map(data.tracks, MB.entity.Track);

            var positionName;
            if (this.name) {
                positionName = this.format ? "{medium_format} {position}: {title}" : "Medium {position}: {title}";
            } else {
                positionName = this.format ? "{medium_format} {position}" : "Medium {position}";
            }

            this.positionName = i18n.l(positionName, {
                medium_format: this.format,
                position: this.position,
                title: this.name
            });
        }
    });

    function relatedArtists(relationships) {
        return _(relationships).filter({target: {entityType: 'artist'}}).pluck('target').value();
    }

    var classicalRoles = /\W(baritone|cello|conductor|gamba|guitar|orch|orchestra|organ|piano|soprano|tenor|trumpet|vocals?|viola|violin): /;

    function isProbablyClassical(entity) {
        return classicalRoles.test(entity.name) || _.any(entity.relationships, function (r) {
            return _.contains(PROBABLY_CLASSICAL_LINK_TYPES, r.linkTypeID);
        });
    }

    // Used by MB.entity() to look up classes. JSON from the web service
    // usually includes a lower-case type name, which is used as the key.

    var coreEntityMapping = {
        artist:        MB.entity.Artist,
        event:         MB.entity.Event,
        instrument:    MB.entity.Instrument,
        label:         MB.entity.Label,
        area:          MB.entity.Area,
        place:         MB.entity.Place,
        recording:     MB.entity.Recording,
        release:       MB.entity.Release,
        release_group: MB.entity.ReleaseGroup,
        series:        MB.entity.Series,
        track:         MB.entity.Track,
        work:          MB.entity.Work,
        url:           MB.entity.URL,
        editor:        MB.entity.Editor
    };
}());
