// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const L = require('../lib/leaflet/leaflet-src');
const ko = require('knockout');
const _ = require('lodash');

const isBlank = require('./common/utility/isBlank');
const initializeDuplicateChecker = require('./edit/check-duplicates');
const initializeArea = require('./edit/MB/Control/Area').Area;
const {initializeBubble} = require('./edit/MB/Control/Bubble');
const {errorField} = require('./edit/validation');
const {initialize_guess_case} = require('./guess-case/MB/Control/GuessCase');

initialize_guess_case('place', 'id-edit-place');
initializeArea('span.area.autocomplete');
initializeDuplicateChecker('place');

var bubble = initializeBubble('#coordinates-bubble', 'input[name=edit-place\\.coordinates]');

// The map is hidden by default, which means it can't position itself correctly.
// This tells it to update its position once it's visible.
bubble.after("show", _.once(function () {
    map.invalidateSize();
}));

map.on('click', function (e) {
    if (map.getZoom() > 11) {
        marker.setLatLng(e.latlng);
        update_coordinates(e.latlng);
    } else {
        // If the map is zoomed too far out, marker placement would be wildly inaccurate, so just zoom in.
        map.setView(e.latlng);
        map.zoomIn(2);
    }
});

marker.on('dragend', function (e) {
    var latlng = marker.getLatLng().wrap();
    update_coordinates(latlng)
});

function update_coordinates(latlng) {
    $('#id-edit-place\\.coordinates').val(latlng.lat + ', ' + latlng.lng);
    $('#id-edit-place\\.coordinates').trigger('input');
}

var coordinates_request;
var coordinatesError = errorField(ko.observable(false));

$('input[name=edit-place\\.coordinates]').on('input', function () {
    if (coordinates_request) {
        coordinates_request.abort();
        coordinates_request = null;
    }
    var coordinates = $('input[name=edit-place\\.coordinates]').val();
    if (isBlank(coordinates)) {
        $('.coordinates-errors').css('display', 'none');
        $('input[name=edit-place\\.coordinates]').removeClass('error');
        $('input[name=edit-place\\.coordinates]').css('background-color', 'transparent');
        coordinatesError(false);
    } else {
        var url = '/ws/js/parse-coordinates?coordinates=' + encodeURIComponent(coordinates);
        coordinates_request = $.getJSON(url, function (data) {
            $('.coordinates-errors').css('display', 'none');
            $('input[name=edit-place\\.coordinates]').removeClass('error');
            $('input[name=edit-place\\.coordinates]').addClass('success');
            coordinatesError(false);

            marker.setLatLng(L.latLng(data.coordinates.latitude, data.coordinates.longitude));

            map.panTo(L.latLng(data.coordinates.latitude, data.coordinates.longitude));
            map.setZoom(16);
        }).fail(function (jqxhr, text_status, error_thrown) {
            if (text_status === 'abort') { return; }

            $('input[name=edit-place\\.coordinates]').addClass('error');
            $('.coordinates-errors').css('display', 'block');
            coordinatesError(true);
        });
    };
});
