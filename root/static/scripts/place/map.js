/*
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {createMap, L} from '../common/leaflet.js';
import getScriptArgs from '../common/utility/getScriptArgs.js';

const {place, title} = getScriptArgs();

let latitude = 0;
let longitude = 0;
let zoom = 2;

if (place && place.coordinates) {
  ({latitude, longitude} = place.coordinates);
  zoom = 16;
}

export const map = createMap(latitude, longitude, zoom);
export const marker = L.marker(
  [latitude, longitude],
  {draggable: false, title: title || (place ? place.name : '')},
);
marker.addTo(map);
