/*
 * @flow strict
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

import {
  MB_SERVER_ROOT,
  STATIC_RESOURCES_LOCATION,
} from './scripts/common/DBDefs.mjs';

let revManifest;

function pathTo(manifest: string) {
  if (revManifest == null) {
    revManifest = JSON.parse(fs.readFileSync(
      path.resolve(MB_SERVER_ROOT, 'root/static/build/rev-manifest.json'),
    ).toString());
  }

  const cleanedManifest = manifest.replace(/^\//, '');

  const publicPath = STATIC_RESOURCES_LOCATION + '/' +
    revManifest[cleanedManifest];

  if (!publicPath) {
    return cleanedManifest;
  }

  return publicPath;
}

const jsExt = /\.js(?:on)?$/;
function manifest(
  manifest: string,
  extraAttrs?: {+'async'?: boolean, +'data-args'?: string} | null = null,
): React.MixedElement {
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

export default manifest;
