// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import fs from 'fs';
import path from 'path';

import isNodeJS from 'detect-node';
import React from 'react';

import {
  STAT_TTL,
  STATIC_RESOURCES_LOCATION,
} from './scripts/common/DBDefs';

function _pathTo(manifest, signatures) {
  manifest = manifest.replace(/^\//, '');

  if (!signatures[manifest]) {
    return STATIC_RESOURCES_LOCATION + '/' + manifest;
  }

  return STATIC_RESOURCES_LOCATION + '/' + signatures[manifest];
}

export let pathTo;

if (isNodeJS) {
  let MANIFEST_MTIME = 0;
  let MANIFEST_LAST_CHECKED = 0;
  let MANIFEST_SIGNAUTRES = {};
  const REV_MANIFEST_PATH = path.join(__dirname, 'build/rev-manifest.json');

  pathTo = function (manifest) {
    let now = Date.now();

    if ((now - MANIFEST_LAST_CHECKED) > (STAT_TTL || 0)) {
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

const jsExt = /\.js(?:on)?$/;
export function js(manifest, extraAttrs={}) {
  if (!jsExt.test(manifest)) {
    manifest += '.js';
  }
  return (
    <script
      src={pathTo('scripts/' + manifest)}
      {...extraAttrs}>
    </script>
  );
}

export function css(manifest) {
  return <link rel="stylesheet" type="text/css" href={pathTo('styles/' + manifest + '.css')} />;
}
