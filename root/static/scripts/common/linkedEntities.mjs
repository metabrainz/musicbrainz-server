/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import isObjectEmpty from './utility/isObjectEmpty.js';

export type LinkedEntitiesT = {
  area: {
    [areaId: number]: AreaT,
  },
  area_alias_type: {
    [typeId: number]: AreaAliasTypeT,
  },
  area_type: {
    [areaTypeId: number]: AreaTypeT,
  },
  artist: {
    [artistId: number]: ArtistT,
  },
  artist_alias_type: {
    [typeId: number]: ArtistAliasTypeT,
  },
  artist_type: {
    [artistId: number]: ArtistTypeT,
  },
  collection_type: {
    [collectionTypeId: number]: CollectionTypeT,
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
  event_alias_type: {
    [typeId: number]: EventAliasTypeT,
  },
  event_type: {
    [eventTypeId: number]: EventTypeT,
  },
  genre: {
    [genreId: number]: GenreT,
  },
  genre_alias_type: {
    [typeId: number]: GenreAliasTypeT,
  },
  instrument: {
    [instrumentId: number]: InstrumentT,
  },
  instrument_alias_type: {
    [typeId: number]: InstrumentAliasTypeT,
  },
  instrument_type: {
    [instrumentTypeId: number]: InstrumentTypeT,
  },
  label: {
    [labelId: number]: LabelT,
  },
  label_alias_type: {
    [typeId: number]: LabelAliasTypeT,
  },
  label_type: {
    [labelTypeId: number]: LabelTypeT,
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
  place_alias_type: {
    [typeId: number]: PlaceAliasTypeT,
  },
  place_type: {
    [placeTypeId: number]: PlaceTypeT,
  },
  recording: {
    [recordingId: number]: RecordingT,
  },
  recording_alias_type: {
    [typeId: number]: RecordingAliasTypeT,
  },
  release: {
    [releaseId: number]: ReleaseT,
  },
  release_alias_type: {
    [typeId: number]: ReleaseAliasTypeT,
  },
  release_group: {
    [releaseGroupId: number]: ReleaseGroupT,
  },
  release_group_alias_type: {
    [typeId: number]: ReleaseGroupAliasTypeT,
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
  series_alias_type: {
    [typeId: number]: SeriesAliasTypeT,
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
  work_alias_type: {
    [typeId: number]: WorkAliasTypeT,
  },
  work_attribute_type: {
    [workAttributeTypeId: number]: WorkAttributeTypeT,
  },
  work_type: {
    [workTypeId: string]: WorkTypeT,
  },
};

// $FlowIgnore[method-unbinding]
const hasOwnProperty = Object.prototype.hasOwnProperty;

const linkedEntities: LinkedEntitiesT = Object.seal({
  area:                           {},
  area_alias_type:                {},
  area_type:                      {},
  artist:                         {},
  artist_alias_type:              {},
  artist_type:                    {},
  collection_type:                {},
  edit:                           {},
  editor:                         {},
  event:                          {},
  event_alias_type:               {},
  event_type:                     {},
  genre:                          {},
  genre_alias_type:               {},
  instrument:                     {},
  instrument_alias_type:          {},
  instrument_type:                {},
  label:                          {},
  label_alias_type:               {},
  label_type:                     {},
  language:                       {},
  link_attribute_type:            {},
  link_type:                      {},
  link_type_tree:                 {},
  place:                          {},
  place_alias_type:               {},
  place_type:                     {},
  recording:                      {},
  recording_alias_type:           {},
  release:                        {},
  release_alias_type:             {},
  release_group:                  {},
  release_group_alias_type:       {},
  release_group_primary_type:     {},
  release_group_secondary_type:   {},
  release_packaging:              {},
  release_status:                 {},
  script:                         {},
  series:                         {},
  series_alias_type:              {},
  series_ordering_type:           {},
  series_type:                    {},
  url:                            {},
  work:                           {},
  work_alias_type:                {},
  work_attribute_type:            {},
  work_type:                      {},
});

export default linkedEntities;

export function mergeLinkedEntities(
  update: ?$ReadOnly<$Partial<LinkedEntitiesT>>,
): void {
  if (update) {
    for (const [type, entities] of Object.entries(update)) {
      if (hasOwnProperty.call(linkedEntities, type)) {
        if (entities != null) {
          if (isObjectEmpty(linkedEntities[type])) {
            // $FlowIgnore[incompatible-type]
            linkedEntities[type] = entities;
          } else {
            Object.assign(linkedEntities[type], entities);
          }
        }
      } else {
        throw new Error(
          JSON.stringify(type) +
          ' is not a valid type assignable to linkedEntities',
        );
      }
    }
  }
}

const linkedEntityTypes = Object.keys(linkedEntities);

export function setLinkedEntities(
  update: ?$Partial<LinkedEntitiesT>,
): void {
  for (const key of linkedEntityTypes) {
    if (!isObjectEmpty(linkedEntities[key])) {
      linkedEntities[key] = {};
    }
  }
  if (update) {
    mergeLinkedEntities(update);
  }
}

setLinkedEntities({artist: undefined});
