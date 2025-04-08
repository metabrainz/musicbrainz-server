/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import ko from 'knockout';
import L from 'leaflet/dist/leaflet-src.js';

import isBlank from '../common/utility/isBlank.js';
import initializeDuplicateChecker from '../edit/check-duplicates.js';
import {installFormUnloadWarning} from '../edit/components/forms.js';
import initializeArea from '../edit/MB/Control/Area.js';
import initializeBubble from '../edit/MB/Control/Bubble.js';
import typeBubble from '../edit/typeBubble.js';
import initializeValidation, {errorField} from '../edit/validation.js';
import initializeGuessCase from '../guess-case/MB/Control/GuessCase.js';

import {map, marker} from './map.js';

$(function () {
  initializeGuessCase('place', 'id-edit-place');
  initializeArea('span.area.autocomplete', '#area-bubble');
  initializeDuplicateChecker('place');

  initializeBubble('#name-bubble', 'input[name=edit-place\\.name]');
  initializeBubble('#comment-bubble', 'input[name=edit-place\\.comment]');
  initializeBubble('#address-bubble', 'input[name=edit-place\\.address]');
  initializeBubble(
    '#begin-end-date-bubble',
    'input[name^=edit-place\\.period\\.begin_date\\.], ' +
      'input[name^=edit-place\\.period\\.end_date\\.]',
  );

  // Display documentation bubbles for external components.
  const externalLinkBubble = initializeBubble('#external-link-bubble');
  $(document).on(
    'focus',
    '#external-links-editor-container .external-link-item input.value',
    (event) => externalLinkBubble.show(event.target),
  );

  const coordsBubble = initializeBubble(
    '#coordinates-bubble',
    'input[name=edit-place\\.coordinates]',
  );

  /*
   * The map is hidden by default, which means it can't
   * position itself correctly.
   * This tells it to update its position once it's visible.
   */
  let invalidateSizeRan = false;
  function afterCoordsBubbleShow() {
    if (!invalidateSizeRan) {
      map.invalidateSize();
      invalidateSizeRan = true;
    }
  }

  const coordsBubbleShow = coordsBubble.show;

  coordsBubble.show = function (...args) {
    coordsBubbleShow.apply(this, args);
    afterCoordsBubbleShow();
  };

  map.on('click', function (e) {
    if (map.getZoom() > 11) {
      marker.setLatLng(e.latlng);
      updateCoordinates(e.latlng);
    } else {
      /*
       * If the map is zoomed too far out,
       * marker placement would be wildly inaccurate,
       * so just zoom in.
       */
      map.setView(e.latlng, map.getZoom() + 2);
    }
  });

  marker.on('dragend', function () {
    const latlng = marker.getLatLng().wrap();
    updateCoordinates(latlng);
  });

  function updateCoordinates(latlng) {
    $('#id-edit-place\\.coordinates').val(latlng.lat + ', ' + latlng.lng);
    $('#id-edit-place\\.coordinates').trigger('input');
  }

  let coordinatesRequest;
  const coordinatesError = errorField(ko.observable(false));

  $('input[name=edit-place\\.coordinates]').on('input', function () {
    if (coordinatesRequest) {
      coordinatesRequest.abort();
      coordinatesRequest = null;
    }
    const coordinates = $('input[name=edit-place\\.coordinates]').val();
    if (isBlank(coordinates)) {
      $('.coordinates-errors').css('display', 'none');
      $('input[name=edit-place\\.coordinates]').removeClass('error');
      $('input[name=edit-place\\.coordinates]')
        .css('background-color', 'transparent');
      coordinatesError(false);
    } else {
      const url = '/ws/js/parse-coordinates?coordinates=' +
                encodeURIComponent(coordinates);
      coordinatesRequest = $.getJSON(url, function (data) {
        $('.coordinates-errors').css('display', 'none');
        $('input[name=edit-place\\.coordinates]').removeClass('error');
        $('input[name=edit-place\\.coordinates]').addClass('success');
        coordinatesError(false);

        const coords = L.latLng(
          data.coordinates.latitude,
          data.coordinates.longitude,
        );
        marker.setLatLng(coords);
        map.setView(coords, 16);
      }).fail(function (jqxhr, textStatus) {
        if (textStatus === 'abort') {
          return;
        }

        $('input[name=edit-place\\.coordinates]').addClass('error');
        $('.coordinates-errors').css('display', 'block');
        coordinatesError(true);
      });
    }
  });

  const typeIdField = 'select[name=edit-place\\.type_id]';
  typeBubble(typeIdField);

  installFormUnloadWarning();

  initializeValidation();
});
