/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable import/no-commonjs */

const path = require('path');

const webpack = require('webpack');

const definePluginConfig = require('./definePluginConfig');

module.exports = {
  node: false,

  plugins: [
    new webpack.DefinePlugin(definePluginConfig),

    new webpack.IgnorePlugin({
      resourceRegExp: /\/server\/gettext$/,
      contextRegExp: /\/root\/static\/scripts\/common\/i18n$/,
    }),

    /*
     * Modules that run in the browser must use DBDefs-client.
     * Any attempt at importing the server DBDefs.js, which can
     * contain sensitive info, is ignored.
     *
     * On the server, files that import DBDefs-client.js will
     * import that file directly. In the browser, we map
     * DBDefs-client to DBDefs-client-browser (below), which
     * fetches the DBDefs values from a global variable at runtime.
     * See root/layout/components/globalsScript.js for more info.
     */
    new webpack.IgnorePlugin({
      resourceRegExp: /\/DBDefs$/,
    }),

    new webpack.NormalModuleReplacementPlugin(
      /\/root\/static\/scripts\/common\/DBDefs-client\.js$/,
      './DBDefs-client-browser.js',
    ),
  ],

  resolve: {
    alias: {
      /*
       * Needed to convince jQuery plugins not to load their own
       * copy of jQuery.
       */
      jquery$: path.resolve(__dirname, '../node_modules/jquery'),
    },
  },

  target: ['web', 'es5'],
};
