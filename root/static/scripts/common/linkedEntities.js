/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable import/no-commonjs */
/* eslint-disable multiline-comment-style */
/* eslint-disable sort-keys */
/* eslint-disable spaced-comment */

/*::
export type LinkedEntitiesT = {
  area: {
    [areaId: number]: AreaT,
  },
  artist: {
    [artistId: number]: ArtistT,
  },
  artist_type: {
    [artistId: number]: ArtistTypeT,
  },
  event: {
    [eventId: number]: EventT,
  },
  genre: {
    [genreId: number]: GenreT,
  },
  instrument: {
    [instrumentId: number]: InstrumentT,
  },
  label: {
    [labelId: number]: LabelT,
  },
  language: {
    [languageId: number]: LanguageT,
  },
  link_attribute_type: {
    [linkAttributeTypeIdOrGid: StrOrNum]: LinkAttrTypeT,
  },
  link_type: {
    [linkTypeIdOrGid: StrOrNum]: LinkTypeT,
  },
  link_type_tree: {
    [entityTypes: string]: $ReadOnlyArray<LinkTypeT>,
  },
  mergeLinkedEntities: (update: ?$Shape<LinkedEntitiesT>) => void,
  place: {
    [placeId: number]: PlaceT,
  },
  recording: {
    [recordingId: number]: RecordingT,
  },
  release: {
    [releaseId: number]: ReleaseT,
  },
  release_group: {
    [releaseGroupId: number]: ReleaseGroupT,
  },
  release_group_primary_type: {
    [releaseGroupPrimaryTypeId: number]: ReleaseGroupTypeT,
  },
  release_group_secondary_type: {
    [releaseGroupSecondaryTypeId: number]: ReleaseGroupSecondaryTypeT,
  },
  release_packaging: {
    [releasePackagingId: number]: ReleasePackagingT,
  },
  release_status: {
    [releaseStatusId: number]: ReleaseStatusT,
  },
  script: {
    [scriptId: number]: ScriptT,
  },
  series: {
    [seriesId: number]: SeriesT,
  },
  series_ordering_type: {
    [seriesOrderingTypeId: number]: SeriesOrderingTypeT,
  },
  series_type: {
    [seriesTypeId: number]: SeriesTypeT,
  },
  url: {
    [urlId: number]: UrlT,
  },
  work: {
    [workId: number]: WorkT,
  },
  work_attribute_type: {
    [workAttributeTypeId: number]: WorkAttributeTypeT,
  },
  ...
};
*/

const EMPTY_OBJECT = Object.freeze({});

const linkedEntities/*: LinkedEntitiesT */ = Object.create(Object.seal({
  artist_type:                    EMPTY_OBJECT,
  language:                       EMPTY_OBJECT,
  link_attribute_type:            EMPTY_OBJECT,
  link_type:                      EMPTY_OBJECT,
  link_type_tree:                 EMPTY_OBJECT,
  recording:                      EMPTY_OBJECT,
  release:                        EMPTY_OBJECT,
  release_group_primary_type:     EMPTY_OBJECT,
  release_group_secondary_type:   EMPTY_OBJECT,
  release_packaging:              EMPTY_OBJECT,
  release_status:                 EMPTY_OBJECT,
  script:                         EMPTY_OBJECT,
  series:                         EMPTY_OBJECT,
  series_ordering_type:           EMPTY_OBJECT,
  series_type:                    EMPTY_OBJECT,
  work:                           EMPTY_OBJECT,
  work_attribute_type:            EMPTY_OBJECT,

  mergeLinkedEntities(update/*: ?$Shape<LinkedEntitiesT> */) {
    if (update) {
      for (const [type, entities] of Object.entries(update)) {
        if (Object.prototype.hasOwnProperty.call(linkedEntities, type)) {
          Object.assign(linkedEntities[type], entities);
        } else {
          linkedEntities[type] = entities;
        }
      }
    }
  },

  setLinkedEntities(update/*: ?LinkedEntitiesT */) {
    for (const key of Object.keys(linkedEntities)) {
      // $FlowIgnore[incompatible-type]
      delete linkedEntities[key];
      /*
       * The above line is deleting the own property only, not the one on the
       * prototype. However, Flow thinks it'll make the object key undefined.
       */
    }
    if (update) {
      Object.assign(linkedEntities, update);
    }
  },
}));

module.exports = linkedEntities;
