/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {createRequire} from 'module';
import path from 'path';

import webpack from 'webpack';

import browserConfig from './browserConfig.mjs';
import dirs from './dirs.mjs';
import moduleConfig from './moduleConfig.mjs';
import providePluginConfig from './providePluginConfig.mjs';

const require = createRequire(import.meta.url);

const webTestsConfig = {
  context: dirs.CHECKOUT,

  devtool: 'source-map',

  entry: {
    'autocomplete2': path.resolve(dirs.SCRIPTS, 'tests', 'autocomplete2.js'),
    'dialog-test': path.resolve(dirs.SCRIPTS, 'tests', 'dialog.js'),
    'web-tests': path.resolve(dirs.SCRIPTS, 'tests', 'browser-runner.js'),
  },

  mode: 'development',

  module: moduleConfig,

  name: 'web-test-bundles',

  node: {
    global: true,
  },

  output: {
    filename: '[name].js',
    path: dirs.BUILD,
  },

  plugins: [
    ...browserConfig.plugins,
    new webpack.ProvidePlugin({
      ...providePluginConfig,
      process: path.resolve(dirs.CHECKOUT, 'node_modules/process'),
    }),
  ],

  resolve: {
    ...browserConfig.resolve,
    fallback: {
      buffer: require.resolve('buffer'),
      fs: false,
      path: require.resolve('path-browserify'),
      stream: require.resolve('stream-browserify'),
    },
  },
};

export default webTestsConfig;
