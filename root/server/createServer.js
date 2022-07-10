/*
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable import/no-commonjs */

const net = require('net');

const Sentry = require('@sentry/node');

const {
  mergeLinkedEntities,
  setLinkedEntities,
} = require('../static/scripts/common/linkedEntities');
const sanitizedContext = require('../utility/sanitizedContext');

const {badRequest, getResponse} = require('./response');

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
        writeResponse(socket, getResponse(requestBody, context));
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
  console.log(`server.js worker started (pid ${process.pid})`);
}

function createServer(fdOrSocketPath) {
  return (
    net
      .createServer({allowHalfOpen: true}, connectionListener)
      .listen(fdOrSocketPath, listenCallback)
  );
}

module.exports = createServer;
