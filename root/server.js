// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

'use strict';

require('babel-core/register');

const cluster = require('cluster');
const fs = require('fs');
const Raven = require('raven');
const spawnSync = require('child_process').spawnSync;

const createServer = require('./server/createServer');
const DBDefs = require('./server/DBDefs');
const gettext = require('./server/gettext');
const {clearRequireCache} = require('./server/utils');

const yargs = require('yargs')
  .option('socket', {
    alias: 's',
    default: DBDefs.RENDERER_SOCKET,
    describe: 'UNIX socket path',
  })
  .option('workers', {
    alias: 'w',
    default: process.env.RENDERER_WORKERS || 1,
    describe: 'Number of workers to spawn',
  });

Raven.config(DBDefs.SENTRY_DSN).install();

const SOCKET_PATH = yargs.argv.socket;

if (fs.existsSync(SOCKET_PATH)) {
  if (spawnSync('lsof', [SOCKET_PATH]).status) {
    fs.unlinkSync(SOCKET_PATH);
  } else {
    console.error('socket ' + SOCKET_PATH + ' exists and is in use');
    process.exit(1);
  }
}

if (cluster.isMaster) {
  const workers = yargs.argv.workers;
  for (let i = 0; i < workers; i++) {
    cluster.fork();
  }
  console.log(`server.js listening on ${SOCKET_PATH} (pid ${process.pid})`);

  function killWorkers(signal) {
    for (const id in cluster.workers) {
      cluster.workers[id].kill(signal);
    }
  }

  const cleanup = function (signal) {
    killWorkers(signal);
    fs.unlinkSync(SOCKET_PATH);
    process.exit();
  };

  process.on('SIGINT', () => cleanup('SIGINT'));
  process.on('SIGTERM', () => cleanup('SIGTERM'));
  process.on('SIGHUP', () => killWorkers('SIGHUP'));
} else {
  const socketServer = createServer(SOCKET_PATH);

  const cleanup = Raven.wrap(function () {
    socketServer.close(function () {
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
}
