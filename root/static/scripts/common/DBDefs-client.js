/*
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/*
 * window[GLOBAL_JS_NAMESPACE].DBDefs contains the values exported by
 * DBDefs-client-values.js.
 * See root/layout/components/globalsScript.js for more info.
 *
 * Flow types for this file are found in DBDefs-client.js.flow.
 */

let defaultExport;
if (typeof window === 'undefined') {
  /*
   * This only works on the server. DBDefs-client-values.js is excluded
   * from client scripts.
   */
  defaultExport = require('./DBDefs-client-values');
} else {
  defaultExport = window[GLOBAL_JS_NAMESPACE].DBDefs;
}

export default defaultExport;
