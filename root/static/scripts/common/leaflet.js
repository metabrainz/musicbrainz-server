/*
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import L from 'leaflet/dist/leaflet-src.js';

import arenaMarkerIconUrl
  from '../../images/leaflet/arena-marker-icon.png';
import arenaMarkerIcon2xUrl
  from '../../images/leaflet/arena-marker-icon-2x.png';
import clusterMarkerIconUrl
  from '../../images/leaflet/cluster-marker-icon.png';
import endedMarkerIconUrl
  from '../../images/leaflet/ended-marker-icon.png';
import endedMarkerIcon2xUrl
  from '../../images/leaflet/ended-marker-icon-2x.png';
import markerIconUrl
  from '../../images/leaflet/marker-icon.png';
import markerIcon2xUrl
  from '../../images/leaflet/marker-icon-2x.png';
import religiousMarkerIconUrl
  from '../../images/leaflet/religious-marker-icon.png';
import religiousMarkerIcon2xUrl
  from '../../images/leaflet/religious-marker-icon-2x.png';
import stadiumMarkerIconUrl
  from '../../images/leaflet/stadium-marker-icon.png';
import stadiumMarkerIcon2xUrl
  from '../../images/leaflet/stadium-marker-icon-2x.png';
import studioMarkerIconUrl
  from '../../images/leaflet/studio-marker-icon.png';
import studioMarkerIcon2xUrl
  from '../../images/leaflet/studio-marker-icon-2x.png';
import venueMarkerIconUrl
  from '../../images/leaflet/venue-marker-icon.png';
import venueMarkerIcon2xUrl
  from '../../images/leaflet/venue-marker-icon-2x.png';

import DBDefs from './DBDefs-client.mjs';

const iconsUrls = {
  'arena-marker-icon.png': arenaMarkerIconUrl,
  'arena-marker-icon-2x.png': arenaMarkerIcon2xUrl,
  'cluster-marker-icon.png': clusterMarkerIconUrl,
  'ended-marker-icon.png': endedMarkerIconUrl,
  'ended-marker-icon-2x.png': endedMarkerIcon2xUrl,
  'marker-icon.png': markerIconUrl,
  'marker-icon-2x.png': markerIcon2xUrl,
  'religious-marker-icon.png': religiousMarkerIconUrl,
  'religious-marker-icon-2x.png': religiousMarkerIcon2xUrl,
  'stadium-marker-icon.png': stadiumMarkerIconUrl,
  'stadium-marker-icon-2x.png': stadiumMarkerIcon2xUrl,
  'studio-marker-icon.png': studioMarkerIconUrl,
  'studio-marker-icon-2x.png': studioMarkerIcon2xUrl,
  'venue-marker-icon.png': venueMarkerIconUrl,
  'venue-marker-icon-2x.png': venueMarkerIcon2xUrl,
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

  L.tileLayer('https://api.mapbox.com/styles/v1/' + DBDefs.MAPBOX_MAP_ID + '/tiles/{z}/{x}/{y}?access_token=' + DBDefs.MAPBOX_ACCESS_TOKEN, {
    attribution: '<a href="https://www.mapbox.com/about/maps/" target="_blank">&copy; Mapbox &copy; OpenStreetMap</a> ' +
                 '<a class="mapbox-improve-map" href="https://www.mapbox.com/map-feedback/" target="_blank">Improve this map</a>',
    maxZoom: 18,
    tileSize: 512,
    zoomOffset: -1,
  }).addTo(map);

  return map;
}

export {L};
