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

import {CatalystContext} from '../context.mjs';

import {
  MB_SERVER_ROOT,
  STATIC_RESOURCES_LOCATION,
} from './scripts/common/DBDefs.mjs';

let revManifest;
let legacyRevManifest;

function pathTo(manifest: string, legacyBrowser: boolean) {
  let mapping: {+[manifest: string]: string};

  if (legacyBrowser) {
    if (legacyRevManifest == null) {
      try {
        legacyRevManifest = JSON.parse(fs.readFileSync(
          path.resolve(
            MB_SERVER_ROOT,
            'root/static/build/rev-manifest-legacy.json',
          ),
        ).toString());
      } catch (error) {
        console.error(error);
      }
    }
    mapping = legacyRevManifest;
  } else {
    if (revManifest == null) {
      revManifest = JSON.parse(fs.readFileSync(
        path.resolve(MB_SERVER_ROOT, 'root/static/build/rev-manifest.json'),
      ).toString());
    }
    mapping = revManifest;
  }

  if (mapping == null) {
    return '';
  }

  const cleanedManifest = manifest.replace(/^\//, '');

  const publicPath = STATIC_RESOURCES_LOCATION + '/' +
    mapping[cleanedManifest];

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
    <CatalystContext.Consumer>
      {$c => (
        <script
          src={pathTo(manifest, $c.stash.legacy_browser ?? false)}
          {...extraAttrs}
        />
      )}
    </CatalystContext.Consumer>
  );
}

export default manifest;
