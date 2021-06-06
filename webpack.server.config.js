/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const path = require('path');
const webpack = require('webpack');
const nodeExternals = require('webpack-node-externals');

const {
  dirs,
  WEBPACK_MODE,
} = require('./webpack/constants');
const moduleConfig = require('./webpack/moduleConfig');
const definePluginConfig = require('./webpack/definePluginConfig');
const providePluginConfig = require('./webpack/providePluginConfig');

/*
 * Components must use the same context, gettext, and linkedEntities
 * instances created in the server process, so those must be externals.
 */
const externals = [
  'root/context',
  'root/server/gettext',
  'root/static/scripts/common/DBDefs',
  'root/static/scripts/common/DBDefs-client-values',
  'root/static/scripts/common/linkedEntities',
];

module.exports = {
  context: dirs.CHECKOUT,

  entry: {
    'server-components': path.resolve(dirs.ROOT, 'server/components'),
  },

  externals: [
    nodeExternals({
      /*
       * jquery and @popperjs are resolved to root/static/scripts/empty.js
       * on the server. See NormalModuleReplacementPlugin below.
       */
      whitelist: [/(jquery|@popperjs)/],
      modulesFromFile: true,
    }),

    function (context, request, callback) {
      const resolvedRequest = path.resolve(context, request);
      const requestFromCheckout = path.relative(
        dirs.CHECKOUT,
        resolvedRequest,
      );
      if (externals.includes(requestFromCheckout)) {
        /*
         * Output a path relative to the build dir, since that's where
         * the server-components bundle will be.
         */
        callback(
          null,
          'commonjs ' + path.relative(dirs.BUILD, resolvedRequest),
        );
        return;
      }
      callback();
    },
  ],

  mode: WEBPACK_MODE,

  module: moduleConfig,

  node: {
    __dirname: false,
    __filename: false,
  },

  output: {
    filename: '[name].js',
    libraryTarget: 'commonjs2',
    path: dirs.BUILD,
  },

  plugins: [
    new webpack.NormalModuleReplacementPlugin(
      /(jquery|@popperjs)/,
      path.resolve(dirs.SCRIPTS, 'empty.js'),
    ),
    new webpack.DefinePlugin(definePluginConfig),
    new webpack.ProvidePlugin(providePluginConfig),
  ],

  resolve: {
    alias: {
      DBDefs$: path.resolve(dirs.SCRIPTS, 'common', 'DBDefs.js'),
    },
  },

  target: 'node',
};

if (String(process.env.WATCH_MODE) === '1') {
  Object.assign(module.exports, require('./webpack/watchConfig'));
}
