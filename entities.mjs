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

const ENTITIES = {
  annotation: {
    model: 'Annotation',
    table: 'annotation',
  },
  area: {
    add_edit_type: 81,
    aliases: {
      add_edit_type: 86,
      delete_edit_type: 87,
      edit_edit_type: 88,
      search_hint_type: 3,
    },
    annotations: {
      edit_type: 85,
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
    table: 'area',
    tags: true,
    type: {
      simple: true,
    },
    url: 'area',
  },
  area_alias_type: {
    model: 'AreaAliasType',
    table: 'area_alias_type',
  },
  area_type: {
    model: 'AreaType',
    table: 'area_type',
  },
  artist: {
    add_edit_type: 1,
    aliases: {
      add_edit_type: 6,
      delete_edit_type: 7,
      edit_edit_type: 8,
      search_hint_type: 3,
    },
    annotations: {
      edit_type: 5,
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
    table: 'artist',
    tags: true,
    type: {
      simple: true,
    },
    url: 'artist',
  },
  artist_alias_type: {
    model: 'ArtistAliasType',
    table: 'artist_alias_type',
  },
  artist_credit: {
    mbid: {
      multiple: true,
    },
    model: 'ArtistCredit',
    table: 'artist_credit',
  },
  artist_type: {
    model: 'ArtistType',
    table: 'artist_type',
  },
  cdstub: {
    model: 'CDStub',
    table: 'release_raw',
    url: 'cdstub',
  },
  cdtoc: {
    model: 'CDTOC',
    table: 'cdtoc',
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
    model: 'CollectionType',
    table: 'editor_collection_type',
  },
  cover_art_type: {
    model: 'CoverArtType',
    table: 'cover_art_archive.art_type',
  },
  editor: {
    last_updated_column: true,
    model: 'Editor',
    subscriptions: {
      entity: false,
    },
    table: 'editor',
    url: 'user',
  },
  event: {
    add_edit_type: 150,
    aliases: {
      add_edit_type: 155,
      delete_edit_type: 156,
      edit_edit_type: 157,
      search_hint_type: 2,
    },
    annotations: {
      edit_type: 154,
    },
    collections: true,
    date_period: true,
    disambiguation: true,
    edit_table: true,
    event_art: true,
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
    table: 'event',
    tags: true,
    type: {
      simple: true,
    },
    url: 'event',
  },
  event_alias_type: {
    model: 'EventAliasType',
    table: 'event_alias_type',
  },
  event_art_type: {
    cache: {
      id: 51,
    },
    model: 'EventArtType',
  },
  event_type: {
    model: 'EventType',
    table: 'event_type',
  },
  gender: {
    model: 'Gender',
    table: 'gender',
  },
  genre: {
    add_edit_type: 160,
    aliases: {
      add_edit_type: 165,
      delete_edit_type: 166,
      edit_edit_type: 167,
      search_hint_type: 2,
    },
    annotations: {
      edit_type: 164,
    },
    collections: true,
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
    table: 'genre',
    url: 'genre',
  },
  genre_alias_type: {
    model: 'GenreAliasType',
    table: 'genre_alias_type',
  },
  instrument: {
    add_edit_type: 131,
    aliases: {
      add_edit_type: 136,
      delete_edit_type: 137,
      edit_edit_type: 138,
      search_hint_type: 2,
    },
    annotations: {
      edit_type: 135,
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
    table: 'instrument',
    tags: true,
    type: {
      simple: true,
    },
    url: 'instrument',
  },
  instrument_alias_type: {
    model: 'InstrumentAliasType',
    table: 'instrument_alias_type',
  },
  instrument_type: {
    model: 'InstrumentType',
    table: 'instrument_type',
  },
  isrc: {
    model: 'ISRC',
    table: 'isrc',
    url: 'isrc',
  },
  iswc: {
    model: 'ISWC',
    table: 'iswc',
    url: 'iswc',
  },
  label: {
    add_edit_type: 10,
    aliases: {
      add_edit_type: 16,
      delete_edit_type: 17,
      edit_edit_type: 18,
      search_hint_type: 2,
    },
    annotations: {
      edit_type: 15,
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
    },
    report_filter: true,
    reviews: true,
    sitemaps_lastmod_table: true,
    subscriptions: {
      deleted: true,
      entity: true,
    },
    table: 'label',
    tags: true,
    type: {
      simple: true,
    },
    url: 'label',
  },
  label_alias_type: {
    model: 'LabelAliasType',
    table: 'label_alias_type',
  },
  label_type: {
    model: 'LabelType',
    table: 'label_type',
  },
  language: {
    model: 'Language',
    table: 'language',
  },
  link: {
    model: 'Link',
    table: 'link',
  },
  link_attribute_type: {
    last_updated_column: true,
    model: 'LinkAttributeType',
    table: 'link_attribute_type',
  },
  link_type: {
    last_updated_column: true,
    mbid: {
      relatable: false,
    },
    model: 'LinkType',
    table: 'link_type',
    url: 'relationship',
  },
  medium: {
    mbid: {
      multiple: true,
    },
    model: 'Medium',
    table: 'medium',
  },
  medium_cdtoc: {
    model: 'MediumCDTOC',
    table: 'medium_cdtoc',
  },
  medium_format: {
    model: 'MediumFormat',
    table: 'medium_format',
  },
  place: {
    add_edit_type: 61,
    aliases: {
      add_edit_type: 66,
      delete_edit_type: 67,
      edit_edit_type: 68,
      search_hint_type: 2,
    },
    annotations: {
      edit_type: 65,
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
    table: 'place',
    tags: true,
    type: {
      simple: true,
    },
    url: 'place',
  },
  place_alias_type: {
    model: 'PlaceAliasType',
    table: 'place_alias_type',
  },
  place_type: {
    model: 'PlaceType',
    table: 'place_type',
  },
  recording: {
    add_edit_type: 71,
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
    table: 'recording',
    tags: true,
    url: 'recording',
  },
  recording_alias_type: {
    model: 'RecordingAliasType',
    table: 'recording_alias_type',
  },
  release: {
    add_edit_type: 31,
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
    table: 'release',
    tags: true,
    url: 'release',
  },
  release_alias_type: {
    model: 'ReleaseAliasType',
    table: 'release_alias_type',
  },
  release_group: {
    add_edit_type: 20,
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
    table: 'release_group',
    tags: true,
    type: {
      complex: true,
    },
    url: 'release-group',
  },
  release_group_alias_type: {
    model: 'ReleaseGroupAliasType',
    table: 'release_group_alias_type',
  },
  release_group_secondary_type: {
    model: 'ReleaseGroupSecondaryType',
    table: 'release_group_secondary_type',
  },
  release_group_type: {
    model: 'ReleaseGroupType',
    table: 'release_group_primary_type',
  },
  release_packaging: {
    model: 'ReleasePackaging',
    table: 'release_packaging',
  },
  release_status: {
    model: 'ReleaseStatus',
    table: 'release_status',
  },
  script: {
    model: 'Script',
    table: 'script',
  },
  series: {
    add_edit_type: 140,
    aliases: {
      add_edit_type: 145,
      delete_edit_type: 146,
      edit_edit_type: 147,
      search_hint_type: 2,
    },
    annotations: {
      edit_type: 144,
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
    table: 'series',
    tags: true,
    type: {
      simple: true,
    },
    url: 'series',
  },
  series_alias_type: {
    model: 'SeriesAliasType',
    table: 'series_alias_type',
  },
  series_ordering_type: {
    model: 'SeriesOrderingType',
    table: 'series_ordering_type',
  },
  series_type: {
    model: 'SeriesType',
    table: 'series_type',
  },
  tag: {
    model: 'Tag',
    table: 'tag',
  },
  track: {
    artist_credits: true,
    last_updated_column: true,
    mbid: {
      multiple: true,
      relatable: false,
    },
    model: 'Track',
    plural: 'tracks',
    plural_url: 'tracks',
    table: 'track',
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
    table: 'url',
    url: 'url',
  },
  work: {
    add_edit_type: 41,
    aliases: {
      add_edit_type: 46,
      delete_edit_type: 47,
      edit_edit_type: 48,
      search_hint_type: 2,
    },
    annotations: {
      edit_type: 45,
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
    table: 'work',
    tags: true,
    type: {
      simple: true,
    },
    url: 'work',
  },
  work_alias_type: {
    model: 'WorkAliasType',
    table: 'work_alias_type',
  },
  work_attribute: {
    model: 'WorkAttribute',
    table: 'work_attribute',
  },
  work_attribute_type: {
    model: 'WorkAttributeType',
    table: 'work_attribute_type',
  },
  work_attribute_type_allowed_value: {
    model: 'WorkAttributeTypeAllowedValue',
    table: 'work_attribute_type_allowed_value',
  },
  work_type: {
    model: 'WorkType',
    table: 'work_type',
  },
};

deepFreeze(ENTITIES);

export default (ENTITIES: DeepReadOnly<typeof ENTITIES>);
