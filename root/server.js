// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

'use strict';

require('babel-core/register');

let argv = require('yargs')
  .demand('port')
  .describe('port', 'port to listen on')
  .describe('development', 'disables module cache if set to 1')
  .argv;

let _ = require('lodash');
let concat = require('concat-stream');
let fs = require('fs');
let http = require('http');
let path = require('path');
let React = require('react');
let ReactDOMServer = require('react-dom/server');
let sliced = require('sliced');
let URL = require('url');
let gettext = require('./server/gettext');
let getCookie = require('./static/scripts/common/utility/getCookie');
let i18n = require('./static/scripts/common/i18n');

const DOCTYPE = '<!DOCTYPE html>';
const URI_FOR_DELIMITER = "\x1F__URI_FOR__\x1F";
const URI_FOR_ACTION_DELIMITER = "\x1F__URI_FOR_ACTION__\x1F";

function pathFromRoot(fpath) {
  return path.resolve(__dirname, '../', fpath);
}

function badRequest(err) {
  return {status: 400, body: err.stack, contentType: 'text/plain'};
}

function uriFor() {
  return URI_FOR_DELIMITER + JSON.stringify(sliced(arguments)) + URI_FOR_DELIMITER;
}

function uriForAction() {
  return URI_FOR_ACTION_DELIMITER + JSON.stringify(sliced(arguments)) + URI_FOR_ACTION_DELIMITER;
}

// Common macros
_.assign(global, {
  doc_link: function (to) {
    return uriFor('/doc', to);
  }
});

function clearRequireCache() {
  Object.keys(require.cache).forEach(key => delete require.cache[key]);
}

function getResponse(req, requestBodyBuf) {
  let url = URL.parse(req.url, true /* parseQueryString */);
  let status = 200;
  let requestBody;
  let Page;
  let responseBuf;

  // N.B. Exceptions will take down the entire process.
  try {
    requestBody = JSON.parse(requestBodyBuf);
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

  // We use a separate gettext handle for each language. Set the current handle
  // to be used for this request based on the given 'lang' cookie.
  i18n.setGettextHandle(gettext.getHandle(getCookie('lang', req.headers.cookie)));

  global.$c = _.assign(context, {
    req: req,
    relative_uri: url.path,
    uri_for: uriFor,
    uri_for_action: uriForAction
  });

  if (String(argv.development) === '1') {
    clearRequireCache();
  }

  try {
    Page = require(pathFromRoot(url.path.replace(/^\//, ''))).default;
  } catch (err) {
    if (err.code === 'MODULE_NOT_FOUND') {
      try {
        Page = require(pathFromRoot('root/main/404')).default;
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
      DOCTYPE +
      ReactDOMServer.renderToStaticMarkup(React.createElement(Page, requestBody.props))
    );
  } catch (err) {
    return badRequest(err);
  }

  return {status: status, body: responseBuf, contentType: 'text/html'};
}

http.createServer(function (req, res) {
  let contentType = 'text/html';

  req.pipe(concat({encoding: 'buffer'}, function (propsBuf) {
    if (!propsBuf.length) {
      propsBuf = new Buffer('{}');
    }

    let resInfo = getResponse(req, propsBuf);
    res.statusCode = resInfo.status;
    res.setHeader('Content-Type', resInfo.contentType);
    res.setHeader('Content-Length', resInfo.body.length);
    res.end(resInfo.body, 'utf8');
  }));
})
.listen(argv.port, '127.0.0.1', function (err) {
  if (err) {
    throw err;
  }

  function cleanup() {
    process.exit();
  }

  function reload() {
    clearRequireCache();
    gettext.clearHandles();
  }

  process.on('SIGINT', cleanup);
  process.on('SIGTERM', cleanup);
  process.on('SIGHUP', reload);

  console.log('server.js listening on 127.0.0.1:' + argv.port + ' (pid ' + process.pid + ')');
});
