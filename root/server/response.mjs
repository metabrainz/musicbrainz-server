/*
 * Copyright (C) 2015-2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import * as ReactDOMServer from 'react-dom/server';
import Sentry from '@sentry/node';

import {
  CatalystContext,
  SanitizedCatalystContext,
} from '../context.mjs';
import getRequestCookie from '../utility/getRequestCookie.mjs';
import sanitizedContext from '../utility/sanitizedContext.mjs';

import components from './components.mjs';
import * as gettext from './gettext.mjs';

export function badRequest(err) {
  return Buffer.from(JSON.stringify({
    body: err.stack,
    content_type: 'text/plain',
    status: 400,
  }));
}

const jsExt = /\.js$/;

export async function getResponse(requestBody, context) {
  let status = null;
  let response;

  const user = context.user;
  if (user) {
    Sentry.setUser({id: user.id, username: user.name});
  }

  /*
   * Set the current translations to be used for this request based on the
   * given 'lang' cookie.
   */
  const bcp47Locale = getRequestCookie(context.req, 'lang') || 'en';
  gettext.setLocale(bcp47Locale.replace('-', '_'));

  const componentPath = String(requestBody.component).replace(jsExt, '');
  const componentModule = components[componentPath];

  if (!componentModule) {
    console.warn(
      'warning: component ' + JSON.stringify(componentPath) +
      ' is missing from root/server/components.mjs or invalid',
    );
  }

  let Page = componentModule ? (await componentModule()).default : undefined;
  if (Page === undefined) {
    try {
      Page = (await components['main/error/404']()).default;
      status = 404;
    } catch (err) {
      Sentry.captureException(err);
      return badRequest(err);
    }
  }

  try {
    let props = requestBody.props;
    if (props == null) {
      props = {};
    }
    props.$c = context;

    response = ReactDOMServer.renderToString(
      React.createElement(
        CatalystContext.Provider,
        {value: context},
        React.createElement(
          SanitizedCatalystContext.Provider,
          {value: sanitizedContext(context)},
          React.createElement(Page, props),
        ),
      ),
    );
  } catch (err) {
    Sentry.captureException(err);
    return badRequest(err);
  }

  return Buffer.from(JSON.stringify({
    body: response,
    content_type: 'text/html',
    status,
  }));
}
