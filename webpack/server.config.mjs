/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import path from 'node:path';
import webpack from 'webpack';
import nodeExternals from 'webpack-node-externals';

import MB_SERVER_ROOT from '../root/utility/serverRootDir.mjs';

import cacheConfig from './cacheConfig.mjs';
import {
  BUILD_DIR,
  ROOT_DIR,
  SCRIPTS_DIR,
  WEBPACK_MODE,
} from './constants.mjs';
import definePluginConfig from './definePluginConfig.mjs';
import moduleConfig from './moduleConfig.mjs';
import providePluginConfig from './providePluginConfig.mjs';

export default {
  cache: String(process.env.NO_CACHE) === '1' ? false : cacheConfig,

  context: MB_SERVER_ROOT,

  devtool: false,

  entry: {
    server: {
      chunkLoading: false,
      import: path.resolve(ROOT_DIR, 'server.mjs'),
      /*
       * This prevents code-splitting of async imports into separate chunks.
       * We can't allow that for the server, because Webpack will duplicate
       * certain modules that must be shared into each chunk (context,
       * gettext, DBDefs, linkedEntities, ...).
       */
    },
  },

  externals: [
    nodeExternals({
      /*
       * jquery is resolved to root/static/scripts/empty.js on the server.
       * See NormalModuleReplacementPlugin below.
       *
       * mutate-cow is allowed because it's published as an ES module, which
       * must be converted to CommonJS. Same for po2json.
       *
       * weight-balanced-tree is allowed because it needs to be transpiled to
       * remove Flow and ESM syntax; this is also fine because it's free of
       * side-effects.
       */
      allowlist: [/(jquery|mutate-cow|po2json|weight-balanced-tree)/],
      modulesFromFile: true,
    }),
  ],

  mode: WEBPACK_MODE,

  module: moduleConfig('node'),

  name: 'server-bundle',

  node: false,

  output: {
    environment: {
      module: false,
    },
    filename: '[name].js',
    libraryTarget: 'commonjs2',
    path: BUILD_DIR,
  },

  plugins: [
    new webpack.NormalModuleReplacementPlugin(
      /jquery/,
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

  target: 'node20',
};
