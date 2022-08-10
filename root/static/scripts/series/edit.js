import $ from 'jquery';
import ko from 'knockout';

import {SERIES_ORDERING_TYPE_AUTOMATIC} from '../common/constants.js';
import MB from '../common/MB.js';
import initializeDuplicateChecker from '../edit/check-duplicates.js';

$(function () {
  var $type = $('#id-edit-series\\.type_id');
  var $orderingType = $('#id-edit-series\\.ordering_type_id');
  const $type_options = $('#id-edit-series\\.type_id > option');

  function updateAllowedTypes(seriesHasItems) {
    $type_options.each(function () {
      const type = MB.seriesTypesByID[this.value];
      const seriesEntityType = series.type()?.item_entity_type;
      const isTypeAllowed =
        type && type.item_entity_type === seriesEntityType;
      if (seriesHasItems && !isTypeAllowed) {
        this.setAttribute('disabled', 'disabled');
      } else {
        this.removeAttribute('disabled');
      }
    });
  }

  var series = MB.entityCache[MB.sourceEntityGID];
  series.typeID($type.val());

  series.orderingTypeID($orderingType.val());

  series.typeBubble = new MB.Control.BubbleDoc();

  series.typeBubble.canBeShown = function () {
    return !!series.type();
  };

  series.orderingTypeBubble = new MB.Control.BubbleDoc();

  ko.computed(function () {
    series.type(MB.seriesTypesByID[series.typeID()]);
  });

  series.orderingTypeDescription = ko.computed(function () {
    return lp_attributes(
      MB.orderingTypesByID[series.orderingTypeID()].description,
      'series_ordering_type',
    );
  });

  var seriesHasItems = ko.computed(function () {
    return series.getSeriesItems(MB.sourceRelationshipEditor).length > 0;
  });

  updateAllowedTypes(seriesHasItems());

  seriesHasItems.subscribe((hasItems) => updateAllowedTypes(hasItems));

  ko.applyBindingsToNode($type[0], {
    value: series.typeID,
    controlsBubble: series.typeBubble,
  }, series);

  ko.applyBindingsToNode($orderingType[0], {
    value: series.orderingTypeID,
    controlsBubble: series.orderingTypeBubble,
  }, series);

  ko.applyBindings(series, $('#series-type-bubble')[0]);
  ko.applyBindings(series, $('#ordering-type-bubble')[0]);

  MB.Control.initializeGuessCase('series', 'id-edit-series');

  $orderingType.on('change', function () {
    series.orderingTypeID(+this.value);

    if (+this.value === SERIES_ORDERING_TYPE_AUTOMATIC) {
      for (const r of series.relationships()) {
        const target = r.target(series);

        if (r.entityIsOrdered && r.entityIsOrdered(target)) {
          r.linkOrder(r.original?.linkOrder || 0);
        }
      }
    }
  });

  initializeDuplicateChecker('series');
});
