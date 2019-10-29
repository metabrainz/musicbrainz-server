// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2017 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import L from 'leaflet/dist/leaflet-src';

import * as DBDefs from './DBDefs-client';

const iconsUrls = {
  'arena-marker-icon-2x.png':
    require('../../images/leaflet/arena-marker-icon-2x.png'),
  'arena-marker-icon.png':
    require('../../images/leaflet/arena-marker-icon.png'),
  'cluster-marker-icon.png':
    require('../../images/leaflet/cluster-marker-icon.png'),
  'marker-icon-2x.png': require('../../images/leaflet/marker-icon-2x.png'),
  'marker-icon.png': require('../../images/leaflet/marker-icon.png'),
  'religious-marker-icon-2x.png':
    require('../../images/leaflet/religious-marker-icon-2x.png'),
  'religious-marker-icon.png':
    require('../../images/leaflet/religious-marker-icon.png'),
  'stadium-marker-icon-2x.png':
    require('../../images/leaflet/stadium-marker-icon-2x.png'),
  'stadium-marker-icon.png':
    require('../../images/leaflet/stadium-marker-icon.png'),
  'studio-marker-icon-2x.png':
    require('../../images/leaflet/studio-marker-icon-2x.png'),
  'studio-marker-icon.png':
    require('../../images/leaflet/studio-marker-icon.png'),
  'venue-marker-icon-2x.png':
    require('../../images/leaflet/venue-marker-icon-2x.png'),
  'venue-marker-icon.png':
    require('../../images/leaflet/venue-marker-icon.png'),
};

L.Icon.Default.prototype._getIconUrl = function (name) {
  const url = iconsUrls[name];
  if (!url) {
    return iconsUrls[L.Icon.prototype._getIconUrl.call(this, name)];
  }
  return url;
};

export function createMap(latitude, longitude, zoom) {
  const map = L.map('largemap').setView([latitude, longitude], zoom);

  L.tileLayer('https://{s}.tiles.mapbox.com/v4/' + DBDefs.MAPBOX_MAP_ID + '/{z}/{x}/{y}.png?access_token=' + DBDefs.MAPBOX_ACCESS_TOKEN, {
    attribution: '<a href="https://www.mapbox.com/about/maps/" target="_blank">&copy; Mapbox &copy; OpenStreetMap</a> ' +
                 '<a class="mapbox-improve-map" href="https://www.mapbox.com/map-feedback/" target="_blank">Improve this map</a>',
    maxZoom: 18,
  }).addTo(map);

  return map;
}

export {L};
