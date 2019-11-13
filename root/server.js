// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

/* eslint-disable import/no-commonjs */

'use strict';

const Raven = require('raven');
const DBDefs = require('./static/scripts/common/DBDefs');
Raven.config(DBDefs.SENTRY_DSN).install();

const cluster = require('cluster');
const fs = require('fs');
const spawnSync = require('child_process').spawnSync;
const _ = require('lodash');

const createServer = require('./server/createServer');
const {clearRequireCache} = require('./server/utils');
const writeCoverage = require('./utility/writeCoverage');

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

const SOCKET_PATH = yargs.argv.socket;
const WORKER_COUNT = yargs.argv.workers;
const DISCONNECT_TIMEOUT = 10000;

if (cluster.isMaster) {
  if (fs.existsSync(SOCKET_PATH)) {
    if (spawnSync('lsof', [SOCKET_PATH]).status) {
      fs.unlinkSync(SOCKET_PATH);
    } else {
      console.error('socket ' + SOCKET_PATH + ' exists and is in use');
      process.exit(1);
    }
  }

  function forkWorker(listening) {
    // Allow spawning one additional worker during HUP.
    if (_.keys(cluster.workers).length > WORKER_COUNT) {
      return false;
    }

    const worker = cluster.fork();

    if (listening) {
      worker.once('listening', listening);
    }

    worker.on('exit', function (code, signal) {
      if (signal) {
        console.info(`worker was killed by signal: ${signal}`);
      } else if (code !== 0) {
        console.info(`worker exited with error code: ${code}`);
      }
      if (!worker.exitedAfterDisconnect) {
        forkWorker();
      }
    });

    return true;
  }

  for (let i = 0; i < WORKER_COUNT; i++) {
    forkWorker();
  }

  console.log(`server.js listening on ${SOCKET_PATH} (pid ${process.pid})`);

  function killWorker(worker) {
    if (!worker.isDead()) {
      console.info(
        `worker hasn't died after ${DISCONNECT_TIMEOUT}ms; ` +
        `sending SIGKILL to pid ${worker.process.pid}`,
      );
      worker.process.kill('SIGKILL');
    }
  }

  function disconnectWorker(worker) {
    if (worker.isConnected()) {
      worker.disconnect();
      setTimeout(() => killWorker(worker), DISCONNECT_TIMEOUT);
    }
  }

  const cleanup = Raven.wrap(function (signal) {
    let timeout;

    cluster.disconnect(function () {
      clearTimeout(timeout);
      process.exit();
    });

    timeout = setTimeout(() => {
      for (const id in cluster.workers) {
        killWorker(cluster.workers[id]);
      }
      process.exit();
    }, DISCONNECT_TIMEOUT);
  });

  let hupAction = null;
  const hup = Raven.wrap(function () {
    console.info('master received SIGHUP; restarting workers');

    let oldWorkers;
    let initialTimeout = 0;

    if (hupAction) {
      clearTimeout(hupAction);
      initialTimeout = 2000;
    }

    const killNext = Raven.wrap(function () {
      if (!oldWorkers) {
        oldWorkers = _.values(cluster.workers);
      }
      const oldWorker = oldWorkers.pop();
      if (oldWorker) {
        const doKill = function () {
          disconnectWorker(oldWorker);
          hupAction = setTimeout(killNext, 1000);
        };
        if (!forkWorker(doKill)) {
          doKill();
        }
      } else {
        hupAction = null;
      }
    });

    hupAction = setTimeout(killNext, initialTimeout);
  });

  process.on('SIGINT', cleanup);
  process.on('SIGTERM', cleanup);
  process.on('SIGHUP', hup);
} else {
  createServer(SOCKET_PATH);

  process.on('beforeExit', function () {
    const coverage = global.__coverage__;
    if (coverage) {
      writeCoverage(
        `server-${process.pid}`,
        JSON.stringify(coverage),
      );
    }
  });
}
