// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const fs = require('fs');
const path = require('path');
const React = require('react');

const DBDefs = require('./scripts/common/DBDefs');

let MANIFEST_MTIME = 0;
let MANIFEST_LAST_CHECKED = 0;
let MANIFEST_SIGNAUTRES = {};
const REV_MANIFEST_PATH = path.join(__dirname, 'build/rev-manifest.json');

function pathTo(manifest) {
  let now = Date.now();

  if ((now - MANIFEST_LAST_CHECKED) > (+process.env.STAT_TTL || 0)) {
    MANIFEST_LAST_CHECKED = now;

    let stats = fs.statSync(REV_MANIFEST_PATH);
    if (stats.mtime > MANIFEST_MTIME) {
      MANIFEST_MTIME = stats.mtime;
      MANIFEST_SIGNAUTRES = JSON.parse(fs.readFileSync(REV_MANIFEST_PATH));
    }
  }

  if (!MANIFEST_SIGNAUTRES[manifest]) {
    throw new Error('no such manifest: ' + manifest);
  }

  return DBDefs.STATIC_RESOURCES_LOCATION + '/' + MANIFEST_SIGNAUTRES[manifest];
}

function js(manifest) {
  return <script src={pathTo('/build/' + manifest + '.js')}></script>;
}

function css(manifest) {
  return <link rel="stylesheet" type="text/css" href={pathTo('/build/' + manifest + '.css')} />;
}

exports.js = js;
exports.css = css;
