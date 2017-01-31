// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2017 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const {createMap, L} = require('../common/leaflet');
const {draggable, place, title} = require('../common/utility/getScriptArgs')();

let latitude = 0;
let longitude = 0;
let zoom = 2;

if (place && place.coordinates) {
  ({latitude, longitude} = place.coordinates);
  zoom = 16;
}

const map = createMap(latitude, longitude, zoom);
const marker = L.marker(
  [latitude, longitude],
  {draggable: false, title: title || (place ? place.name : '')},
);
marker.addTo(map);

exports.map = map;
exports.marker = marker;
