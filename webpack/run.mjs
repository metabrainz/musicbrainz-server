/*
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import fs from 'fs';
import path from 'path';

import webpack from 'webpack';

import clientConfig from './client.config.mjs';
import {BUILD_DIR} from './constants.mjs';
import serverConfig from './server.config.mjs';
import testsConfig from './tests.config.mjs';

const configMap = new Map([
  ['client', clientConfig],
  ['server', serverConfig],
  ['tests', testsConfig],
]);

const validConfigNames = Array.from(configMap.keys());

const configNames = process.argv
  .slice(2)
  .reduce((accum, x) => {
    if (validConfigNames.includes(x)) {
      accum.push(x);
    } else {
      throw new Error(
        'Invalid config: ' + JSON.stringify(x),
      );
    }
    return accum;
  }, [])
  .sort((a, b) => (
    validConfigNames.indexOf(a) -
    validConfigNames.indexOf(b)
  ));

const configObjects = configNames.map(name => configMap.get(name));

const revManifestJson = {};

function webpackCallback(err, stats) {
  if (err) {
    console.error(err.stack || err);
    if (err.details) {
      console.error(err.details);
    }
    return;
  }

  const statsJson = stats.toJson();

  const clientBundlesStats =
    statsJson.children.find(x => x.name === 'client-bundles');

  if (clientBundlesStats) {
    const clientAssets = clientBundlesStats.assetsByChunkName;
    for (const [key, [value]] of Object.entries(clientAssets)) {
      revManifestJson[key] = value;
    }
    fs.writeFileSync(
      path.resolve(BUILD_DIR, 'rev-manifest.json'),
      JSON.stringify(revManifestJson),
    );
  }

  console.log(stats.toString({
    colors: true,
  }));
}

if (process.env.WATCH_MODE === '1') {
  webpack(configObjects).watch({
    aggregateTimeout: 100,
    ignored: /node_modules/,
  }, webpackCallback);
} else {
  webpack(configObjects, webpackCallback);
}
