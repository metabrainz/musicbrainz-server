// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const isNodeJS = require('detect-node');
const fs = require('fs');
const path = require('path');
const React = require('react');

const DBDefs = require('./scripts/common/DBDefs');

function _pathTo(manifest, signatures) {
  manifest = manifest.replace(/^\//, '');

  if (!signatures[manifest]) {
    throw new Error('no such manifest: ' + manifest);
  }

  return DBDefs.STATIC_RESOURCES_LOCATION + '/' + signatures[manifest];
}

let pathTo;

if (isNodeJS) {
  let MANIFEST_MTIME = 0;
  let MANIFEST_LAST_CHECKED = 0;
  let MANIFEST_SIGNAUTRES = {};
  const REV_MANIFEST_PATH = path.join(__dirname, 'build/rev-manifest.json');

  pathTo = function (manifest) {
    let now = Date.now();

    if ((now - MANIFEST_LAST_CHECKED) > (DBDefs.STAT_TTL || 0)) {
      MANIFEST_LAST_CHECKED = now;

      let stats = fs.statSync(REV_MANIFEST_PATH);
      if (stats.mtime > MANIFEST_MTIME) {
        MANIFEST_MTIME = stats.mtime;
        MANIFEST_SIGNAUTRES = JSON.parse(fs.readFileSync(REV_MANIFEST_PATH));
      }
    }

    return _pathTo(manifest, MANIFEST_SIGNAUTRES);
  };
} else {
  pathTo = function (manifest) {
    return _pathTo(manifest, require('rev-manifest.json'));
  };
}

function js(manifest, extraAttrs={}) {
  return (
    <script
      src={pathTo('scripts/' + manifest + '.js')}
      {...extraAttrs}>
    </script>
  );
}

function css(manifest) {
  return <link rel="stylesheet" type="text/css" href={pathTo('styles/' + manifest + '.css')} />;
}

exports.js = js;
exports.css = css;
exports.pathTo = pathTo;
