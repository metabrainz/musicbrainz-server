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
import DBDefs from '../../static/scripts/common/DBDefs-client-values';
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
 *   In production, lib/DBDefs.pm is rendered by consul-template, and so may
 *   be updated if we change a DBDefs value in consul. In order for client
 *   scripts to pick up on these changes without having to recompile/bundle
 *   all of our JavaScript, we define the DBDefs configuration values in a
 *   <script> on the page external from any JS bundle.
 *
 *   (CLIENT_DBDEFS_CODE below is a const for the lifetime of the module;
 *   modules, including this one, are reloaded when root/server.js receives
 *   a SIGHUP from consul-template.)
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
