/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

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
  edit: {
    [editId: number]: EditWithIdT,
  },
  editor: {
    [editorId: number]: EditorT,
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
    [entityTypes: string]: Array<LinkTypeT>,
  },
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
    [seriesTypeId: string]: SeriesTypeT,
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
  work_type: {
    [workTypeId: string]: WorkTypeT,
  },
  ...
};
*/

// $FlowIgnore[method-unbinding]
const hasOwnProperty = Object.prototype.hasOwnProperty;

const EMPTY_OBJECT = Object.freeze({});

const linkedEntities/*: LinkedEntitiesT */ = Object.create(Object.seal({
  area:                           EMPTY_OBJECT,
  artist:                         EMPTY_OBJECT,
  artist_type:                    EMPTY_OBJECT,
  edit:                           EMPTY_OBJECT,
  editor:                         EMPTY_OBJECT,
  event:                          EMPTY_OBJECT,
  genre:                          EMPTY_OBJECT,
  instrument:                     EMPTY_OBJECT,
  label:                          EMPTY_OBJECT,
  language:                       EMPTY_OBJECT,
  link_attribute_type:            EMPTY_OBJECT,
  link_type:                      EMPTY_OBJECT,
  link_type_tree:                 EMPTY_OBJECT,
  place:                          EMPTY_OBJECT,
  recording:                      EMPTY_OBJECT,
  release:                        EMPTY_OBJECT,
  release_group:                  EMPTY_OBJECT,
  release_group_primary_type:     EMPTY_OBJECT,
  release_group_secondary_type:   EMPTY_OBJECT,
  release_packaging:              EMPTY_OBJECT,
  release_status:                 EMPTY_OBJECT,
  script:                         EMPTY_OBJECT,
  series:                         EMPTY_OBJECT,
  series_ordering_type:           EMPTY_OBJECT,
  series_type:                    EMPTY_OBJECT,
  url:                            EMPTY_OBJECT,
  work:                           EMPTY_OBJECT,
  work_attribute_type:            EMPTY_OBJECT,
  work_type:                      EMPTY_OBJECT,
}));

export default linkedEntities;

export function mergeLinkedEntities(
  update/*: ?$ReadOnly<$Partial<LinkedEntitiesT>> */,
)/*: void */ {
  if (update) {
    for (const [type, entities] of Object.entries(update)) {
      if (hasOwnProperty.call(linkedEntities, type)) {
        Object.assign(linkedEntities[type], entities);
      } else {
        linkedEntities[type] = entities;
      }
    }
  }
}

export function setLinkedEntities(
  update/*: ?LinkedEntitiesT */,
)/*: void */ {
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
}
