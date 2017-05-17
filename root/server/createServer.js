// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2017 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const net = require('net');
const Raven = require('raven');

const DBDefs = require('../static/scripts/common/DBDefs');
const {allocBuffer} = require('./buffer');
const {badRequest, getResponse} = require('./response');
const {clearRequireCache} = require('./utils');

const REQUEST_TIMEOUT = 60000;

const connectionListener = Raven.wrap(function (socket) {
  let expectedBytes = 0;
  let recvBuffer = null;
  let recvBytes = 0;
  let context;

  function clearRecv() {
    expectedBytes = 0;
    recvBuffer = null;
    recvBytes = 0;
  }

  const receiveData = Raven.wrap(function (data) {
    if (!recvBuffer) {
      expectedBytes = data.readUInt32LE(0);
      recvBuffer = allocBuffer(expectedBytes);
      data = data.slice(4);
    }

    let overflow = null;
    let remainder = expectedBytes - recvBytes;
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
        Raven.captureException(err);
        writeResponse(socket, badRequest(err));
        return;
      }

      if (requestBody.begin) {
        context = requestBody.context;

        if (DBDefs.DEVELOPMENT_SERVER) {
          clearRequireCache();
        }
      } else if (requestBody.finish) {
        socket.end();
        socket.destroy();
      } else {
        writeResponse(socket, getResponse(requestBody, context));
      }

      if (overflow) {
        receiveData(overflow);
      }
    }
  });

  socket.on('close', clearRecv);
  socket.on('error', clearRecv);
  socket.on('timeout', clearRecv);
  socket.on('data', receiveData);
});

function writeResponse(socket, body) {
  const lengthBuffer = allocBuffer(4);
  lengthBuffer.writeUInt32LE(Buffer.byteLength(body), 0);
  socket.write(lengthBuffer);
  socket.write(body);
}

function listenCallback() {
  console.log(`server.js worker started (pid ${process.pid})`);
}

function createServer(socketPath) {
  return (
    net
      .createServer({allowHalfOpen: true}, connectionListener)
      .listen(socketPath, listenCallback)
  );
}

module.exports = createServer;
