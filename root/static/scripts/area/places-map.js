/*
 * This file is part of MusicBrainz, the open internet music database.
 * Copyright (C) 2016 Jérôme Roy
 * Copyright (C) 2017 MetaBrainz Foundation
 * Licensed under the GPL version 2, or (at your option) any later version:
 * http://www.gnu.org/licenses/gpl-2.0.txt
 */

import 'leaflet.markercluster/dist/leaflet.markercluster-src';

import _ from 'lodash';
import React from 'react';
import ReactDOMServer from 'react-dom/server';

import EntityLink from '../common/components/EntityLink';
import {createMap, L} from '../common/leaflet';
import getScriptArgs from '../common/utility/getScriptArgs';

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

  const iconNames = {
    1: require('../../images/leaflet/studio-marker-icon.png'),
    2: require('../../images/leaflet/venue-marker-icon.png'),
    3: require('../../images/leaflet/marker-icon.png'),
    4: require('../../images/leaflet/stadium-marker-icon.png'),
    5: require('../../images/leaflet/arena-marker-icon.png'),
    6: require('../../images/leaflet/religious-marker-icon.png'),
  };
  const icons = _.mapValues(iconNames, iconUrl => new LeafIcon({iconUrl}));

  const markers = L.markerClusterGroup({
    iconCreateFunction: function (cluster) {
      const iconURL = require('../../images/leaflet/cluster-marker-icon.png');

      return L.divIcon({
        className: 'cluster-div-icon',
        html: '<img src="' + _.escape(iconURL) + '" />' +
              '<div class="cluster-div-text">' +
              '<b>' + cluster.getChildCount() + '</b></div>',
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
      popupText += _.escape(texp.ln(
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
    const coordinates = [
      place.coordinates.latitude,
      place.coordinates.longitude,
    ];
    const marker = L.marker(coordinates, {
      clickable: true,
      draggable: false,
      icon: _.get(icons, place.typeID, icons['3']),
      title: place.name,
    }).bindPopup(
      texp.l('{place_type}: {place_link}', {
        place_link: placeLink(place),
        place_type: placeType,
      }),
    );
    bounds.push(coordinates);
    markers.addLayer(marker);
  });

  map.addLayer(markers);
  map.fitBounds(bounds);
}
