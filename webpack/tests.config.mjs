/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import path from 'path';

import webpack from 'webpack';

import {
  MB_SERVER_ROOT,
} from '../root/static/scripts/common/DBDefs.mjs';

import browserConfig from './browserConfig.mjs';
import {
  BUILD_DIR,
  SCRIPTS_DIR,
} from './constants.mjs';
import moduleConfig from './moduleConfig.mjs';
import providePluginConfig from './providePluginConfig.mjs';

const webTestsConfig = {
  context: MB_SERVER_ROOT,

  devtool: 'source-map',

  entry: {
    'autocomplete2': path.resolve(SCRIPTS_DIR, 'tests', 'autocomplete2.js'),
    'dialog-test': path.resolve(SCRIPTS_DIR, 'tests', 'dialog.js'),
    'web-tests': path.resolve(SCRIPTS_DIR, 'tests', 'browser-runner.js'),
  },

  mode: 'development',

  module: moduleConfig,

  name: 'web-test-bundles',

  node: {
    global: true,
  },

  output: {
    filename: '[name].js',
    path: BUILD_DIR,
  },

  plugins: [
    ...browserConfig.plugins,
    new webpack.ProvidePlugin({
      ...providePluginConfig,
      process: path.resolve(MB_SERVER_ROOT, 'node_modules/process'),
    }),
  ],

  resolve: {
    ...browserConfig.resolve,
    fallback: {
      buffer: path.resolve(MB_SERVER_ROOT, 'node_modules/buffer'),
      fs: false,
      path: path.resolve(MB_SERVER_ROOT, 'node_modules/path-browserify'),
      stream: path.resolve(MB_SERVER_ROOT, 'node_modules/stream-browserify'),
    },
  },
};

export default webTestsConfig;
