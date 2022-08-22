/*
 * Copyright (C) 2016 Jérôme Roy
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import 'leaflet.markercluster/dist/leaflet.markercluster-src.js';

import he from 'he';
import * as ReactDOMServer from 'react-dom/server';

import clusterMarkerIconUrl
  from '../../images/leaflet/cluster-marker-icon.png';
import endedMarkerIconUrl
  from '../../images/leaflet/ended-marker-icon.png';
import studioMarkerIconUrl
  from '../../images/leaflet/studio-marker-icon.png';
import venueMarkerIconUrl
  from '../../images/leaflet/venue-marker-icon.png';
import markerIconUrl
  from '../../images/leaflet/marker-icon.png';
import stadiumMarkerIconUrl
  from '../../images/leaflet/stadium-marker-icon.png';
import arenaMarkerIconUrl
  from '../../images/leaflet/arena-marker-icon.png';
import religiousMarkerIconUrl
  from '../../images/leaflet/religious-marker-icon.png';
import EntityLink from '../common/components/EntityLink.js';
import {createMap, L} from '../common/leaflet.js';
import getScriptArgs from '../common/utility/getScriptArgs.js';

const {places} = getScriptArgs();

const CLUSTER_POPUP_LIMIT = 10;

function placeLink(place) {
  return ReactDOMServer.renderToStaticMarkup(<EntityLink entity={place} />);
}

if (places.length) {
  const map = createMap(0, 0, 12);

  const LeafIcon = L.Icon.extend({
    options: {
      iconAnchor: [12, 41],
      iconSize: [25, 41],
      popupAnchor: [1, -34],
    },
  });

  const buildIcon = iconUrl => new LeafIcon({iconUrl});

  const icons = {
    0: buildIcon(endedMarkerIconUrl),
    1: buildIcon(studioMarkerIconUrl),
    2: buildIcon(venueMarkerIconUrl),
    3: buildIcon(markerIconUrl),
    4: buildIcon(stadiumMarkerIconUrl),
    5: buildIcon(arenaMarkerIconUrl),
    6: buildIcon(religiousMarkerIconUrl),
  };

  const markers = L.markerClusterGroup({
    iconCreateFunction: function (cluster) {
      const iconURL = clusterMarkerIconUrl;

      return L.divIcon({
        className: 'cluster-div-icon',
        html: '<img src="' + he.escape(iconURL) + '" />' +
              '<div class="cluster-div-text">' +
              '<strong>' + cluster.getChildCount() + '</strong></div>',
        iconSize: L.point(25, 41),
      });
    },
    maxClusterRadius: 50,
    showCoverageOnHover: false,
    spiderfyOnMaxZoom: true,
    zoomToBoundsOnClick: false,
  });

  markers.on('clustermouseover', function (event) {
    const markers = event.layer.getAllChildMarkers();

    let popupText = markers
      .slice(0, CLUSTER_POPUP_LIMIT)
      .map(marker => marker._popup._content)
      .join('<br />');

    if (markers.length > CLUSTER_POPUP_LIMIT) {
      popupText += '<br /> ';
      popupText += he.escape(texp.ln(
        '… and {place_count} other',
        '… and {place_count} others',
        markers.length - CLUSTER_POPUP_LIMIT,
        {place_count: markers.length - CLUSTER_POPUP_LIMIT},
      ));
    }

    event.layer.bindPopup(popupText).openPopup();
  });

  const bounds = [];
  places.forEach(function (place) {
    const placeType = place.typeName || l('No type');
    const placeName = place.ended
      ? texp.l('{place_name} (closed)', {place_name: place.name})
      : place.name;
    const icon = place.ended
      ? icons['0']
      : icons[place.typeID] ?? icons['3'];
    const coordinates = [
      place.coordinates.latitude,
      place.coordinates.longitude,
    ];
    const marker = L.marker(coordinates, {
      clickable: true,
      draggable: false,
      icon: icon,
      title: placeName,
    }).bindPopup(
      place.ended ? (
        texp.l('{place_type}: {place_link} (closed)', {
          place_link: placeLink(place),
          place_type: placeType,
        })
      ) : (
        texp.l('{place_type}: {place_link}', {
          place_link: placeLink(place),
          place_type: placeType,
        })
      ),
    );
    bounds.push(coordinates);
    markers.addLayer(marker);
  });

  map.addLayer(markers);
  map.fitBounds(bounds);
}
