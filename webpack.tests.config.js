/*
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const path = require('path');

const browserConfig = require('./webpack/browserConfig');
const dirs = require('./webpack/dirs');
const moduleConfig = require('./webpack/moduleConfig');

process.env.MUSICBRAINZ_RUNNING_TESTS = true;
process.env.NODE_ENV = 'development';

module.exports = {
  context: dirs.CHECKOUT,

  entry: {
    tests: path.resolve(dirs.SCRIPTS, 'tests', 'browser-runner.js'),
  },

  mode: 'development',

  module: moduleConfig,

  node: browserConfig.node,

  output: {
    filename: '[name].js',
    path: dirs.BUILD,
  },

  plugins: browserConfig.plugins,

  resolve: browserConfig.resolve,
};
