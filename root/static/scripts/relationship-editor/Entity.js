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

MB.RelationshipEditor = (function (RE) {


MB.entity.CoreEntity.extend({

    after$init: function (data) {
        this.relationships = ko.observableArray([]);

        // XXX This must be deferred (i.e. run outside of this call stack),
        // because parseRelationships will try to instantiate the exact same
        // entity we're calling from, leading to infinite recursion.
        _.defer(RE.Util.parseRelationships, data, this.type);
    },

    toJSON: function () {
        return { gid: this.gid, type: this.type };
    },

    // searches this entity's relationships for potential duplicate "rel"
    // if it is a duplicate, remove and merge it

    mergeRelationship: function (rel) {
        var relationships = (rel.type == "recording-work")
                ? this.performanceRelationships() : this.relationships();

        for (var i = 0; i < relationships.length; i++) {
            var other = relationships[i];

            if (rel !== other && rel.isDuplicate(other)) {
                var obj = rel.toJSON();
                delete obj.id;
                delete obj.action;

                obj.period.begin_date = RE.Util.mergeDates(
                    rel.period.begin_date, other.period.begin_date);

                obj.period.end_date = RE.Util.mergeDates(
                    rel.period.end_date, other.period.end_date);

                other.fromJS(obj);
                rel.remove();

                return true;
            }
        }
        return false;
    },

    hasRelationshipChanges: function () {
        return _.any(_.invoke(this.relationships(), "action"));
    }
});


MB.entity.Recording.extend({

    after$init: function () {
        this.performanceRelationships = ko.observableArray([]);
    },

    around$hasRelationshipChanges: function (supr) {
        return supr() || _.any(this.performanceRelationships(), function (relationship) {
            return relationship.action() ||
                   relationship.entity[1]().hasRelationshipChanges();
        });
    }
});


MB.entity.Release.extend({

    around$hasRelationshipChanges: function (supr) {
        return supr() || _.any(this.mediums, function (medium) {
            return _.any(medium.tracks, function (track) {
                return track.recording.hasRelationshipChanges();
            });
        });
    }
});


MB.entity.Work.after("init", function (data) {
    this.performanceCount = 0;
});


return RE;

}(MB.RelationshipEditor || {}));
