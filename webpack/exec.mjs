#!./bin/babel-node
/*
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/*
 * See HACKING.md > Debugging > JavaScript for usage.
 */

import {execFile} from 'node:child_process';
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import webpack from 'webpack';

import MB_SERVER_ROOT from '../root/utility/serverRootDir.mjs';

import moduleConfig from './moduleConfig.mjs';
import serverConfig from './server.config.mjs';

const entryFilePath = path.resolve(process.argv[2]);
const outputFileName = crypto.randomBytes(8).toString('base64') + '.js';
const outputFileDir = path.dirname(entryFilePath);
const outputFilePath = path.resolve(outputFileDir, outputFileName);

const compiler = webpack({
  context: MB_SERVER_ROOT,

  entry: entryFilePath,

  externals: serverConfig.externals,

  mode: 'production',

  module: moduleConfig('node'),

  optimization: {
    minimize: false,
  },

  output: {
    environment: {
      module: false,
    },
    filename: outputFileName,
    libraryTarget: 'commonjs2',
    path: outputFileDir,
  },

  plugins: serverConfig.plugins.filter((plugin) => !(
    plugin instanceof webpack.ProgressPlugin
  )),

  target: 'node',
});

process.on('exit', () => {
  fs.unlink(outputFilePath, console.error);
});

compiler.run((err, stats) => {
  if (err) {
    console.error(err.stack || err);
    if (err.details) {
      console.error(err.details);
    }
    return;
  }

  const compilationErrors = stats.compilation.errors;
  if (compilationErrors.length) {
    for (const error of compilationErrors) {
      console.log(error);
    }
    return;
  }

  execFile('node', [outputFilePath], (error, stdout, stderr) => {
    console.log(stdout);
    if (stderr) {
      console.error(stderr);
    }
    if (error) {
      throw error;
    }
  });
});
