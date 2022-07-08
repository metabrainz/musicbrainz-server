/*
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import net from 'net';

import Sentry from '@sentry/node';

import {
  mergeLinkedEntities,
  setLinkedEntities,
} from '../static/scripts/common/linkedEntities.js';
import sanitizedContext from '../utility/sanitizedContext.mjs';

import {badRequest, getResponse} from './response.mjs';

const connectionListener = function (socket) {
  let expectedBytes = 0;
  let recvBuffer = null;
  let recvBytes = 0;
  let context;

  function clearRecv() {
    expectedBytes = 0;
    recvBuffer = null;
    recvBytes = 0;
  }

  const receiveData = function (data) {
    if (!recvBuffer) {
      expectedBytes = data.readUInt32LE(0);
      recvBuffer = Buffer.allocUnsafe(expectedBytes);
      data = data.slice(4);
    }

    let overflow = null;
    const remainder = expectedBytes - recvBytes;
    if (data.length > remainder) {
      overflow = data.slice(remainder);
      data = data.slice(0, remainder);
    }

    data.copy(recvBuffer, recvBytes);
    recvBytes += data.length;

    if (recvBytes === expectedBytes) {
      const _recvBuffer = recvBuffer;

      clearRecv();

      let requestBody;
      try {
        requestBody = JSON.parse(_recvBuffer);
      } catch (err) {
        Sentry.captureException(err);
        writeResponse(socket, badRequest(err));
        return;
      }

      if (requestBody.begin) {
        context = requestBody.context;
        context.toJSON = () => sanitizedContext(context);
        setLinkedEntities(requestBody.linked_entities);
      } else if (requestBody.finish) {
        socket.end();
        socket.destroy();
      } else {
        // Merge new linked entities into current ones.
        mergeLinkedEntities(requestBody.linked_entities);
        getResponse(requestBody, context).then(function (body) {
          writeResponse(socket, body);
        });
      }

      if (overflow) {
        receiveData(overflow);
      }
    }
  };

  socket.on('close', clearRecv);
  socket.on('error', clearRecv);
  socket.on('timeout', clearRecv);
  socket.on('data', receiveData);
};

function writeResponse(socket, body) {
  const lengthBuffer = Buffer.allocUnsafe(4);
  lengthBuffer.writeUInt32LE(Buffer.byteLength(body), 0);
  socket.write(lengthBuffer);
  socket.write(body);
}

function listenCallback() {
  console.log(`server.mjs worker started (pid ${process.pid})`);
}

function createServer(fdOrSocketPath) {
  return (
    net
      .createServer({allowHalfOpen: true}, connectionListener)
      .listen(fdOrSocketPath, listenCallback)
  );
}

export default createServer;
