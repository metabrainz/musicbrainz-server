/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context';
import DBDefs from '../../static/scripts/common/DBDefs-client';
import escapeClosingTags from '../../utility/escapeClosingTags';
import sanitizedContext from '../../utility/sanitizedContext';

/*
 * window.__MB__ (GLOBAL_JS_NAMESPACE) is defined as a non-configurable,
 * non-enumerable global namespace under which we store global data to
 * avoid conflicts with other scripts (libraries, plugins, userscripts)
 * that may pollute the global namespace. Currently, it stores the
 * following keys:
 *
 * "DBDefs"
 *   Configuration values used by client code.
 *
 *   For production, static resources are built into the Docker image.  These
 *   images are built without access to any private DBDefs values, and are
 *   publicly uploaded to Docker Hub; we don't copy in our private DBDefs.pm
 *   files until after the containers are started.  dbdefs_to_js.pl is then
 *   run to generate DBDefs-client.js.
 *
 *   In order for client scripts to pick up on these changes without having
 *   to recompile/bundle all of our JavaScript, we define the DBDefs
 *   configuration values in a <script> on the page external from any JS
 *   bundle.  Webpack is configured to map any imports for DBDefs-client.js
 *   to DBDefs-client-browser.js, which reads from this global script.
 *
 *   CLIENT_DBDEFS_CODE below is a const for the lifetime of the module;
 *   modules, including this one, are reloaded when root/server.mjs receives
 *   a SIGHUP.
 *
 * "$c"
 *   A sanitized version of $c (Catalyst context) from the server, for React-
 *   hydrated client scripts to use. (See root/utility/hydrate.js.)
 */

const renderValue = (value: mixed): string => {
  let result = escapeClosingTags(JSON.stringify(value) ?? '');
  if (typeof value === 'object' && value != null) {
    result = 'Object.freeze(' + result + ')';
  }
  return result;
};

export const renderKeyAndValue = (
  key: string,
  value: mixed,
): string => (
  JSON.stringify(key) + ':' + renderValue(value)
);

const CLIENT_DBDEFS_CODE = renderKeyAndValue('DBDefs', DBDefs);

export default ((
  <CatalystContext.Consumer>
    {$c => {
      const GLOBAL_JS_CODE =
        'Object.defineProperty(window,' +
        JSON.stringify(GLOBAL_JS_NAMESPACE) +
        ',{value:Object.freeze({' +
        CLIENT_DBDEFS_CODE + ',' +
        renderKeyAndValue('$c', sanitizedContext($c)) +
        '})})';
      return (
        <script
          dangerouslySetInnerHTML={{__html: GLOBAL_JS_CODE}}
          nonce={$c.stash.globals_script_nonce}
        />
      );
    }}
  </CatalystContext.Consumer>
): React.MixedElement);
