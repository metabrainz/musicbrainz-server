// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

'use strict';

require('babel-core/register');

const fs = require('fs');
const _ = require('lodash');
const reload = require('require-reload')(require);
const net = require('net');
const path = require('path');
const Raven = require('raven');
const React = require('react');
const ReactDOMServer = require('react-dom/server');
const sliced = require('sliced');

const gettext = require('./server/gettext');
// Reloaded on HUP.
let DBDefs = reload('./static/scripts/common/DBDefs');
const i18n = require('./static/scripts/common/i18n');
const getCookie = require('./static/scripts/common/utility/getCookie');

const yargs = require('yargs')
  .option('socket', {
    alias: 's',
    default: DBDefs.RENDERER_SOCKET,
    describe: 'UNIX socket path',
  });

Raven.config(DBDefs.SENTRY_DSN).install();

const REQUEST_TIMEOUT = 60000;
const SOCKET_PATH = yargs.argv.socket;

function pathFromRoot(fpath) {
  return path.resolve(__dirname, '../', fpath);
}

function badRequest(err) {
  return Buffer.from(JSON.stringify({
    body: err.stack,
    content_type: 'text/plain',
    status: 400,
  }));
}

// Common macros
_.assign(global, {
  bugtracker_url: function (description) {
    return 'http://tickets.musicbrainz.org/secure/CreateIssueDetails!init.jspa?' +
           'pid=10000&issuetype=1' +
           (!description ? '' : '&description=' + encodeURIComponent(description));
  }
});

function clearRequireCache() {
  Object.keys(require.cache).forEach(key => delete require.cache[key]);
}

function getResponse(requestBody, context) {
  let status = 200;
  let Page;
  let response;

  Raven.setContext({
    environment: DBDefs.GIT_BRANCH,
    tags: {
      git_commit: DBDefs.GIT_SHA,
    },
  });

  if (context.user) {
    Raven.mergeContext({user: _.pick(context.user, ['id', 'name'])});
  }

  global.$c = context;

  // We use a separate gettext handle for each language. Set the current handle
  // to be used for this request based on the given 'lang' cookie.
  i18n.setGettextHandle(gettext.getHandle(getCookie('lang')));

  try {
    Page = require(pathFromRoot(requestBody.component));
  } catch (err) {
    if (err.code === 'MODULE_NOT_FOUND') {
      try {
        Page = require(pathFromRoot('root/main/404'));
        status = 404;
      } catch (err) {
        Raven.captureException(err);
        return badRequest(err);
      }
    } else {
      Raven.captureException(err);
      return badRequest(err);
    }
  }

  try {
    response = ReactDOMServer.renderToStaticMarkup(
      React.createElement(Page, requestBody.props)
    );
  } catch (err) {
    Raven.captureException(err);
    return badRequest(err);
  }

  return Buffer.from(JSON.stringify({
    body: response,
    content_type: 'text/html',
    status,
  }));
}

const socketServer = net.createServer(
    {allowHalfOpen: true},
    Raven.wrap(function (socket) {
      let expectedBytes = 0;
      let recvBuffer = null;
      let recvBytes = 0;
      let context;

      function clearRecv() {
        expectedBytes = 0;
        recvBuffer = null;
        recvBytes = 0;
      }

      function writeResponse(body) {
        const lengthBuffer = Buffer.allocUnsafe(4);
        lengthBuffer.writeUInt32LE(Buffer.byteLength(body), 0);
        socket.write(lengthBuffer);
        socket.write(body);
      }

      function receiveData(data) {
        if (!recvBuffer) {
          expectedBytes = data.readUInt32LE(0);
          recvBuffer = Buffer.allocUnsafe(expectedBytes);
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
            writeResponse(badRequest(err));
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
            writeResponse(getResponse(requestBody, context));
          }

          if (overflow) {
            receiveData(overflow);
          }
        }
      }

      socket.on('close', clearRecv);
      socket.on('error', clearRecv);
      socket.on('timeout', clearRecv);
      socket.on('data', receiveData);
  }))
  .listen(SOCKET_PATH, function () {
    console.log(
      'server.js listening on ' + SOCKET_PATH +
      ' (pid ' + process.pid + ')'
    );
  });

const cleanup = Raven.wrap(function () {
  socketServer.close(function () {
    fs.unlinkSync(SOCKET_PATH);
    process.exit();
  });
});

const hup = Raven.wrap(function () {
  clearRequireCache();
  gettext.clearHandles();
  DBDefs = reload('./static/scripts/common/DBDefs');
});

process.on('SIGINT', cleanup);
process.on('SIGTERM', cleanup);
process.on('SIGHUP', hup);
