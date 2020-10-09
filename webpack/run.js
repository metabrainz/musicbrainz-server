#!/usr/bin/env node
/*
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable import/no-commonjs */

const fs = require('fs');
const path = require('path');

const webpack = require('webpack');

const {dirs} = require('./constants');

const validConfigNames = ['client', 'server', 'tests'];

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

const configObjects =
  /* eslint-disable-next-line import/no-dynamic-require */
  configNames.flatMap(x => require('./' + x + '.config'));

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
      path.resolve(dirs.BUILD, 'rev-manifest.json'),
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
