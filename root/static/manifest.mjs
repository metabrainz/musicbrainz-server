/*
 * @flow
 * This file is part of MusicBrainz, the open internet music database.
 * Copyright (C) 2015 MetaBrainz Foundation
 * Licensed under the GPL version 2, or (at your option) any later version:
 * http://www.gnu.org/licenses/gpl-2.0.txt
 */

/*
 * This module is used to look up assets in webpack's manifest, which maps
 * asset names to their public URLs (which include a hash in the filename
 * in production). This is really only useful for looking up JavaScript
 * bundles; for other types of assets, we use webpack's asset modules. This
 * module shouldn't be used in any client scripts, as it makes no sense
 * there. The actual manifest file (./build/rev-manifest) doesn't exist
 * until after the client scripts are bundled.
 */

import fs from 'fs';
import path from 'path';

import * as React from 'react';

import {
  MB_SERVER_ROOT,
  STATIC_RESOURCES_LOCATION,
} from './scripts/common/DBDefs.mjs';

let revManifest;

function pathTo(manifest) {
  if (revManifest == null) {
    revManifest = JSON.parse(fs.readFileSync(
      path.resolve(MB_SERVER_ROOT, 'root/static/build/rev-manifest.json'),
    ).toString());
  }

  manifest = manifest.replace(/^\//, '');

  const publicPath = STATIC_RESOURCES_LOCATION + '/' +
    revManifest[manifest];

  if (!publicPath) {
    return manifest;
  }

  return publicPath;
}

const jsExt = /\.js(?:on)?$/;
export function js(
  manifest: string,
  extraAttrs?: {+'async'?: 'async', +'data-args'?: mixed} | null = null,
): React.Element<'script'> {
  if (jsExt.test(manifest)) {
    throw new Error(
      'Do not include .js in the manifest path name',
    );
  }
  return (
    <script
      src={pathTo(manifest)}
      {...extraAttrs}
    />
  );
}
