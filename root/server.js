// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

'use strict';

require('babel-core/register');

const fs = require('fs');
const http = require('http');
const _ = require('lodash');
const redis = require('redis');
const reload = require('require-reload')(require);
const path = require('path');
const React = require('react');
const ReactDOMServer = require('react-dom/server');
const sliced = require('sliced');
const URL = require('url');

const gettext = require('./server/gettext');
// Reloaded on HUP.
let DBDefs = reload('./static/scripts/common/DBDefs');
const i18n = require('./static/scripts/common/i18n');
const getCookie = require('./static/scripts/common/utility/getCookie');

function createRedisClient() {
  const REDIS_ARGS = DBDefs.DATASTORE_REDIS_ARGS;
  return redis.createClient({
    url: 'redis://' + REDIS_ARGS.server,
    prefix: REDIS_ARGS.namespace,
    retry_strategy: function (options) {
      const oneMinute = 60 * 1000; // ms
      if (options.total_retry_time < oneMinute) {
        return 1;
      }
    },
  });
}

// Reloaded on HUP.
let redisClient = createRedisClient();

function pathFromRoot(fpath) {
  return path.resolve(__dirname, '../', fpath);
}

function badRequest(err, status) {
  return {status: status || 400, body: err.stack, contentType: 'text/plain'};
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

function getResponse(req, requestBody) {
  let url = URL.parse(req.url, true /* parseQueryString */);
  let status = 200;
  let Page;
  let responseBuf;

  // N.B. Exceptions will take down the entire process.
  try {
    requestBody = JSON.parse(requestBody);
  } catch (err) {
    return badRequest(err);
  }

  _.defaults(requestBody, {props: {}, context: {}});

  let context = requestBody.context;

  if (_.isEmpty(context)) {
    return badRequest(new Error('context is missing'));
  }

  if (_.isEmpty(context.stash)) {
    return badRequest(new Error('context.stash is missing'));
  }

  if (_.isEmpty(context.stash.server_details)) {
    return badRequest(new Error('context.stash.server_details is missing'));
  }

  // Emulate perl context/request API.
  req.query_params = url.query;

  global.$c = _.assign(context, {
    req: req,
    relative_uri: url.path,
  });

  // We use a separate gettext handle for each language. Set the current handle
  // to be used for this request based on the given 'lang' cookie.
  i18n.setGettextHandle(gettext.getHandle(getCookie('lang')));

  if (DBDefs.DEVELOPMENT_SERVER) {
    clearRequireCache();
  }

  try {
    Page = require(pathFromRoot(url.path.replace(/^\//, '')));
  } catch (err) {
    if (err.code === 'MODULE_NOT_FOUND') {
      try {
        Page = require(pathFromRoot('root/main/404'));
        status = 404;
      } catch (err) {
        return badRequest(err);
      }
    } else {
      return badRequest(err);
    }
  }

  try {
    responseBuf = new Buffer(
      '<!DOCTYPE html>' +
      ReactDOMServer.renderToStaticMarkup(React.createElement(Page, requestBody.props))
    );
  } catch (err) {
    return badRequest(err);
  }

  return {status: status, body: responseBuf, contentType: 'text/html'};
}

http.createServer(function (req, res) {
  let contentType = 'text/html';
  let cacheKey = 'template-body:' + req.url;

  redisClient.get(cacheKey, function (err, reply) {
    let resInfo;
    if (err) {
      resInfo = badRequest(err);
    } else if (reply) {
      resInfo = getResponse(req, reply);
    } else {
      resInfo = badRequest(new Error('got null reply from redis'), 500);
    }
    res.statusCode = resInfo.status;
    res.setHeader('Content-Type', resInfo.contentType);
    res.setHeader('Content-Length', resInfo.body.length);
    // MBS-7061: Prevent network providers/proxies from stripping HTML comments.
    res.setHeader('Cache-Control', 'no-transform');
    res.end(resInfo.body, 'utf8');
  });
})
.listen(DBDefs.RENDERER_PORT, '127.0.0.1', function (err) {
  if (err) {
    throw err;
  }

  function cleanup() {
    redisClient.quit();
    process.exit();
  }

  function reload() {
    clearRequireCache();
    gettext.clearHandles();
    DBDefs = reload('./static/scripts/common/DBDefs');
    redisClient.quit();
    redisClient = createRedisClient();
  }

  process.on('SIGINT', cleanup);
  process.on('SIGTERM', cleanup);
  process.on('SIGHUP', reload);

  console.log('server.js listening on 127.0.0.1:' + DBDefs.RENDERER_PORT + ' (pid ' + process.pid + ')');
});
