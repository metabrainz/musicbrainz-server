// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2017 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const Raven = require('raven-js');

const DBDefs = require('./DBDefs');
const {user} = require('./utility/getScriptArgs')();

if (user && user.id) {
  Raven.setUserContext({
    id: user.id,
    username: user.name,
  });
}

Raven.config(DBDefs.SENTRY_DSN_PUBLIC, {
  tags: {
    git_commit: DBDefs.GIT_SHA,
  },
  whitelistUrls: [
    new RegExp(DBDefs.STATIC_RESOURCES_LOCATION + '/.+\\.js$'),
  ],
}).install();
