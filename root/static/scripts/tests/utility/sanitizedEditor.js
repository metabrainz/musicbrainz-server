/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import sanitizedEditor from '../../../../utility/sanitizedEditor.mjs';

const genericEditor = {
  age: 20,
  area: null,
  avatar: '',
  biography: '',
  birth_date: {day: 1, month: 1, year: 1111},
  email: 'example@example.com',
  email_confirmation_date: '2013-11-25T13:54:19Z',
  entityType: 'editor',
  gender: null,
  has_confirmed_email_address: true,
  has_email_address: true,
  is_charter: false,
  languages: [],
  last_login_date: '2023-05-16T00:20:43Z',
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
  registration_date: '2007-05-31T16:05:32Z',
  website: 'http://example.com',
};

const normalEditor = {
  ...genericEditor,
  deleted: false,
  id: 1,
  is_limited: false,
  name: 'editor1',
  privileges: 0,
};

const sanitizedNormalEditor = {
  avatar: '',
  deleted: false,
  entityType: 'editor',
  id: 1,
  is_limited: false,
  name: 'editor1',
  privileges: 0,
};

const deletedEditor = {
  ...genericEditor,
  deleted: true,
  id: 123,
  is_limited: false,
  name: 'Deleted Editor #123',
  privileges: 0,
};

const sanitizedDeletedEditor = {
  avatar: '',
  deleted: true,
  entityType: 'editor',
  id: 123,
  is_limited: false,
  name: 'Deleted Editor #123',
  privileges: 0,
};

const autoEditor = {
  ...genericEditor,
  deleted: false,
  id: 2,
  is_limited: false,
  name: 'Priv McPrivileged',
  privileges: 1,
};

const sanitizedAutoEditor = {
  avatar: '',
  deleted: false,
  entityType: 'editor',
  id: 2,
  is_limited: false,
  name: 'Priv McPrivileged',
  privileges: 1,
};

const bannedEditor = {
  ...genericEditor,
  deleted: false,
  id: 3,
  is_limited: false,
  name: 'Gaiseric',
  privileges: 3072,
};

const sanitizedBannedEditor = {
  avatar: '',
  deleted: false,
  entityType: 'editor',
  id: 3,
  is_limited: false,
  name: 'Gaiseric',
  privileges: 0,
};

const limitedEditor = {
  ...genericEditor,
  deleted: false,
  id: 5,
  is_limited: true,
  name: 'Nancy NewEditor',
  privileges: 0,
};

const sanitizedLimitedEditor = {
  avatar: '',
  deleted: false,
  entityType: 'editor',
  id: 5,
  is_limited: true,
  name: 'Nancy NewEditor',
  privileges: 0,
};

test('sanitizedEditor', function (t) {
  t.plan(5);

  t.deepEqual(
    sanitizedEditor(normalEditor),
    sanitizedNormalEditor,
    'Standard editor is sanitized as expected',
  );

  t.deepEqual(
    sanitizedEditor(deletedEditor),
    sanitizedDeletedEditor,
    'Deleted editor is sanitized as expected',
  );

  t.deepEqual(
    sanitizedEditor(autoEditor),
    sanitizedAutoEditor,
    'Autoeditor is sanitized as expected (public privileges are kept)',
  );

  t.deepEqual(
    sanitizedEditor(bannedEditor),
    sanitizedBannedEditor,
    'Banned editor is sanitized as expected (hidden privileges are dropped)',
  );

  t.deepEqual(
    sanitizedEditor(limitedEditor),
    sanitizedLimitedEditor,
    'Beginner editor is sanitized as expected',
  );
});
