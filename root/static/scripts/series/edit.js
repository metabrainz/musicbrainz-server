import $ from 'jquery';
import ko from 'knockout';

import '../common/entity.js';
import '../external-links-editor/components/StandaloneExternalLinksEditor.js';
import './components/SeriesRelationshipEditor.js';

import MB from '../common/MB.js';
import {getCatalystContext} from '../common/utility/catalyst.js';
import initializeDuplicateChecker from '../edit/check-duplicates.js';
import {installFormUnloadWarning} from '../edit/components/forms.js';
import initializeBubble, {
  BubbleDoc,
  initializeExternalLinksBubble,
} from '../edit/MB/Control/Bubble.js';
import typeBubble from '../edit/typeBubble.js';
import initializeValidation from '../edit/validation.js';
import initializeGuessCase from '../guess-case/MB/Control/GuessCase.js';

$(function () {
  var $orderingType = $('#id-edit-series\\.ordering_type_id');

  const series = MB.getSourceEntityInstance();
  series.orderingTypeID($orderingType.val());

  series.orderingTypeBubble = new BubbleDoc();

  const orderingTypesByID = getCatalystContext().stash.series_ordering_types;
  series.orderingTypeDescription = ko.computed(function () {
    return lp_attributes(
      orderingTypesByID[series.orderingTypeID()].description,
      'series_ordering_type',
    );
  });

  ko.applyBindingsToNode($orderingType[0], {
    value: series.orderingTypeID,
    controlsBubble: series.orderingTypeBubble,
  }, series);

  ko.applyBindings(series, $('#ordering-type-bubble')[0]);

  initializeGuessCase('series', 'id-edit-series');

  $orderingType.on('change', function () {
    series.orderingTypeID(Number(this.value));
  });

  initializeDuplicateChecker('series');

  initializeBubble('#name-bubble', 'input[name=edit-series\\.name]');
  initializeBubble('#comment-bubble', 'input[name=edit-series\\.comment]');
  typeBubble('select[name=edit-series\\.type_id]');
  initializeExternalLinksBubble('#external-link-bubble');

  installFormUnloadWarning();

  initializeValidation();
});
