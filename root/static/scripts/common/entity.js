/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2014 MetaBrainz Foundation

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

(function () {

    // Base class that both core and non-core entities inherit from. The only
    // purpose this really serves is allowing the `data instanceof Entity`
    // check in MB.entity() to work.
    var Entity = aclass();


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
        var id = type === "url" ? data.name : data.gid;
        if (id) {
            return MB.entityCache[id] || (MB.entityCache[id] = new entityClass(data));
        }
        return new entityClass(data);
    };

    // Used by MB.entity() above to cache everything with a GID.
    MB.entityCache = {};

    MB.entity.CoreEntity = aclass(Entity, {

        template: _.template(
            "<% if (data.editsPending) { %><span class=\"mp\"><% } %>" +
            "<a href=\"/<%= data.entityType %>/<%- data.gid %>\"" +
            "<% if (data.target) { %> target=\"_blank\"<% } %>" +
            "<% if (data.sortName) { %> title=\"<%- data.sortName %>\"" +
            "<% } %>><bdi><%- data.name %></bdi></a><% if (data.comment) { %> " +
            "<span class=\"comment\">(<%- data.comment %>)</span><% } %>" +
            "<% if (data.video) { %> <span class=\"comment\">" +
            "(<%- data.video %>)</span><% } %>" +
            "<% if (data.editsPending) { %></span><% } %>",
            null,
            {variable: "data"}
        ),

        init: function (data) {
            this.id = data.id;
            this.gid = data.gid;
            this.name = data.name || "";
            this.editsPending = data.editsPending;
            this.relationships = ko.observableArray([]);

            if (data.sortName) {
                this.sortName = data.sortName;
            }

            if (data.comment) {
                this.comment = data.comment;
            }

            if (data.artistCredit) {
                this.artistCredit = new MB.entity.ArtistCredit(data.artistCredit);
            }
        },

        html: function (renderParams) {
            var json = this.toJSON();

            json.entityType = json.entityType.replace("_", "-");

            if (this.gid) {
                return this.template(_.extend(renderParams || {}, json));
            }
            return json.name;
        },

        toJSON: function () {
            var obj = {
                entityType: this.entityType,
                id:         this.id,
                gid:        this.gid,
                name:       ko.unwrap(this.name),
                comment:    ko.unwrap(this.comment)
            };

            if (this.sortName) {
                obj.sortName = this.sortName;
            }

            if (this.artistCredit) {
                obj.artistCredit = this.artistCredit.toJSON();
            }

            return obj;
        }
    });

    MB.entity.Editor = aclass(Entity, {
        entityType: "editor",
        init: function (data) {
            this.id = data.id;
            this.name = data.name;
        },
        toJSON: function () {
            var obj = {
                entityType: this.entityType,
                id:         this.id,
                name:       ko.unwrap(this.name)
            };
            return obj;
        },
        template: _.template(
            "<a href=\"/<%= data.entityType %>/<%- data.name %>\">" +
            "<bdi><%- data.name %></bdi></a>",
            null,
            {variable: "data"}
        )
    });

    MB.entity.Artist = aclass(MB.entity.CoreEntity, { entityType: "artist" });

    MB.entity.Instrument = aclass(MB.entity.CoreEntity, { entityType: "instrument" });

    MB.entity.Label = aclass(MB.entity.CoreEntity, { entityType: "label" });

    MB.entity.Area = aclass(MB.entity.CoreEntity, { entityType: "area" });

    MB.entity.Place = aclass(MB.entity.CoreEntity, { entityType: "place" });

    MB.entity.Recording = aclass(MB.entity.CoreEntity, {
        entityType: "recording",

        after$init: function (data) {
            this.length = data.length;
            this.formattedLength = MB.utility.formatTrackLength(data.length);
            this.video = data.video;

            // Returned from the /ws/js/recording search.
            if (_.isObject(data.appearsOn)) {
                // Depending on where we're getting the data from (search
                // server, /ws/js...) we may have either releases or release
                // groups here. Assume the latter by default.
                var appearsOnType = data.appearsOn.entityType || "release_group";

                this.appearsOn = _.map(data.appearsOn.results, function (appearance) {
                    return MB.entity(appearance, appearsOnType);
                });
            }

            if (_.isString(data.artist)) {
                this.artist = data.artist;
            }
        },

        around$html: function (supr, params) {
            params = params || {};

            if (this.video) {
                params.video = MB.text.Video;
            }
            return supr(params);
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
        }
    });

    MB.entity.ReleaseGroup = aclass(MB.entity.CoreEntity, {
        entityType: "release_group",

        after$init: function (data) {
            this.typeID = data.typeID;
            this.secondaryTypeIDs = data.secondaryTypeIDs;
        }
    });

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

            var gid = MB.constants.PART_OF_SERIES_LINK_TYPES_BY_ENTITY[type.entityType];
            var linkTypeInfo = MB.typeInfoByID[gid];

            return this.getRelationshipGroup(linkTypeInfo.id, viewModel);
        }
    });

    MB.entity.Track = aclass(MB.entity.CoreEntity, {
        entityType: "track",

        after$init: function (data) {
            this.number = data.number;
            this.position = data.position;
            this.length = data.length;
            this.formattedLength = MB.utility.formatTrackLength(this.length);
            this.gid = data.gid;

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

    MB.entity.Work = aclass(MB.entity.CoreEntity, { entityType: "work" });


    // "ko.unwrap" is used throughout this class because the classes in
    // edit/MB/Control/ArtistCredit.js inherit from it. Over there, observables
    // are used for the member variables because they're editable in the UI.
    // Everywhere else, regular variables are used, because the values are
    // constant; there's no need for the added overhead, especially in places
    // like the relationship editor where you can have hundreds of entities
    // being created and rendered.

    MB.entity.ArtistCreditName = aclass(Entity, {

        template: _.template(
            "<% if (data.nameVariation) print('<span class=\"name-variation\">'); %>" +
            "<a href=\"/artist/<%- data.gid %>\"" +
            "<% if (data.target) print(' target=\"_blank\"'); %>" +
            " title=\"<%- data.title %>\"><bdi><%- data.name %></bdi></a>" +
            "<% if (data.nameVariation) print('</span>'); %>" +
            "<%- data.join %>",
            null,
            {variable: "data"}
        ),

        init: function (data) {
            data = data || {};
            data.artist = data.artist || { name: data.name || "" };

            this.artist = MB.entity(data.artist, "artist");;
            this.name = data.name || data.artist.name || "";
            this.joinPhrase = data.joinPhrase || "";
        },

        visibleName: function () {
            var artist = ko.unwrap(this.artist) || {};
            return ko.unwrap(this.name) || artist.name || "";
        },

        isEmpty: function () {
            return !(this.hasArtist() || ko.unwrap(this.name) ||
                     ko.unwrap(this.joinPhrase));
        },

        hasArtist: function () {
            var artist = ko.unwrap(this.artist) || {};
            return Boolean(artist.id || artist.gid);
        },

        isVariousArtists: function () {
            var artist = ko.unwrap(this.artist);
            return artist && (artist.gid === MB.constants.VARTIST_GID ||
                              artist.id == MB.constants.VARTIST_ID);
        },

        isEqual: function (other) {
            return _.isEqual(ko.unwrap(this.artist), ko.unwrap(other.artist)) &&
                   ko.unwrap(this.name) === ko.unwrap(other.name) &&
                   ko.unwrap(this.joinPhrase) === ko.unwrap(other.joinPhrase);
        },

        toJSON: function () {
            var artist = ko.unwrap(this.artist);
            return {
                artist: artist ? artist.toJSON() : null,
                name: ko.unwrap(this.name) || "",
                joinPhrase: ko.unwrap(this.joinPhrase) || ""
            };
        },

        text: function () {
            return ko.unwrap(this.name) + ko.unwrap(this.joinPhrase);
        },

        html: function (renderParams) {
            if (!this.hasArtist()) {
                return _.escape(this.text());
            }

            var name = ko.unwrap(this.name);
            var artist = ko.unwrap(this.artist);
            var title = artist.sortName || "";

            if (artist.comment) {
                title += " (" + artist.comment + ")";
            }

            return this.template(
                _.extend(
                    renderParams || {},
                    {
                        gid:   artist.gid,
                        title: title,
                        name:  name,
                        join:  ko.unwrap(this.joinPhrase),
                        nameVariation: name !== artist.name
                    }
                )
            );
        },

        toJSON: function () {
            var artist = ko.unwrap(this.artist) || {};

            return {
                artist: {
                    name: artist.name,
                    id:   artist.id,
                    gid:  artist.gid
                },
                name: ko.unwrap(this.name),
                joinPhrase: ko.unwrap(this.joinPhrase)
            };
        }
    });


    MB.entity.ArtistCredit = aclass(Entity, {

        init: function (data) {
            this.names = _.map(data, MB.entity.ArtistCreditName);
        },

        isVariousArtists: function () {
            return _.any(_.invoke(ko.unwrap(this.names), "isVariousArtists"));
        },

        isEqual: function (other) {
            var names = ko.unwrap(this.names);
            var otherNames = ko.unwrap(other.names);

            if (names.length !== otherNames.length) {
                return false;
            }

            for (var i = 0, len = names.length; i < len; i++) {
                if (!names[i].isEqual(otherNames[i])) {
                    return false;
                }
            }
            return true;
        },

        isEmpty: function () {
            return _.every(_.invoke(ko.unwrap(this.names), "isEmpty"));
        },

        isComplete: function () {
            var names = ko.unwrap(this.names);

            return names.length > 0 && _.all(names, function (name) {
                return name.hasArtist();
            });
        },

        text: function () {
            var names = ko.unwrap(this.names);

            return _.reduce(names, function (memo, name) {
                return memo + name.text();
            }, "");
        },

        html: function (renderParams) {
            var names = ko.unwrap(this.names);

            return _.reduce(names, function (memo, name) {
                return memo + name.html(renderParams);
            }, "");
        },

        toJSON: function () {
            return _.invoke(ko.unwrap(this.names), "toJSON");
        }
    });


    MB.entity.Medium = aclass(Entity, function (data) {
        this.format = data.format;
        this.formatID = data.formatID;
        this.name = data.name;
        this.position = data.position;

        this.tracks = _.map(data.tracks, MB.entity.Track);

        this.editsPending = data.editsPending;

        this.positionName = "";
        this.positionName += (this.format || MB.text.Medium) + " " + this.position;

        if (this.name) {
            this.positionName += ": " + this.name;
        }
    });


    // Used by MB.entity() to look up classes. JSON from the web service
    // usually includes a lower-case type name, which is used as the key.

    var coreEntityMapping = {
        artist:        MB.entity.Artist,
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
