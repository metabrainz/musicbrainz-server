// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2016 Jérôme Roy
// Copyright (C) 2017 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

require('leaflet.markercluster/dist/leaflet.markercluster-src');
const _ = require('lodash');
const ReactDOMServer = require('react-dom/server');

const manifest = require('../../manifest');
const EntityLink = require('../common/components/EntityLink');
const {l, ln} = require('../common/i18n');
const {createMap, L} = require('../common/leaflet');
const {places} = require('../common/utility/getScriptArgs')();

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
    '1': 'studio-marker',
    '2': 'venue-marker',
    '3': 'marker',
    '4': 'stadium-marker',
    '5': 'arena-marker',
    '6': 'religious-marker',
  };
  const icons = _.mapValues(iconNames, function (name) {
    return new LeafIcon({
      iconUrl: manifest.pathTo('/images/leaflet/' + name + '-icon.png'),
    });
  });

  const markers = L.markerClusterGroup({
    maxClusterRadius: 50,
    spiderfyOnMaxZoom: true,
    showCoverageOnHover: false,
    zoomToBoundsOnClick: false,
    iconCreateFunction: function (cluster) {
      const iconURL = manifest.pathTo('/images/leaflet/cluster-marker-icon.png');

      return L.divIcon({
        html: '<img src="' + _.escape(iconURL) + '" />'
            + '<div class="cluster-div-text">'
            + '<b>' + cluster.getChildCount() + '</b></div>',
        className: 'cluster-div-icon',
        iconSize: L.point(25, 41),
      });
    },
  });

  markers.on('clustermouseover', function (event) {
    const markers = event.layer.getAllChildMarkers();

    let popupText = markers
      .slice(0, CLUSTER_POPUP_LIMIT)
      .map(marker => marker._popup._content)
      .join('<br />');

    if (markers.length > CLUSTER_POPUP_LIMIT) {
      popupText += '<br /> ';
      popupText += _.escape(ln(
        '… and {place_count} other',
        '… and {place_count} others',
        CLUSTER_POPUP_LIMIT,
        {place_count: markers.length - CLUSTER_POPUP_LIMIT}
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
      l('{place_type}: {place_link}', {
        place_type: placeType,
        place_link: placeLink(place),
      })
    );
    bounds.push(coordinates);
    markers.addLayer(marker);
  });

  map.addLayer(markers);
  map.fitBounds(bounds);
}
