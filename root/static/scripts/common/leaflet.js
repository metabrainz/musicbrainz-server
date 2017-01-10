// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2017 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const L = require('leaflet/dist/leaflet-src');

const manifest = require('../../manifest');
const DBDefs = require('./DBDefs');

L.Icon.Default.prototype._getIconUrl = function (name) {
  return manifest.pathTo(
    '/images/leaflet/' +
    L.Icon.prototype._getIconUrl.call(this, name)
  );
};

function createMap(latitude, longitude, zoom) {
  const map = L.map('largemap').setView([latitude, longitude], zoom);

  L.tileLayer('https://{s}.tiles.mapbox.com/v4/' + DBDefs.MAPBOX_MAP_ID + '/{z}/{x}/{y}.png?access_token=' + DBDefs.MAPBOX_ACCESS_TOKEN, {
    attribution: '<a href="https://www.mapbox.com/about/maps/" target="_blank">&copy; Mapbox &copy; OpenStreetMap</a> ' +
                 '<a class="mapbox-improve-map" href="https://www.mapbox.com/map-feedback/" target="_blank">Improve this map</a>',
    maxZoom: 18,
  }).addTo(map);

  return map;
}

exports.createMap = createMap;
exports.L = L;
