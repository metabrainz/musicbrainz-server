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
 * In production, lib/DBDefs.pm is rendered by consul-template, and so
 * may be updated if we change a DBDefs value in consul. In order for
 * client scripts to pick up on these changes without having to
 * recompile/bundle all of our JavaScript, we define the DBDefs
 * configuration values as a <script> on the page external from any JS
 * bundle.
 *
 * (CLIENT_DBDEFS_CODE is a const for the lifetime of the module;
 * modules, including this one, are reloaded when root/server.js
 * receives a SIGHUP from consul-template.)
 *
 * __MB_DBDefs__ (GLOBAL_DBDEFS_NAMESPACE) is used for the global var
 * name to avoid conflicts with other scripts (libraries, plugins,
 * userscripts) that pollute the global namespace.
 *
 * We have another, unrelated global named __MB_Catalyst_Context__
 * which stores a sanitized version of $c for React-hydrated client
 * scripts to use. (See root/utility/hydrate.js.) The <script> exported
 * by this file defines both globals.
 */

const CLIENT_DBDEFS_CODE =
  'Object.defineProperty(window,' +
  JSON.stringify(GLOBAL_DBDEFS_NAMESPACE) +
  ',{value:Object.freeze(' +
  escapeClosingTags(JSON.stringify(DBDefs)) +
  ')})';

export default ((
  <CatalystContext.Consumer>
    {$c => {
      const CLIENT_CATALYST_CONTEXT_CODE =
        'Object.defineProperty(window,' +
        JSON.stringify(GLOBAL_CATALYST_CONTEXT_NAMESPACE) +
        ',{value:Object.freeze(' +
        escapeClosingTags(JSON.stringify(sanitizedContext($c))) +
        ')})';
      return (
        <script
          dangerouslySetInnerHTML={{
            __html: CLIENT_DBDEFS_CODE + ';' +
              CLIENT_CATALYST_CONTEXT_CODE,
          }}
          nonce={$c.stash.globals_script_nonce}
        />
      );
    }}
  </CatalystContext.Consumer>
): React.MixedElement);
