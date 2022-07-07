/*
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import cluster from 'cluster';
import fs from 'fs';
import {spawnSync} from 'child_process';

import Sentry from '@sentry/node';

import createServer from './server/createServer.mjs';
import * as DBDefs from './static/scripts/common/DBDefs.js';
import nonEmpty from './static/scripts/common/utility/nonEmpty.js';
import writeCoverage from './utility/writeCoverage.js';

function sentryInit(config) {
  Sentry.init({
    dsn: config.SENTRY_DSN_PUBLIC,
    environment: config.GIT_BRANCH,
    release: config.GIT_SHA,
  });
}
sentryInit(DBDefs);

const WORKER_COUNT = parseInt(process.env.RENDERER_WORKERS, 10) || 1;
const DISCONNECT_TIMEOUT = 10000;
const SERVER_STARTER_PORT = process.env.SERVER_STARTER_PORT;

let SERVER_STARTER_FD = null;
let SOCKET_PATH = null;

if (nonEmpty(SERVER_STARTER_PORT)) {
  const fdMatch = SERVER_STARTER_PORT.match(/=([0-9]+)$/);
  const fd = fdMatch ? parseInt(fdMatch[1], 10) : NaN;
  if (Number.isNaN(fd)) {
    throw new Error(
      'Invalid file descriptor in SERVER_STARTER_PORT: ' +
      JSON.stringify(SERVER_STARTER_PORT),
    );
  }
  SERVER_STARTER_FD = fd;
} else {
  SOCKET_PATH = process.env.RENDERER_SOCKET;
  if (!nonEmpty(SOCKET_PATH)) {
    SOCKET_PATH = DBDefs.RENDERER_SOCKET;
  }
}

if (cluster.isMaster) {
  if (SOCKET_PATH != null && fs.existsSync(SOCKET_PATH)) {
    if (spawnSync('lsof', [SOCKET_PATH]).status) {
      fs.unlinkSync(SOCKET_PATH);
    } else {
      console.error('socket ' + SOCKET_PATH + ' exists and is in use');
      process.exit(1);
    }
  }

  function forkWorker(listening) {
    // Allow spawning one additional worker during HUP.
    if (Object.keys(cluster.workers).length > WORKER_COUNT) {
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

  console.log(`server.mjs listening on ${SOCKET_PATH} (pid ${process.pid})`);

  function killWorker(worker) {
    if (!worker.isDead()) {
      console.info(
        `worker hasn't died after ${DISCONNECT_TIMEOUT}ms; ` +
        `sending SIGKILL to pid ${worker.process.pid}`,
      );
      worker.process.kill('SIGKILL');
    }
  }

  function cleanup() {
    const timeout = setTimeout(() => {
      for (const id in cluster.workers) {
        killWorker(cluster.workers[id]);
      }
      process.exit();
    }, DISCONNECT_TIMEOUT);

    cluster.disconnect(function () {
      clearTimeout(timeout);
      process.exit();
    });
  }

  process.on('SIGINT', cleanup);
  process.on('SIGTERM', cleanup);
} else {
  if (SERVER_STARTER_FD == null) {
    createServer(SOCKET_PATH);
  } else {
    createServer({fd: SERVER_STARTER_FD});
  }

  cluster.worker.on('disconnect', function () {
    const coverage = global.__coverage__;
    if (coverage) {
      writeCoverage(
        `server-${process.pid}`,
        JSON.stringify(coverage),
      );
    }
  });
}
