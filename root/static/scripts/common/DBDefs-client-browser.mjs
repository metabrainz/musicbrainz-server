/*
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/*
 * window[GLOBAL_JS_NAMESPACE].DBDefs contains the values exported by
 * DBDefs-client.mjs.
 * See root/layout/components/globalsScript.mjs for more info.
 *
 * This file should not be imported directly. It's substituted for
 * ./DBDefs-client.mjs via the NormalModuleReplacementPlugin in
 * webpack/browserConfig.js.
 */

export default window[GLOBAL_JS_NAMESPACE].DBDefs;
