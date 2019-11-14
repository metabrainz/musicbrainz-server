// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import ko from 'knockout';
import _ from 'lodash';
import React from 'react';
import ReactDOMServer from 'react-dom/server';

import ArtistCreditLink from './components/ArtistCreditLink';
import EditorLink from './components/EditorLink';
import EntityLink from './components/EntityLink';
import DescriptiveLink from './components/DescriptiveLink';
import {
  ENTITY_NAMES,
  PART_OF_SERIES_LINK_TYPES,
  PROBABLY_CLASSICAL_LINK_TYPES,
} from './constants';
import {
  artistCreditsAreEqual,
  isCompleteArtistCredit,
} from './immutable-entities';
import linkedEntities from './linkedEntities';
import MB from './MB';
import clean from './utility/clean';
import formatTrackLength from './utility/formatTrackLength';

(function () {
    // Base class that both core and non-core entities inherit from. The only
    // purpose this really serves is allowing the `data instanceof Entity`
    // check in MB.entity() to work.
    class Entity {
        constructor(data) {
            Object.assign(this, data);
            this.name = this.name || '';
        }

        toJSON() {
            var key, result = {};
            for (key in this) {
                toJSON(result, this[key], key);
            }
            return result;
        }

        renderArtistCredit(ac) {
            ac = ko.unwrap(ac);
            return ReactDOMServer.renderToStaticMarkup(
              <ArtistCreditLink artistCredit={ac} target="_blank" />,
            );
        }

        isCompleteArtistCredit(ac) {
            ac = ko.unwrap(ac);
            return isCompleteArtistCredit(ac);
        }

        entityTypeLabel() {
            return addColon(ENTITY_NAMES[this.entityType]());
        }

        html(...args) {
            return ReactDOMServer.renderToStaticMarkup(this.reactElement(...args));
        }
    }

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
        type = (type || data.entityType || '').replace('-', '_');
        var entityClass = coreEntityMapping[type];

        if (!entityClass) {
            throw 'Unknown type of entity: ' + type;
        }
        var entity = MB.entityCache[data.gid];

        if (type === 'url') {
            entity = entity || MB.entityCache[data.name];
        }

        if (!entity) {
            entity = new entityClass(data);

            if (data.gid) {
                MB.entityCache[data.gid] = entity;
            }

            if (data.name && type === 'url') {
                MB.entityCache[data.name] = entity;
            }
        }

        return entity;
    };

    // Used by MB.entity() above to cache everything with a GID.
    MB.entityCache = {};

    class CoreEntity extends Entity {
        constructor(data) {
            super(data);

            this.relationships = ko.observableArray([]);

            if (data.artistCredit) {
                this.artistCredit = _.cloneDeep(data.artistCredit);
            }

            if (this._afterCoreEntityCtor) {
                this._afterCoreEntityCtor(data);
            }
        }

        reactElement(renderParams) {
            var json = this.toJSON();

            if (this.gid) {
                // XXX needed by the relationship editor
                if (renderParams && renderParams.creditedAs !== undefined) {
                    json.creditedAs = renderParams.creditedAs;
                    delete renderParams.creditedAs;
                }

                return (
                  <EntityLink
                    content={json.creditedAs}
                    entity={{
                        comment: json.comment,
                        editsPending: json.editsPending,
                        entityType: json.entityType,
                        gid: json.gid,
                        name: json.name,
                        sort_name: json.sort_name,
                        typeID: json.typeID,
                        video: json.video,
                    }}
                    {...renderParams}
                  />
                );
            }

            return json.name;
        }

        toJSON() {
            var json = super.toJSON();

            if (this.artistCredit) {
                json.artistCredit = ko.unwrap(this.artistCredit);
            }

            return json;
        }

        canTakeName(name) {
            name = clean(name);
            return name && name !== ko.unwrap(this.name);
        }

        canTakeArtist(ac) {
            ac = ko.unwrap(ac);
            return isCompleteArtistCredit(ac) && !this.isArtistCreditEqual(ac);
        }

        isArtistCreditEqual(ac) {
            ac = ko.unwrap(ac);
            return artistCreditsAreEqual(ko.unwrap(this.artistCredit), ac);
        }
    }

    class Editor extends CoreEntity {
        reactElement() {
            return (
              <EditorLink editor={{entityType: 'editor', name: this.name}} />
            );
        }
    }

    Editor.prototype.entityType = 'editor';

    class Artist extends CoreEntity {}

    Artist.prototype.entityType = 'artist';

    class Event extends CoreEntity {}

    Event.prototype.entityType = 'event';

    class Instrument extends CoreEntity {}

    Instrument.prototype.entityType = 'instrument';

    class Label extends CoreEntity {
        selectionMessage() {
            return ReactDOMServer.renderToStaticMarkup(
                exp.l('You selected {label}.', {label: this.reactElement({target: '_blank'})}),
            );
        }
    }

    Label.prototype.entityType = 'label';

    class Area extends CoreEntity {
        selectionMessage() {
            return ReactDOMServer.renderToStaticMarkup(
                exp.l('You selected {area}.', {area: this.reactElement({target: '_blank'})}),
            );
        }
    }

    Area.prototype.entityType = 'area';

    class Place extends CoreEntity {}

    Place.prototype.entityType = 'place';

    class Recording extends CoreEntity {
        constructor(data) {
            super(data);

            this.formattedLength = formatTrackLength(data.length);

            // Returned from the /ws/js/recording search.
            if (this.appearsOn) {
                // Depending on where we're getting the data from (search
                // server, /ws/js...) we may have either releases or release
                // groups here. Assume the latter by default.
                var appearsOnType = this.appearsOn.entityType || 'release_group';

                this.appearsOn.results = _.map(this.appearsOn.results, function (appearance) {
                    return MB.entity(appearance, appearsOnType);
                });
            }

            if (!this.artistCredit) {
                this.artistCredit = {names: []};
            }

            this.relatedArtists = relatedArtists(data.relationships);
            this.isProbablyClassical = isProbablyClassical(data);

            if (this._afterRecordingCtor) {
                this._afterRecordingCtor(data);
            }
        }

        toJSON() {
            return Object.assign(super.toJSON(), {isrcs: this.isrcs, appearsOn: this.appearsOn});
        }
    }

    Recording.prototype.entityType = 'recording';

    class Release extends CoreEntity {
        constructor(data) {
            super(data);

            if (data.releaseGroup) {
                this.releaseGroup = MB.entity(data.releaseGroup, 'release_group');
            }

            if (data.mediums) {
                this.mediums = _.map(data.mediums, x => new Medium(x));
            }

            this.relatedArtists = relatedArtists(data.relationships);
            this.isProbablyClassical = isProbablyClassical(data);
        }

        toJSON() {
            var object = super.toJSON();

            if (_.isArray(this.events)) {
                object.events = _.cloneDeep(this.events);
            }

            if (_.isArray(this.labels)) {
                object.labels = _.cloneDeep(this.labels);
            }

            return object;
        }
    }

    Release.prototype.entityType = 'release';

    class ReleaseGroup extends CoreEntity {
        selectionMessage() {
            return ReactDOMServer.renderToStaticMarkup(
                exp.l('You selected {releasegroup}.', {
                    releasegroup: <DescriptiveLink entity={this} target="_blank" />,
                }),
            );
        }
    }

    ReleaseGroup.prototype.entityType = 'release_group';

    class Series extends CoreEntity {
        constructor(data) {
            super(data);
            this.type = ko.observable(data.type);
            this.typeID = ko.observable(data.type && data.type.id);
            this.orderingTypeID = ko.observable(data.orderingTypeID);
        }

        getSeriesItems(viewModel) {
            var type = this.type();
            if (!type) return [];

            var gid = PART_OF_SERIES_LINK_TYPES[type.item_entity_type];
            var linkTypeID = linkedEntities.link_type[gid].id;

            return _.filter(this.displayableRelationships(viewModel)(), function (r) {
                return r.linkTypeID() === linkTypeID;
            });
        }

        toJSON() {
            return Object.assign(super.toJSON(), {
                type: this.type(),
                typeID: this.typeID,
                orderingTypeID: this.orderingTypeID,
            });
        }
    }

    Series.prototype.entityType = 'series';

    class Track extends CoreEntity {
        constructor(data) {
            super(data);

            this.formattedLength = formatTrackLength(this.length);

            if (data.recording) {
                this.recording = MB.entity(data.recording, 'recording');
            }
        }

        reactElement(renderParams) {
            var recording = this.recording;

            if (!recording) {
                return super.reactElement(renderParams);
            }

            const json = {
                comment: recording.comment,
                editsPending: recording.editsPending,
                entityType: 'recording',
                gid: recording.gid,
                name: recording.name,
                video: recording.video,
            };
            return (
              <EntityLink content={this.name} entity={json} {...renderParams} />
            );
        }
    }

    Track.prototype.entityType = 'track';

    class URL extends CoreEntity {}

    URL.prototype.entityType = 'url';

    class Work extends CoreEntity {
        toJSON() {
            return Object.assign(super.toJSON(), {artists: this.artists});
        }
    }

    Work.prototype.entityType = 'work';

    class Medium extends Entity {
        constructor(data) {
            super(data);

            this.tracks = _.map(data.tracks, x => new Track(x));

            const positionArgs = {
                medium_format: this.format,
                position: this.position,
                title: this.name,
            };
            if (this.name) {
                this.positionName = this.format
                    ? texp.l('{medium_format} {position}: {title}', positionArgs)
                    : texp.l('Medium {position}: {title}', positionArgs);
            } else {
                this.positionName = this.format
                    ? texp.l('{medium_format} {position}', positionArgs)
                    : texp.l('Medium {position}', positionArgs);
            }
        }
    }

    MB.entity.Area = Area;
    MB.entity.Artist = Artist;
    MB.entity.CoreEntity = CoreEntity;
    MB.entity.Editor = Editor;
    MB.entity.Entity = Entity;
    MB.entity.Event = Event;
    MB.entity.Instrument = Instrument;
    MB.entity.Label = Label;
    MB.entity.Medium = Medium;
    MB.entity.Place = Place;
    MB.entity.Recording = Recording;
    MB.entity.Release = Release;
    MB.entity.ReleaseGroup = ReleaseGroup;
    MB.entity.Series = Series;
    MB.entity.Track = Track;
    MB.entity.URL = URL;
    MB.entity.Work = Work;

    function relatedArtists(relationships) {
        return _(relationships).filter({target: {entityType: 'artist'}}).map('target').value();
    }

    var classicalRoles = /\W(baritone|cello|conductor|gamba|guitar|orch|orchestra|organ|piano|soprano|tenor|trumpet|vocals?|viola|violin): /;

    function isProbablyClassical(entity) {
        return classicalRoles.test(entity.name) || _.some(entity.relationships, function (r) {
            return _.includes(PROBABLY_CLASSICAL_LINK_TYPES, r.linkTypeID);
        });
    }

    // Used by MB.entity() to look up classes. JSON from the web service
    // usually includes a lower-case type name, which is used as the key.

    var coreEntityMapping = {
        artist:        Artist,
        event:         Event,
        instrument:    Instrument,
        label:         Label,
        area:          Area,
        place:         Place,
        recording:     Recording,
        release:       Release,
        release_group: ReleaseGroup,
        series:        Series,
        track:         Track,
        work:          Work,
        url:           URL,
        editor:        Editor,
    };
}());

export default MB.entity;
