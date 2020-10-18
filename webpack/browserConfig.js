/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const path = require('path');
const webpack = require('webpack');

const definePluginConfig = require('./definePluginConfig');

module.exports = {
  node: {
    fs: 'empty',
    path: true,
  },

  plugins: [
    new webpack.DefinePlugin(definePluginConfig),

    new webpack.IgnorePlugin({
      resourceRegExp: /\/server\/gettext$/,
      contextRegExp: /\/root\/static\/scripts\/common\/i18n$/,
    }),

    // Modules that run in the browser must use DBDefs-client.
    new webpack.IgnorePlugin({
      resourceRegExp: /\/DBDefs(?:-client-values)?$/,
    }),
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
};
