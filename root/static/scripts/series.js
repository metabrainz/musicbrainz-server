import $ from 'jquery';
import _ from 'lodash';
import ko from 'knockout';

import {SERIES_ORDERING_TYPE_AUTOMATIC} from './common/constants';
import MB from './common/MB';
import initializeDuplicateChecker from './edit/check-duplicates';

$(function () {
  var $type = $('#id-edit-series\\.type_id');
  var $orderingType = $('#id-edit-series\\.ordering_type_id');

  // Type can be disabled, but is a required field, so use a hidden input.
  var $hiddenType = $('<input>')
    .attr({type: 'hidden', name: $type[0].name})
    .val($type.val())
    .insertAfter($type.removeAttr('name'));

  var series = MB.entityCache[MB.sourceEntityGID];
  series.typeID($type.val());

  series.typeID.subscribe(function (typeID) {
    $hiddenType.val(typeID);
  });

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

  ko.applyBindingsToNode($type[0], {
    value: series.typeID,
    controlsBubble: series.typeBubble,
    disable: seriesHasItems,
  }, series);

  ko.applyBindingsToNode($orderingType[0], {
    value: series.orderingTypeID,
    controlsBubble: series.orderingTypeBubble,
  }, series);

  ko.applyBindings(series, $('#series-type-bubble')[0]);
  ko.applyBindings(series, $('#ordering-type-bubble')[0]);

  MB.Control.initialize_guess_case('series', 'id-edit-series');

  $orderingType.on('change', function () {
    series.orderingTypeID(+this.value);

    if (+this.value === SERIES_ORDERING_TYPE_AUTOMATIC) {
      _.each(series.relationships(), function (r) {
        var target = r.target(series);

        if (r.entityIsOrdered && r.entityIsOrdered(target)) {
          r.linkOrder(r.original.linkOrder || 0);
        }
      });
    }
  });

  initializeDuplicateChecker('series');
});
