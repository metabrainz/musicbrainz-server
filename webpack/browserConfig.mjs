/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import path from 'path';

import webpack from 'webpack';

import MB_SERVER_ROOT from '../root/utility/serverRootDir.mjs';

import {SCRIPTS_DIR} from './constants.mjs';
import definePluginConfig from './definePluginConfig.mjs';

export default {
  node: false,

  plugins: [
    new webpack.DefinePlugin(definePluginConfig),

    /*
     * Modules that run in the browser must use DBDefs-client.
     * Any attempt at importing the server DBDefs.mjs, which can
     * contain sensitive info, is ignored.
     *
     * On the server, files that import DBDefs-client.mjs will
     * import that file directly. In the browser, we map
     * DBDefs-client to DBDefs-client-browser (below), which
     * fetches the DBDefs values from a global variable at runtime.
     * See root/layout/components/globalsScript.mjs for more info.
     */
    new webpack.IgnorePlugin({
      resourceRegExp: /\/DBDefs$/,
    }),

    new webpack.NormalModuleReplacementPlugin(
      /\/root\/static\/scripts\/common\/DBDefs-client\.mjs$/,
      './DBDefs-client-browser.mjs',
    ),

    new webpack.NormalModuleReplacementPlugin(
      /\/root\/server\/gettext\.mjs$/,
      path.resolve(SCRIPTS_DIR, 'empty.js'),
    ),
  ],

  resolve: {
    alias: {
      /*
       * Needed to convince jQuery plugins not to load their own
       * copy of jQuery.
       */
      jquery$: path.resolve(MB_SERVER_ROOT, 'node_modules/jquery'),
    },
  },

  target: ['web', 'es5'],
};
