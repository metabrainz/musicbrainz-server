/*
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';
import * as ReactDOMServer from 'react-dom/server';

import formatLabelCode from '../../../utility/formatLabelCode.js';
import getRelatedArtists from '../edit/utility/getRelatedArtists.js';
import isEntityProbablyClassical
  from '../edit/utility/isEntityProbablyClassical.js';

import ArtistCreditLink from './components/ArtistCreditLink.js';
import DescriptiveLink from './components/DescriptiveLink.js';
import EditorLink from './components/EditorLink.js';
import EntityLink from './components/EntityLink.js';
import MediumDescription from './components/MediumDescription.js';
import {bracketedText} from './utility/bracketed.js';
import {getSourceEntityData} from './utility/catalyst.js';
import clean from './utility/clean.js';
import {cloneArrayDeep, cloneObjectDeep} from './utility/cloneDeep.mjs';
import formatTrackLength from './utility/formatTrackLength.js';
import {
  ENTITY_NAMES,
  PART_OF_SERIES_LINK_TYPES,
} from './constants.js';
import {
  artistCreditsAreEqual,
  isCompleteArtistCredit,
} from './immutable-entities.js';
import linkedEntities from './linkedEntities.mjs';
import MB from './MB.js';

(function () {
  /*
   * Base class that both core and non-core entities inherit from. The only
   * purpose this really serves is allowing the `data instanceof Entity`
   * check in MB.entity() to work.
   */
  class Entity {
    constructor(data) {
      Object.assign(this, data);
      this.name = this.name || '';
    }

    toJSON() {
      const result = {};
      for (const key in this) {
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
      return addColonText(ENTITY_NAMES[this.entityType]());
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

  /*
   * Usually, this function should be called to create new entities instead
   * of directly instantiating any of the classes below. MB.entity() caches
   * everything with a GID, so if you pass in the same entity twice, you get
   * the same object back (which is ideal, because otherwise there could be
   * a lot of duplication for things like track artists). This also allows
   * comparing entities for equality with a simple `===` instead of having
   * to compare the GIDs.
   */

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

  MB._sourceEntityInstance = null;
  MB.getSourceEntityInstance = function () {
    if (MB._sourceEntityInstance != null) {
      return MB._sourceEntityInstance;
    }
    MB._sourceEntityInstance = MB.entity(getSourceEntityData());
    return MB._sourceEntityInstance;
  };

  // Used by MB.entity() above to cache everything with a GID.
  MB.entityCache = {};

  class CoreEntity extends Entity {
    constructor(data) {
      super(data);

      this.relationships = ko.observableArray([]);

      if (data.artistCredit) {
        this.artistCredit = cloneObjectDeep(data.artistCredit);
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
              href_url: json.href_url,
              iso_3166_1_codes: json.iso_3166_1_codes,
              name: json.name,
              pretty_name: json.pretty_name,
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

  class Genre extends CoreEntity {}

  Genre.prototype.entityType = 'genre';

  class Instrument extends CoreEntity {}

  Instrument.prototype.entityType = 'instrument';

  class Label extends CoreEntity {
    selectionMessage() {
      const code = this.label_code;

      return ReactDOMServer.renderToStaticMarkup(
        <>
          {exp.l(
            'You selected {label}.',
            {label: this.reactElement({target: '_blank'})},
          )}
          {code ? (
            ' ' +
                        bracketedText(texp.l(
                          'Label code: {code}',
                          {code: formatLabelCode(code)},
                        ))
          ) : null}
        </>,
      );
    }
  }

  Label.prototype.entityType = 'label';

  class Area extends CoreEntity {
    toJSON() {
      return Object.assign(
        super.toJSON(),
        {
          containment: this.containment || [],
          iso_3166_1_codes: this.iso_3166_1_codes || [],
          iso_3166_2_codes: this.iso_3166_2_codes || [],
          iso_3166_3_codes: this.iso_3166_3_codes || [],
        },
      );
    }

    selectionMessage() {
      return ReactDOMServer.renderToStaticMarkup(
        exp.l(
          'You selected {area}.',
          {area: <DescriptiveLink entity={this.toJSON()} target="_blank" />},
        ),
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
        /*
         * Depending on where we're getting the data from (search
         * server, /ws/js...) we may have either releases or release
         * groups here. Assume the latter by default.
         */
        var appearsOnType = this.appearsOn.entityType || 'release_group';

        this.appearsOn.results = this.appearsOn.results.map(
          function (appearance) {
            return MB.entity(appearance, appearsOnType);
          },
        );
      }

      if (!this.artistCredit) {
        this.artistCredit = {names: []};
      }

      this.relatedArtists = getRelatedArtists(data.relationships);
      this.isProbablyClassical = isEntityProbablyClassical(data);

      if (this._afterRecordingCtor) {
        this._afterRecordingCtor(data);
      }
    }

    toJSON() {
      return Object.assign(
        super.toJSON(),
        {isrcs: this.isrcs, appearsOn: this.appearsOn},
      );
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
        this.mediums = data.mediums.map(x => new Medium(x));
      }

      this.relatedArtists = getRelatedArtists(data.relationships);
      this.isProbablyClassical = isEntityProbablyClassical(data);
    }

    toJSON() {
      var object = super.toJSON();

      if (Array.isArray(this.events)) {
        object.events = cloneArrayDeep(this.events);
      }

      if (Array.isArray(this.labels)) {
        object.labels = cloneArrayDeep(this.labels);
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
      if (!type) {
        return [];
      }

      var gid = PART_OF_SERIES_LINK_TYPES[type.item_entity_type];
      var linkTypeID = linkedEntities.link_type[gid].id;

      return this.displayableRelationships(viewModel)().filter(function (r) {
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

      this.tracks = data.tracks
        ? data.tracks.map(x => new Track(x))
        : [];

      this.positionName = ReactDOMServer.renderToString(
        <MediumDescription medium={this} />,
      );
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

  /*
   * Used by MB.entity() to look up classes. JSON from the web service
   * usually includes a lower-case type name, which is used as the key.
   */

  var coreEntityMapping = {
    artist:        Artist,
    event:         Event,
    genre:         Genre,
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
