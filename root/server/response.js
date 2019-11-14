// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015-2017 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

/* eslint-disable import/no-commonjs */

const _ = require('lodash');
const path = require('path');
const Raven = require('raven');

const DBDefs = require('../static/scripts/common/DBDefs');
const getRequestCookie = require('../utility/getRequestCookie');
const {bufferFrom} = require('./buffer');

function badRequest(err) {
  return bufferFrom(JSON.stringify({
    body: err.stack,
    content_type: 'text/plain',
    status: 400,
  }));
}

function getExport(object) {
  return object.default || object;
}

const jsExt = /\.js$/;

function getResponse(requestBody, context) {
  let status = null;
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

  let components;
  try {
    /*
     * N.B. This *must* be required in the same process
     * that serves the request.
     * Do not move to the top of the file.
     */
    components = require('../static/build/server-components');
  } catch (err) {
    Raven.captureException(err);
    return badRequest(err);
  }

  /*
   * Set the current translations to be used for this request based on the
   * given 'lang' cookie.
   * N.B. This *must* be required in the same process that serves the request.
   * Do not move to the top of the file.
   */
  const gettext = require('./gettext');
  const bcp47Locale = getRequestCookie(context.req, 'lang') || 'en';
  gettext.setLocale(bcp47Locale.replace('-', '_'));

  const componentPath = String(requestBody.component).replace(jsExt, '');
  const componentModule = components[componentPath];

  if (!componentModule) {
    console.warn(
      'warning: component ' + JSON.stringify(componentPath) +
      ' is missing from root/server/components.js or invalid',
    );
  }

  let Page = componentModule ? getExport(componentModule) : undefined;
  if (Page === undefined) {
    try {
      Page = getExport(components['main/404']);
      status = 404;
    } catch (err) {
      Raven.captureException(err);
      return badRequest(err);
    }
  }

  try {
    /*
     * N.B. These *must* be required in the same process that serves
     * the request, in order for the in-memory React and
     * CatalystContext instances to be shared with
     * ../static/build/server-components, required above.
     * Do not move to the top of the file.
     */
    const React = require('react');
    const ReactDOMServer = require('react-dom/server');
    const {CatalystContext} = require('../context');

    response = ReactDOMServer.renderToString(
      React.createElement(
        CatalystContext.Provider,
        {value: context},
        React.createElement(Page, requestBody.props),
      ),
    );
  } catch (err) {
    Raven.captureException(err);
    return badRequest(err);
  }

  return bufferFrom(JSON.stringify({
    body: response,
    content_type: 'text/html',
    status,
  }));
}

exports.badRequest = badRequest;
exports.getResponse = getResponse;
