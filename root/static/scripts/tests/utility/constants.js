/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export const genericArea: AreaT = {
  begin_date: null,
  comment: '',
  containment: null,
  country_code: '',
  editsPending: false,
  end_date: null,
  ended: false,
  entityType: 'area',
  gid: 'b8aa865e-ffec-4562-b3f3-00c9a603d693',
  id: 123,
  iso_3166_1_codes: [],
  iso_3166_2_codes: [],
  iso_3166_3_codes: [],
  last_updated: null,
  name: 'Test Area',
  primary_code: '',
  typeID: null,
};

export const genericArtist: ArtistT = {
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
  gid: 'daa7b69c-bb32-486a-8b88-260327938568',
  id: 123,
  ipi_codes: [],
  isni_codes: [],
  last_updated: null,
  name: 'Test Artist',
  sort_name: 'Artist, Test',
  typeID: null,
};

export const genericCDToc: CDTocT = {
  discid: 'Wt.1HiYD17SbduR39yKqxoZ2o9k-',
  entityType: 'cdtoc',
  freedb_id: '2f0f1105',
  id: 99836,
  leadout_offset: 289458,
  length: 3859440,
  track_count: 5,
  track_details: [
    {
      end_sectors: 56393,
      end_time: 751906,
      length_sectors: 56210,
      length_time: 749466,
      start_sectors: 183,
      start_time: 2440,
    },
    {
      end_sectors: 87013,
      end_time: 1160173,
      length_sectors: 30620,
      length_time: 408266,
      start_sectors: 56393,
      start_time: 751906,
    },
    {
      end_sectors: 103208,
      end_time: 1376106,
      length_sectors: 16195,
      length_time: 215933,
      start_sectors: 87013,
      start_time: 1160173,
    },
    {
      end_sectors: 159188,
      end_time: 2122506,
      length_sectors: 55980,
      length_time: 746400,
      start_sectors: 103208,
      start_time: 1376106,
    },
    {
      end_sectors: 289458,
      end_time: 3859440,
      length_sectors: 130270,
      length_time: 1736933,
      start_sectors: 159188,
      start_time: 2122506,
    },
  ],
  track_offset: [183, 56393, 87013, 103208, 159188],
};

export const genericEditor: UnsanitizedEditorT = {
  age: 20,
  area: null,
  avatar: '',
  biography: '',
  birth_date: {day: 1, month: 1, year: 1111},
  deleted: false,
  email: 'example@example.com',
  email_confirmation_date: '2013-11-25T13:54:19Z',
  entityType: 'editor',
  gender: null,
  has_confirmed_email_address: true,
  has_email_address: true,
  id: 1,
  is_charter: false,
  languages: [],
  last_login_date: '2023-05-16T00:20:43Z',
  name: 'editor1',
  preferences: {
    datetime_format: '%Y-%m-%d %H:%M %Z',
    email_on_abstain: true,
    email_on_no_vote: true,
    email_on_notes: true,
    email_on_vote: true,
    public_ratings: true,
    public_subscriptions: true,
    public_tags: true,
    subscribe_to_created_artists: true,
    subscribe_to_created_labels: true,
    subscribe_to_created_series: true,
    subscriptions_email_period: 'daily',
    timezone: 'UTC',
  },
  privileges: 0,
  registration_date: '2007-05-31T16:05:32Z',
  website: 'http://example.com',
};

export const genericIswc: IswcT = {
  editsPending: false,
  entityType: 'iswc',
  id: 123,
  iswc: 'T-345246800-1',
  work_id: 123,
};

export const genericRecording: RecordingT = {
  artistCredit: {
    names: [
      {
        artist: genericArtist,
        joinPhrase: '',
        name: 'Test Artist',
      },
    ],
  },
  comment: '',
  editsPending: false,
  entityType: 'recording',
  gid: 'dff82387-d728-4fd9-9e4b-2c292b34949d',
  id: 123,
  isrcs: [],
  last_updated: null,
  length: 9001,
  name: 'Test Recording',
  related_works: [],
  video: false,
};

export const genericUrl: UrlT = {
  decoded: 'https://musicbrainz.org',
  editsPending: false,
  entityType: 'url',
  gid: 'b8aa865e-ffec-4562-b3f3-00c9a603d693',
  href_url: 'https://musicbrainz.org',
  id: 123,
  last_updated: null,
  name: 'https://musicbrainz.org',
  pretty_name: 'https://musicbrainz.org',
};

export const genericWork: WorkT = {
  artists: [],
  attributes: [],
  authors: [],
  comment: '',
  editsPending: false,
  entityType: 'work',
  gid: 'daa7b69c-bb32-486a-8b88-260327938568',
  id: 123,
  iswcs: [],
  languages: [],
  last_updated: null,
  misc_artists: [],
  name: 'Test Work',
  typeID: null,
};
