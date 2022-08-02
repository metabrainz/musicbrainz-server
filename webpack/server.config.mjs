/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import path from 'path';

import webpack from 'webpack';
import nodeExternals from 'webpack-node-externals';

import {
  MB_SERVER_ROOT,
} from '../root/static/scripts/common/DBDefs.mjs';

import cacheConfig from './cacheConfig.mjs';
import {
  BUILD_DIR,
  ROOT_DIR,
  SCRIPTS_DIR,
  WEBPACK_MODE,
} from './constants.mjs';
import moduleConfig from './moduleConfig.mjs';
import definePluginConfig from './definePluginConfig.mjs';
import providePluginConfig from './providePluginConfig.mjs';

export default {
  cache: cacheConfig,

  context: MB_SERVER_ROOT,

  devtool: false,

  entry: {
    server: {
      import: path.resolve(ROOT_DIR, 'server.mjs'),
      /*
       * This prevents code-splitting of async imports into separate chunks.
       * We can't allow that for the server, because Webpack will duplicate
       * certain modules that must be shared into each chunk (context,
       * gettext, DBDefs, linkedEntities, ...).
       */
      chunkLoading: false,
    },
  },

  externals: [
    nodeExternals({
      /*
       * jquery and @popperjs are resolved to root/static/scripts/empty.js
       * on the server. See NormalModuleReplacementPlugin below.
       *
       * mutate-cow is allowed because it's published as an ES module, which
       * must be converted to CommonJS.
       */
      allowlist: [/(jquery|@popperjs|mutate-cow)/],
      modulesFromFile: true,
    }),
  ],

  mode: WEBPACK_MODE,

  module: moduleConfig,

  name: 'server-bundle',

  node: false,

  output: {
    filename: '[name].js',
    libraryTarget: 'commonjs2',
    path: BUILD_DIR,
  },

  plugins: [
    new webpack.NormalModuleReplacementPlugin(
      /(jquery|@popperjs)/,
      path.resolve(SCRIPTS_DIR, 'empty.js'),
    ),
    new webpack.DefinePlugin(definePluginConfig),
    new webpack.ProvidePlugin(providePluginConfig),
    ...(
      String(process.env.NO_PROGRESS) === '1'
        ? []
        : [new webpack.ProgressPlugin({activeModules: true})]
    ),
  ],

  target: 'node16.0',
};
