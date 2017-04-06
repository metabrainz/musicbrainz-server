// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

'use strict';

require('babel-core/register');

const fs = require('fs');
const Raven = require('raven');

const createServer = require('./server/createServer');
const DBDefs = require('./server/DBDefs');
const gettext = require('./server/gettext');
const {clearRequireCache} = require('./server/utils');

const yargs = require('yargs')
  .option('socket', {
    alias: 's',
    default: DBDefs.RENDERER_SOCKET,
    describe: 'UNIX socket path',
  });

Raven.config(DBDefs.SENTRY_DSN).install();

const SOCKET_PATH = yargs.argv.socket;

const socketServer = createServer(SOCKET_PATH);

const cleanup = Raven.wrap(function () {
  socketServer.close(function () {
    fs.unlinkSync(SOCKET_PATH);
    process.exit();
  });
});

const hup = Raven.wrap(function () {
  clearRequireCache();
  gettext.clearHandles();
  DBDefs.reload();
});

process.on('SIGINT', cleanup);
process.on('SIGTERM', cleanup);
process.on('SIGHUP', hup);
