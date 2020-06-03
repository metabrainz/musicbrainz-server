/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const path = require('path');
const webpack = require('webpack');

const browserConfig = require('./webpack/browserConfig');
const dirs = require('./webpack/dirs');
const moduleConfig = require('./webpack/moduleConfig');
const definePluginConfig = require('./webpack/definePluginConfig');
const providePluginConfig = require('./webpack/providePluginConfig');

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
    'web-tests': path.resolve(dirs.SCRIPTS, 'tests', 'browser-runner.js'),
  },

  node: browserConfig.node,

  plugins: [
    ...browserConfig.plugins,
    new webpack.ProvidePlugin(providePluginConfig),
  ],

  resolve: browserConfig.resolve,

  ...baseTestsConfig,
};

const nodeTestsConfig = {
  entry: {
    'tests': path.resolve(dirs.SCRIPTS, 'tests', 'node-runner.js'),
    'react-macros-tests': path.resolve(dirs.SCRIPTS, 'tests', 'react-macros.js'),
  },

  node: {
    __dirname: false,
    __filename: false,
  },

  plugins: [
    new webpack.DefinePlugin(definePluginConfig),
    new webpack.ProvidePlugin(providePluginConfig),
  ],

  target: 'node',

  ...baseTestsConfig,
};

if (String(process.env.WATCH_MODE) === '1') {
  Object.assign(webTestsConfig, require('./webpack/watchConfig'));
  Object.assign(nodeTestsConfig, require('./webpack/watchConfig'));
}

module.exports = [
  webTestsConfig,
  nodeTestsConfig,
];
