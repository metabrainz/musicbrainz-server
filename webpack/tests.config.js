/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const path = require('path');
const webpack = require('webpack');

const browserConfig = require('./browserConfig');
const dirs = require('./dirs');
const moduleConfig = require('./moduleConfig');
const definePluginConfig = require('./definePluginConfig');
const providePluginConfig = require('./providePluginConfig');

process.env.MUSICBRAINZ_RUNNING_TESTS = true;
process.env.NODE_ENV = 'test';

const baseTestsConfig = {
  context: dirs.CHECKOUT,
  devtool: 'source-map',
  mode: 'development',
  module: moduleConfig,
  output: {
    filename: '[name].js',
    path: dirs.BUILD,
  },
};

const webTestsConfig = {
  entry: {
    'autocomplete2': path.resolve(dirs.SCRIPTS, 'tests', 'autocomplete2.js'),
    'dialog-test': path.resolve(dirs.SCRIPTS, 'tests', 'dialog.js'),
    'web-tests': path.resolve(dirs.SCRIPTS, 'tests', 'browser-runner.js'),
  },

  name: 'web-test-bundles',

  node: {
    global: true,
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

  ...baseTestsConfig,
};

const nodeTestsConfig = {
  entry: {
    tests: path.resolve(dirs.SCRIPTS, 'tests', 'node-runner.js'),
  },

  name: 'node-test-bundles',

  node: false,

  plugins: [
    new webpack.DefinePlugin(definePluginConfig),
    new webpack.ProvidePlugin(providePluginConfig),
    new webpack.IgnorePlugin({
      resourceRegExp: /\/iconv-loader$/,
      contextRegExp: /\/node_modules\/encoding\//,
    }),
  ],

  target: 'node',

  ...baseTestsConfig,
};

module.exports = [
  webTestsConfig,
  nodeTestsConfig,
];
