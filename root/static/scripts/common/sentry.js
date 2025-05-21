/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as Sentry from '@sentry/browser';

import {maybeGetCatalystContext} from './utility/catalyst.js';
import escapeRegExp from './utility/escapeRegExp.mjs';
import * as DBDefs from './DBDefs-client.mjs';

Sentry.init({
  allowUrls: [
    new RegExp(escapeRegExp(DBDefs.STATIC_RESOURCES_LOCATION) + '/.+\\.js$'),
  ],
  dsn: DBDefs.SENTRY_DSN_PUBLIC,
  environment: DBDefs.GIT_BRANCH,
  release: DBDefs.GIT_SHA,
});

const user = maybeGetCatalystContext()?.user;
if (user && user.id) {
  Sentry.setUser({
    id: user.id,
    username: user.name,
  });
}
