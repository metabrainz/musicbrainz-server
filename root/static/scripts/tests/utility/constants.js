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
  is_limited: false,
  languages: [],
  last_login_date: '2023-05-16T00:20:43Z',
  name: 'editor1',
  preferences: {
    datetime_format: '%Y-%m-%d %H:%M %Z',
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
