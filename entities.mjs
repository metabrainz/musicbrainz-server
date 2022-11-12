/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/*
 * To regenerate entities.json from this file, use the following command:
 *
 *   ./script/generate_entities_json.mjs > entities.json
 */

import deepFreeze from 'deep-freeze-strict';

type AutomaticRemovalPropsT = {
  +exempt?: $ReadOnlyArray<number>,
  +extra_fks?: {+[foreignTable: string]: string},
  ...
};

type $MakeReadOnly =
  & (<T: {...}>(T) => $ReadOnly<$ObjMap<T, $MakeReadOnly>>)
  & (<T: mixed>(T) => T);

const ENTITIES = {
  annotation: {
    model: 'Annotation',
  },
  area: {
    aliases: {
      add_edit_type: 86,
      delete_edit_type: 87,
      edit_edit_type: 88,
      search_hint_type: 3,
    },
    annotations: {
      edit_type: 85,
    },
    cache: {
      id: 1,
    },
    collections: true,
    custom_tabs: ([
      'artists',
      'events',
      'labels',
      'releases',
      'recordings',
      'places',
      'users',
      'works',
    ]: $ReadOnlyArray<string>),
    date_period: true,
    disambiguation: true,
    edit_table: true,
    last_updated_column: true,
    mbid: {
      multiple: true,
      relatable: 'overview',
    },
    merging: true,
    model: 'Area',
    plural: 'areas',
    plural_url: 'areas',
    removal: {
      manual: true,
    },
    tags: true,
    type: {
      simple: true,
    },
    url: 'area',
  },
  area_alias_type: {
    cache: {
      id: 39,
    },
    model: 'AreaAliasType',
    table: 'area_alias_type',
  },
  area_type: {
    cache: {
      id: 2,
    },
    model: 'AreaType',
  },
  artist: {
    aliases: {
      add_edit_type: 6,
      delete_edit_type: 7,
      edit_edit_type: 8,
      search_hint_type: 3,
    },
    annotations: {
      edit_type: 5,
    },
    cache: {
      id: 3,
    },
    collections: true,
    custom_tabs: ([
      'releases',
      'recordings',
      'works',
      'events',
    ]: $ReadOnlyArray<string>),
    date_period: true,
    disambiguation: true,
    edit_table: true,
    ipis: true,
    isnis: true,
    last_updated_column: true,
    materialized_edit_status: true,
    mbid: {
      indexable: true,
      multiple: true,
      relatable: 'dedicated',
    },
    merging: true,
    meta_table: true,
    model: 'Artist',
    plural: 'artists',
    plural_url: 'artists',
    ratings: true,
    removal: {
      automatic: {
        exempt: ([
          1,
          2,
        ]: $ReadOnlyArray<number>),
        extra_fks: {
          artist_credit_name: 'artist',
        },
      },
    },
    report_filter: true,
    reviews: true,
    series: true,
    sitemaps_lastmod_table: true,
    sort_name: true,
    subscriptions: {
      deleted: true,
      entity: true,
    },
    tags: true,
    type: {
      simple: true,
    },
    url: 'artist',
  },
  artist_alias_type: {
    cache: {
      id: 40,
    },
    model: 'ArtistAliasType',
    table: 'artist_alias_type',
  },
  artist_credit: {
    cache: {
      id: 4,
    },
    model: 'ArtistCredit',
  },
  artist_type: {
    cache: {
      id: 5,
    },
    model: 'ArtistType',
  },
  cdstub: {
    model: 'CDStub',
    url: 'cdstub',
  },
  cdtoc: {
    model: 'CDTOC',
    url: 'cdtoc',
  },
  collection: {
    mbid: {
      multiple: true,
      relatable: false,
    },
    model: 'Collection',
    plural: 'collections',
    plural_url: 'collections',
    subscriptions: {
      entity: true,
    },
    table: 'editor_collection',
    type: {
      simple: true,
    },
    url: 'collection',
  },
  collection_type: {
    cache: {
      id: 6,
    },
    model: 'CollectionType',
  },
  cover_art_type: {
    cache: {
      id: 7,
    },
    model: 'CoverArtType',
  },
  editor: {
    last_updated_column: true,
    model: 'Editor',
    subscriptions: {
      entity: false,
    },
    url: 'user',
  },
  event: {
    aliases: {
      add_edit_type: 155,
      delete_edit_type: 156,
      edit_edit_type: 157,
      search_hint_type: 2,
    },
    annotations: {
      edit_type: 154,
    },
    cache: {
      id: 8,
    },
    collections: true,
    date_period: true,
    disambiguation: true,
    edit_table: true,
    last_updated_column: true,
    mbid: {
      indexable: true,
      multiple: true,
      relatable: 'overview',
    },
    merging: true,
    meta_table: true,
    model: 'Event',
    plural: 'events',
    plural_url: 'events',
    ratings: true,
    removal: {
      automatic: ({}: AutomaticRemovalPropsT),
    },
    reviews: true,
    series: true,
    tags: true,
    type: {
      simple: true,
    },
    url: 'event',
  },
  event_alias_type: {
    cache: {
      id: 41,
    },
    model: 'EventAliasType',
    table: 'event_alias_type',
  },
  event_type: {
    cache: {
      id: 9,
    },
    model: 'EventType',
  },
  gender: {
    cache: {
      id: 10,
    },
    model: 'Gender',
  },
  genre: {
    aliases: {
      add_edit_type: 165,
      delete_edit_type: 166,
      edit_edit_type: 167,
      search_hint_type: 2,
    },
    annotations: {
      edit_type: 164,
    },
    cache: {
      id: 333,
    },
    disambiguation: true,
    edit_table: true,
    mbid: {
      indexable: true,
      multiple: false,
      relatable: 'overview',
    },
    merging: false,
    model: 'Genre',
    plural: 'genres',
    plural_url: 'genres',
    removal: {
      manual: true,
    },
    url: 'genre',
  },
  genre_alias_type: {
    cache: {
      id: 50,
    },
    model: 'GenreAliasType',
    table: 'genre_alias_type',
  },
  instrument: {
    aliases: {
      add_edit_type: 136,
      delete_edit_type: 137,
      edit_edit_type: 138,
      search_hint_type: 2,
    },
    annotations: {
      edit_type: 135,
    },
    cache: {
      id: 11,
    },
    collections: true,
    custom_tabs: ([
      'artists',
      'releases',
      'recordings',
    ]: $ReadOnlyArray<string>),
    disambiguation: true,
    edit_table: true,
    last_updated_column: true,
    mbid: {
      indexable: true,
      multiple: true,
      relatable: 'overview',
    },
    merging: true,
    model: 'Instrument',
    plural: 'instruments',
    plural_url: 'instruments',
    removal: {
      manual: true,
    },
    tags: true,
    type: {
      simple: true,
    },
    url: 'instrument',
  },
  instrument_alias_type: {
    cache: {
      id: 42,
    },
    model: 'InstrumentAliasType',
    table: 'instrument_alias_type',
  },
  instrument_type: {
    cache: {
      id: 12,
    },
    model: 'InstrumentType',
  },
  isrc: {
    model: 'ISRC',
    url: 'isrc',
  },
  iswc: {
    model: 'ISWC',
    url: 'iswc',
  },
  label: {
    aliases: {
      add_edit_type: 16,
      delete_edit_type: 17,
      edit_edit_type: 18,
      search_hint_type: 2,
    },
    annotations: {
      edit_type: 15,
    },
    cache: {
      id: 13,
    },
    collections: true,
    date_period: true,
    disambiguation: true,
    edit_table: true,
    ipis: true,
    isnis: true,
    last_updated_column: true,
    materialized_edit_status: true,
    mbid: {
      indexable: true,
      multiple: true,
      relatable: 'dedicated',
    },
    merging: true,
    meta_table: true,
    model: 'Label',
    plural: 'labels',
    plural_url: 'labels',
    ratings: true,
    removal: {
      automatic: {
        exempt: ([
          1,
        ]: $ReadOnlyArray<number>),
        extra_fks: {
          release_label: 'label',
        },
      },
      manual: true,
    },
    report_filter: true,
    reviews: true,
    sitemaps_lastmod_table: true,
    subscriptions: {
      deleted: true,
      entity: true,
    },
    tags: true,
    type: {
      simple: true,
    },
    url: 'label',
  },
  label_alias_type: {
    cache: {
      id: 43,
    },
    model: 'LabelAliasType',
    table: 'label_alias_type',
  },
  label_type: {
    cache: {
      id: 14,
    },
    model: 'LabelType',
  },
  language: {
    cache: {
      id: 15,
    },
    model: 'Language',
  },
  link: {
    cache: {
      id: 16,
    },
    model: 'Link',
  },
  link_attribute_type: {
    cache: {
      id: 17,
    },
    last_updated_column: true,
    model: 'LinkAttributeType',
  },
  link_type: {
    cache: {
      id: 18,
    },
    last_updated_column: true,
    mbid: {
      relatable: false,
    },
    model: 'LinkType',
    url: 'relationship',
  },
  medium: {
    model: 'Medium',
  },
  medium_cdtoc: {
    model: 'MediumCDTOC',
  },
  medium_format: {
    cache: {
      id: 19,
    },
    model: 'MediumFormat',
  },
  place: {
    aliases: {
      add_edit_type: 66,
      delete_edit_type: 67,
      edit_edit_type: 68,
      search_hint_type: 2,
    },
    annotations: {
      edit_type: 65,
    },
    cache: {
      id: 20,
    },
    collections: true,
    custom_tabs: ([
      'events',
      'performances',
      'map',
    ]: $ReadOnlyArray<string>),
    date_period: true,
    disambiguation: true,
    edit_table: true,
    last_updated_column: true,
    mbid: {
      indexable: true,
      multiple: true,
      relatable: 'overview',
    },
    merging: true,
    model: 'Place',
    plural: 'places',
    plural_url: 'places',
    ratings: true,
    removal: {
      automatic: ({}: AutomaticRemovalPropsT),
    },
    reviews: true,
    sitemaps_lastmod_table: true,
    tags: true,
    type: {
      simple: true,
    },
    url: 'place',
  },
  place_alias_type: {
    cache: {
      id: 44,
    },
    model: 'PlaceAliasType',
    table: 'place_alias_type',
  },
  place_type: {
    cache: {
      id: 21,
    },
    model: 'PlaceType',
  },
  recording: {
    aliases: {
      add_edit_type: 711,
      delete_edit_type: 712,
      edit_edit_type: 713,
      search_hint_type: 2,
    },
    annotations: {
      edit_type: 75,
    },
    artist_credits: true,
    cache: {
      id: 22,
    },
    collections: true,
    custom_tabs: ([
      'fingerprints',
    ]: $ReadOnlyArray<string>),
    disambiguation: true,
    edit_table: true,
    last_updated_column: true,
    mbid: {
      multiple: true,
      relatable: 'overview',
    },
    merging: true,
    meta_table: true,
    model: 'Recording',
    plural: 'recordings',
    plural_url: 'recordings',
    ratings: true,
    removal: {
      manual: true,
    },
    report_filter: true,
    reviews: true,
    series: true,
    sitemaps_lastmod_table: true,
    tags: true,
    url: 'recording',
  },
  recording_alias_type: {
    cache: {
      id: 45,
    },
    model: 'RecordingAliasType',
    table: 'recording_alias_type',
  },
  release: {
    aliases: {
      add_edit_type: 318,
      delete_edit_type: 319,
      edit_edit_type: 320,
      search_hint_type: 2,
    },
    annotations: {
      edit_type: 35,
    },
    artist_credits: true,
    cache: {
      id: 23,
    },
    collections: true,
    cover_art: true,
    disambiguation: true,
    edit_table: true,
    last_updated_column: true,
    mbid: {
      indexable: true,
      multiple: true,
      relatable: 'overview',
    },
    merging: true,
    meta_table: true,
    model: 'Release',
    plural: 'releases',
    plural_url: 'releases',
    removal: {
      manual: true,
    },
    report_filter: true,
    series: true,
    sitemaps_lastmod_table: true,
    tags: true,
    url: 'release',
  },
  release_alias_type: {
    cache: {
      id: 46,
    },
    model: 'ReleaseAliasType',
    table: 'release_alias_type',
  },
  release_group: {
    aliases: {
      add_edit_type: 26,
      delete_edit_type: 27,
      edit_edit_type: 28,
      search_hint_type: 2,
    },
    annotations: {
      edit_type: 25,
    },
    artist_credits: true,
    cache: {
      id: 24,
    },
    collections: true,
    disambiguation: true,
    edit_table: true,
    last_updated_column: true,
    mbid: {
      indexable: true,
      multiple: true,
      relatable: 'overview',
    },
    merging: true,
    meta_table: true,
    model: 'ReleaseGroup',
    plural: 'release_groups',
    plural_url: 'release-groups',
    ratings: true,
    removal: {
      automatic: {
        extra_fks: {
          release: 'release_group',
        },
      },
    },
    report_filter: true,
    reviews: true,
    series: true,
    sitemaps_lastmod_table: true,
    tags: true,
    type: {
      complex: true,
    },
    url: 'release-group',
  },
  release_group_alias_type: {
    cache: {
      id: 47,
    },
    model: 'ReleaseGroupAliasType',
    table: 'release_group_alias_type',
  },
  release_group_secondary_type: {
    cache: {
      id: 25,
    },
    model: 'ReleaseGroupSecondaryType',
  },
  release_group_type: {
    cache: {
      id: 26,
    },
    model: 'ReleaseGroupType',
  },
  release_packaging: {
    cache: {
      id: 27,
    },
    model: 'ReleasePackaging',
  },
  release_status: {
    cache: {
      id: 28,
    },
    model: 'ReleaseStatus',
  },
  script: {
    cache: {
      id: 29,
    },
    model: 'Script',
  },
  series: {
    aliases: {
      add_edit_type: 145,
      delete_edit_type: 146,
      edit_edit_type: 147,
      search_hint_type: 2,
    },
    annotations: {
      edit_type: 144,
    },
    cache: {
      id: 30,
    },
    collections: true,
    disambiguation: true,
    edit_table: true,
    last_updated_column: true,
    mbid: {
      indexable: true,
      multiple: true,
      relatable: 'overview',
    },
    merging: true,
    model: 'Series',
    plural: 'series',
    plural_url: 'series',
    removal: {
      automatic: ({}: AutomaticRemovalPropsT),
    },
    report_filter: true,
    subscriptions: {
      deleted: true,
      entity: true,
    },
    tags: true,
    type: {
      simple: true,
    },
    url: 'series',
  },
  series_alias_type: {
    cache: {
      id: 48,
    },
    model: 'SeriesAliasType',
    table: 'series_alias_type',
  },
  series_ordering_type: {
    cache: {
      id: 31,
    },
    model: 'SeriesOrderingType',
  },
  series_type: {
    cache: {
      id: 32,
    },
    model: 'SeriesType',
  },
  tag: {
    cache: {
      id: 33,
    },
    model: 'Tag',
  },
  track: {
    artist_credits: 1,
    last_updated_column: true,
    mbid: {
      multiple: true,
      relatable: false,
    },
    model: 'Track',
    plural: 'tracks',
    plural_url: 'tracks',
    url: 'track',
  },
  url: {
    edit_table: true,
    last_updated_column: true,
    mbid: {
      multiple: true,
      no_details: true,
      relatable: 'overview',
    },
    model: 'URL',
    plural: 'urls',
    plural_url: 'urls',
    removal: {
      automatic: ({}: AutomaticRemovalPropsT),
    },
    url: 'url',
  },
  work: {
    aliases: {
      add_edit_type: 46,
      delete_edit_type: 47,
      edit_edit_type: 48,
      search_hint_type: 2,
    },
    annotations: {
      edit_type: 45,
    },
    cache: {
      id: 34,
    },
    collections: true,
    disambiguation: true,
    edit_table: true,
    last_updated_column: true,
    mbid: {
      indexable: true,
      multiple: true,
      relatable: 'overview',
    },
    merging: true,
    meta_table: true,
    model: 'Work',
    plural: 'works',
    plural_url: 'works',
    ratings: true,
    removal: {
      automatic: ({}: AutomaticRemovalPropsT),
    },
    report_filter: true,
    reviews: true,
    series: true,
    sitemaps_lastmod_table: true,
    tags: true,
    type: {
      simple: true,
    },
    url: 'work',
  },
  work_alias_type: {
    cache: {
      id: 49,
    },
    model: 'WorkAliasType',
    table: 'work_alias_type',
  },
  work_attribute: {
    cache: {
      id: 35,
    },
    model: 'WorkAttribute',
  },
  work_attribute_type: {
    cache: {
      id: 36,
    },
    model: 'WorkAttributeType',
  },
  work_attribute_type_allowed_value: {
    cache: {
      id: 37,
    },
    model: 'WorkAttributeTypeAllowedValue',
  },
  work_type: {
    cache: {
      id: 38,
    },
    model: 'WorkType',
  },
};

deepFreeze(ENTITIES);

export default (ENTITIES: $Call<$MakeReadOnly, typeof ENTITIES>);
