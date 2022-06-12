/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// This file can be renamed to entity.js once that file is removed.

type CommonPropsT = {
  +id?: number,
  +name?: string,
};

export function createNonUrlCoreEntityObject(
  type: NonUrlCoreEntityTypeT,
  props?: CommonPropsT,
): NonUrlCoreEntityT {
  switch (type) {
    case 'area':
      return createAreaObject(props);
    case 'artist':
      return createArtistObject(props);
    case 'event':
      return createEventObject(props);
    case 'genre':
      return createGenreObject(props);
    case 'instrument':
      return createInstrumentObject(props);
    case 'label':
      return createLabelObject(props);
    case 'place':
      return createPlaceObject(props);
    case 'recording':
      return createRecordingObject(props);
    case 'release':
      return createReleaseObject(props);
    case 'release_group':
      return createReleaseGroupObject(props);
    case 'series':
      return createSeriesObject(props);
    case 'work':
      return createWorkObject(props);
    default: {
      /*:: exhaustive(type); */

      throw new Error(
        JSON.stringify(type) + ' is not a core entity type.',
      );
    }
  }
}

export function createCoreEntityObject(
  type: CoreEntityTypeT,
  props?: CommonPropsT,
): CoreEntityT {
  switch (type) {
    case 'url':
      return createUrlObject(props);
    default:
      return createNonUrlCoreEntityObject(type, props);
  }
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
    begin_date: null,
    comment: '',
    end_area: null,
    end_date: null,
    ended: false,
    entityType: 'artist',
    gender: null,
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
    end_date: null,
    ended: false,
    entityType: 'event',
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
      names: [],
    },
    barcode: null,
    comment: '',
    cover_art_presence: 'absent',
    entityType: 'release',
    gid: '',
    id: 0,
    language: null,
    languageID: null,
    last_updated: null,
    length: 0,
    name: '',
    packagingID: null,
    script: null,
    scriptID: null,
    status: null,
    statusID: null,
    quality: 0,
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
  }>,
): SeriesT {
  return {
    comment: '',
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
  }>,
): WorkT {
  return {
    artists: [],
    attributes: [],
    comment: '',
    entityType: 'work',
    gid: '',
    id: 0,
    iswcs: [],
    languages: [],
    last_updated: null,
    name: '',
    typeID: null,
    writers: [],
    ...props,
  };
}
