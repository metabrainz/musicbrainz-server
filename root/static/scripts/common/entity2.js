/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// This file can be renamed to entity.js once that file is removed.

type CommonPropsT = {
  +gid?: string,
  +id?: number,
  +name?: string,
};

export function createNonUrlRelatableEntityObject(
  type: NonUrlRelatableEntityTypeT,
  props?: CommonPropsT,
): NonUrlRelatableEntityT {
  return match (type) {
    'area' => createAreaObject(props),
    'artist' => createArtistObject(props),
    'event' => createEventObject(props),
    'genre' => createGenreObject(props),
    'instrument' => createInstrumentObject(props),
    'label' => createLabelObject(props),
    'place' => createPlaceObject(props),
    'recording' => createRecordingObject(props),
    'release' => createReleaseObject(props),
    'release_group' => createReleaseGroupObject(props),
    'series' => createSeriesObject(props),
    'work' => createWorkObject(props),
  };
}

export function createRelatableEntityObject(
  type: RelatableEntityTypeT,
  props?: CommonPropsT,
): RelatableEntityT {
  return match (type) {
    'url' => createUrlObject(props),
    _ as type => createNonUrlRelatableEntityObject(type, props),
  };
}

export function createAreaObject(
  props?: $ReadOnly<{
    ...CommonPropsT,
  }>,
): AreaT {
  return {
    begin_date: null,
    comment: '',
    containment: null,
    country_code: '',
    editsPending: false,
    end_date: null,
    ended: false,
    entityType: 'area',
    gid: '',
    id: 0,
    iso_3166_1_codes: [],
    iso_3166_2_codes: [],
    iso_3166_3_codes: [],
    last_updated: null,
    name: '',
    primary_code: '',
    typeID: null,
    ...props,
  };
}

export function createArtistObject(
  props?: $ReadOnly<{
    ...CommonPropsT,
  }>,
): ArtistT {
  return {
    area: null,
    begin_area: null,
    begin_area_id: null,
    begin_date: null,
    comment: '',
    editsPending: false,
    end_area: null,
    end_area_id: null,
    end_date: null,
    ended: false,
    entityType: 'artist',
    gender: null,
    gender_id: null,
    gid: '',
    id: 0,
    ipi_codes: [],
    isni_codes: [],
    last_updated: null,
    name: '',
    sort_name: '',
    typeID: null,
    ...props,
  };
}

export function createEventObject(
  props?: $ReadOnly<{
    ...CommonPropsT,
  }>,
): EventT {
  return {
    areas: [],
    begin_date: null,
    cancelled: false,
    comment: '',
    editsPending: false,
    end_date: null,
    ended: false,
    entityType: 'event',
    event_art_presence: 'absent',
    gid: '',
    id: 0,
    last_updated: null,
    name: '',
    performers: [],
    places: [],
    related_series: [],
    time: '',
    typeID: null,
    ...props,
  };
}

export function createGenreObject(
  props?: $ReadOnly<{
    ...CommonPropsT,
  }>,
): GenreT {
  return {
    comment: '',
    editsPending: false,
    entityType: 'genre',
    gid: '',
    id: 0,
    last_updated: null,
    name: '',
    ...props,
  };
}

export function createInstrumentObject(
  props?: $ReadOnly<{
    ...CommonPropsT,
  }>,
): InstrumentT {
  return {
    comment: '',
    description: '',
    editsPending: false,
    entityType: 'instrument',
    gid: '',
    id: 0,
    last_updated: null,
    name: '',
    typeID: null,
    ...props,
  };
}

export function createLabelObject(
  props?: $ReadOnly<{
    ...CommonPropsT,
  }>,
): LabelT {
  return {
    area: null,
    begin_date: null,
    comment: '',
    editsPending: false,
    end_date: null,
    ended: false,
    entityType: 'label',
    gid: '',
    id: 0,
    ipi_codes: [],
    isni_codes: [],
    label_code: 0,
    last_updated: null,
    name: '',
    typeID: null,
    ...props,
  };
}

export function createPlaceObject(
  props?: $ReadOnly<{
    ...CommonPropsT,
  }>,
): PlaceT {
  return {
    address: '',
    area: null,
    begin_date: null,
    comment: '',
    coordinates: null,
    editsPending: false,
    end_date: null,
    ended: false,
    entityType: 'place',
    gid: '',
    id: 0,
    last_updated: null,
    name: '',
    typeID: null,
    ...props,
  };
}

export function createRecordingObject(
  props?: $ReadOnly<{
    ...CommonPropsT,
  }>,
): RecordingT {
  return {
    comment: '',
    editsPending: false,
    entityType: 'recording',
    gid: '',
    id: 0,
    isrcs: [],
    last_updated: null,
    length: 0,
    name: '',
    related_works: [],
    video: false,
    ...props,
  };
}

export function createReleaseObject(
  props?: $ReadOnly<{
    ...CommonPropsT,
  }>,
): ReleaseT {
  return {
    artist: '',
    artistCredit: {
      names: ([]: $ReadOnlyArray<ArtistCreditNameT>),
    },
    barcode: null,
    comment: '',
    cover_art_presence: 'absent',
    editsPending: false,
    entityType: 'release',
    gid: '',
    has_no_tracks: true,
    id: 0,
    language: null,
    languageID: null,
    last_updated: null,
    length: 0,
    name: '',
    packagingID: null,
    quality: 0,
    script: null,
    scriptID: null,
    status: null,
    statusID: null,
    ...props,
  };
}

export function createReleaseGroupObject(
  props?: $ReadOnly<{
    ...CommonPropsT,
  }>,
): ReleaseGroupT {
  return {
    artist: '',
    artistCredit: {
      names: [],
    },
    comment: '',
    editsPending: false,
    entityType: 'release_group',
    firstReleaseDate: null,
    gid: '',
    hasCoverArt: false,
    id: 0,
    l_type_name: null,
    last_updated: null,
    name: '',
    release_count: 0,
    review_count: 0,
    secondaryTypeIDs: [],
    typeID: null,
    typeName: '',
    ...props,
  };
}

export function createSeriesObject(
  props?: $ReadOnly<{
    ...CommonPropsT,
    +orderingTypeID?: number,
  }>,
): SeriesT {
  return {
    comment: '',
    editsPending: false,
    entityType: 'series',
    gid: '',
    id: 0,
    last_updated: null,
    name: '',
    orderingTypeID: 1,
    typeID: null,
    ...props,
  };
}

export function createUrlObject(
  props?: $ReadOnly<{
    ...CommonPropsT,
  }>,
): UrlT {
  return {
    decoded: '',
    editsPending: false,
    entityType: 'url',
    gid: '',
    href_url: '',
    id: 0,
    last_updated: null,
    name: '',
    pretty_name: '',
    ...props,
  };
}

export function createWorkObject(
  props?: $ReadOnly<{
    ...CommonPropsT,
    +_fromBatchCreateWorksDialog?: boolean,
    +languages?: $ReadOnlyArray<WorkLanguageT>,
    +typeID?: number | null,
  }>,
): WorkT {
  return {
    artists: [],
    attributes: [],
    authors: [],
    comment: '',
    editsPending: false,
    entityType: 'work',
    gid: '',
    id: 0,
    iswcs: [],
    languages: [],
    last_updated: null,
    name: '',
    other_artists: [],
    typeID: null,
    ...props,
  };
}
