import $ from 'jquery';
import ko from 'knockout';

import '../common/entity.js';
import './components/SeriesRelationshipEditor.js';

import MB from '../common/MB.js';
import initializeDuplicateChecker from '../edit/check-duplicates.js';
import {createExternalLinksEditorForHtmlForm} from '../edit/externalLinks.js';
import typeBubble from '../edit/typeBubble.js';

$(function () {
  var $orderingType = $('#id-edit-series\\.ordering_type_id');

  const series = MB.getSourceEntityInstance();
  series.orderingTypeID($orderingType.val());

  series.orderingTypeBubble = new MB.Control.BubbleDoc();

  series.orderingTypeDescription = ko.computed(function () {
    return lp_attributes(
      MB.orderingTypesByID[series.orderingTypeID()].description,
      'series_ordering_type',
    );
  });

  ko.applyBindingsToNode($orderingType[0], {
    value: series.orderingTypeID,
    controlsBubble: series.orderingTypeBubble,
  }, series);

  ko.applyBindings(series, $('#ordering-type-bubble')[0]);

  MB.Control.initializeGuessCase('series', 'id-edit-series');

  $orderingType.on('change', function () {
    series.orderingTypeID(+this.value);
  });

  initializeDuplicateChecker('series');

  createExternalLinksEditorForHtmlForm('edit-series');
});

const typeIdField = 'select[name=edit-series\\.type_id]';
typeBubble(typeIdField);
