// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2015 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

/*
 * This module is used to look up assets in webpack's manifest, which maps
 * asset names to their public URLs (which include a hash in the filename
 * in production). This is really only useful for looking up JavaScript
 * bundles; for other types of assets, we use webpack's file-loader. This
 * module shouldn't be used in any client scripts, as it makes no sense
 * there. The actual manifest file (./build/rev-manifest) doesn't exist
 * until after the client scripts are bundled.
 */
const React = require('react');

const revManifest = require('./build/rev-manifest');

function pathTo(manifest) {
  manifest = manifest.replace(/^\//, '');

  const publicPath = revManifest[manifest];

  if (!publicPath) {
    return manifest;
  }

  return publicPath;
}

const jsExt = /\.js(?:on)?$/;
function js(manifest, extraAttrs = {}) {
  if (!jsExt.test(manifest)) {
    manifest += '.js';
  }
  return (
    <script
      src={pathTo(manifest)}
      {...extraAttrs}>
    </script>
  );
}

exports.js = js;
