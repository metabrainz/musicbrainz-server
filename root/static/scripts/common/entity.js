/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2013 MetaBrainz Foundation

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

    // Used by MB.entity() below to cache everything with a GID.
    var entityCache = {};

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
        type = (type || data.type || "").replace("-", "_");
        var entityClass = coreEntityMapping[type];

        if (!entityClass) {
            throw "Unknown type of entity: " + type;
        }
        if (data.gid) {
            return entityCache[data.gid] || (
                entityCache[data.gid] = new entityClass(data)
            );
        }
        return new entityClass(data);
    };


    MB.entity.CoreEntity = aclass(Entity, {

        template: _.template(
            "<% if (data.editsPending) { %><span class=\"mp\"><% } %>" +
            "<a href=\"/<%= data.type %>/<%- data.gid %>\" target=\"_blank\"" +
            "<% if (data.sortname) { %> title=\"<%- data.sortname %>\"" +
            "<% } %>><%- data.name %></a><% if (data.comment) { %> " +
            "<span class=\"comment\">(<%- data.comment %>)</span><% } %>" +
            "<% if (data.editsPending) { %></span><% } %>",
            null,
            {variable: "data"}
        ),

        init: function (data) {
            this.id = data.id;
            this.gid = data.gid;
            this.name = data.name || "";
            this.editsPending = data.editsPending;

            if (data.sortname) {
                this.sortname = data.sortname;
            }

            if (data.comment) {
                this.comment = data.comment;
            }

            if (data.artist_credit) {
                this.artistCredit =
                    new MB.entity.ArtistCredit(data.artist_credit);
            }
        },

        html: function () {
            return this.template(this);
        }
    });


    MB.entity.Artist = aclass(MB.entity.CoreEntity, { type: "artist" });

    MB.entity.Label = aclass(MB.entity.CoreEntity, { type: "label" });

    MB.entity.Area = aclass(MB.entity.CoreEntity, { type: "area" });

    MB.entity.Place = aclass(MB.entity.CoreEntity, { type: "place" });

    MB.entity.Recording = aclass(MB.entity.CoreEntity, {
        type: "recording",

        after$init: function (data) {
            this.length = data.length;
            this.video = data.video;

            // Returned from the /ws/js/recording search.
            if (_.isObject(data.appears_on)) {
                this.appearsOn = data.appears_on;
            }

            if (_.isString(data.artist)) {
                this.artist = data.artist;
            }
        }
    });

    MB.entity.Release = aclass(MB.entity.CoreEntity, { type: "release" });

    MB.entity.ReleaseGroup = aclass(MB.entity.CoreEntity, {
        type: "release_group",

        after$init: function (data) {
            this.typeID = data.typeID;
            this.secondaryTypes = data.secondary_types;
        }
    });

    MB.entity.Track = aclass(MB.entity.CoreEntity, {
        type: "track",

        after$init: function (data) {
            this.number = data.number;
            this.position = data.position;
            this.length = MB.utility.formatTrackLength(data.length);
            this.gid = data.gid;

            if (data.recording) {
                this.recording = MB.entity(data.recording, "recording");
            }
        },

        around$html: function (supr) {
            var recording = this.recording;

            if (!recording) {
                return supr();
            }

            return this.template({
                type: "recording",
                gid: recording.gid,
                name: this.name,
                comment: recording.comment,
                editsPending: recording.editsPending
            });
        }
    });

    MB.entity.URL = aclass(MB.entity.CoreEntity, { type: "url" });

    MB.entity.Work = aclass(MB.entity.CoreEntity, { type: "work" });


    // "ko.unwrap" is used throughout this class because the classes in
    // edit/MB/Control/ArtistCredit.js inherit from it. Over there, observables
    // are used for the member variables because they're editable in the UI.
    // Everywhere else, regular variables are used, because the values are
    // constant; there's no need for the added overhead, especially in places
    // like the relationship editor where you can have hundreds of entities
    // being created and rendered.

    MB.entity.ArtistCreditName = aclass(Entity, {

        template: _.template(
            "<a href=\"/artist/<%- data.gid %>\" target=\"_blank\" title=\"" +
            "<%- data.title %>\"><%- data.name %></a><%- data.join %>",
            null,
            {variable: "data"}
        ),

        init: function (data) {
            data = data || {};
            data.artist = MB.entity(data.artist || {}, "artist");

            this.artist = data.artist;
            this.name = data.name || data.artist.name || "";
            this.joinPhrase = data.join_phrase || "";
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

        text: function () {
            return ko.unwrap(this.name) + ko.unwrap(this.joinPhrase);
        },

        html: function () {
            if (!this.hasArtist()) {
                return _.escape(this.text());
            }

            var artist = ko.unwrap(this.artist);
            var title = artist.sortname;

            if (artist.comment) {
                title += " (" + artist.comment + ")";
            }

            var link = this.template({
                gid:   artist.gid,
                title: title,
                name:  ko.unwrap(this.name),
                join:  ko.unwrap(this.joinPhrase)
            });

            if (ko.unwrap(this.name) != artist.name) {
                return '<span class="name-variation">' + link + '</span>';
            }
            else {
                return link;
            }
        },

        toJS: function () {
            var artist = ko.unwrap(this.artist) || {};

            return {
                artist: {
                    name: artist.name,
                    id:   artist.id,
                    gid:  artist.gid
                },
                name: ko.unwrap(this.name),
                join_phrase: ko.unwrap(this.joinPhrase)
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

        text: function () {
            var names = ko.unwrap(this.names);

            return _.reduce(names, function (memo, name) {
                return memo + name.text();
            }, "");
        },

        html: function () {
            var names = ko.unwrap(this.names);

            return _.reduce(names, function (memo, name) {
                return memo + name.html();
            }, "");
        },

        toJS: function () {
            return _.invoke(ko.unwrap(this.names), "toJS");
        }
    });


    MB.entity.Medium = aclass(Entity, function (data) {
        this.format = data.format;
        this.name = data.name;
        this.position = data.position;

        this.tracks = _.map(data.tracks, function (obj) {
            return new MB.entity.Track(obj);
        });

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
        label:         MB.entity.Label,
        area:          MB.entity.Area,
        place:         MB.entity.Place,
        recording:     MB.entity.Recording,
        release:       MB.entity.Release,
        release_group: MB.entity.ReleaseGroup,
        work:          MB.entity.Work,
        url:           MB.entity.URL
    };
}());
