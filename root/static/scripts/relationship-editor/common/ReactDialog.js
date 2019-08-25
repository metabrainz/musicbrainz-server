import React, {useEffect, useState} from 'react';
import _ from 'lodash';

import MB from '../../common/MB';
import {ENTITY_NAMES, PART_OF_SERIES_LINK_TYPES} from '../../common/constants';


const PART_OF_SERIES_LINK_TYPE_GIDS = _.values(PART_OF_SERIES_LINK_TYPES);
const RE = MB.relationshipEditor = MB.relationshipEditor || {};

const UI = RE.UI = RE.UI || {};
const fields = RE.fields = RE.fields || {};
const incorrectEntityForSeries = {
  recording:      l('The series you’ve selected is for recordings.'),
  release:        l('The series you’ve selected is for releases.'),
  release_group:  l('The series you’ve selected is for release groups.'),
  work:           l('The series you’ve selected is for works.'),
};

relationshipEditorAutoComplete = function () {
  let dialog;

  function changeTarget(data) {
    if (!data || !data.gid) {
      return;
    }
    const relationship = dialog.relationship();
    const entities = relationship.entities().slice(0);

    entities[dialog.backward() ? 0 : 1] = MB.entity(data);
    relationship.entities(entities);
  }

  return {
    init: function (
      element,
      valueAccessor,
      allBindings,
      viewModel,
      bindingContext,
    ) {
      dialog = valueAccessor();

      dialog.autocomplete = $(element).entitylookup({
        entity: dialog.targetType(),
        resultHook: function (items) {
          if (dialog.autocomplete.entity === 'series' &&
                    dialog.relationship().getLinkType().orderable_direction !== 0) {
            return _.filter(items, function (item) {
              return item.type.item_entity_type === dialog.source.entityType;
            });
          }
          return items;
        },
        setEntity: function (type) {
          if (dialog.disableTypeSelection) {
            return false;
          }

          const possible = dialog.targetTypeOptions();

          if (!_.find(possible, {value: type})) {
            return false;
          }

          dialog.targetType(type);
          return true;
        },
      }).data('mb-entitylookup');
      dialog.autocomplete.currentSelection.subscribe(changeTarget);

      const target = dialog.relationship().target(dialog.source);

      if (dialog instanceof UI.EditDialog) {
        dialog.autocomplete.currentSelection(target);
      } else {
        // Fills in the recording name in the add-related-work dialog.
        dialog.autocomplete.currentSelection({name: target.name});
      }
    },
  };
};

const instrumentSelect = {

  init: function (
    element,
    valueAccessor,
    allBindings,
    viewModel,
    bindingContext,
  ) {
    const relationship = valueAccessor();
    const instruments = ko.observableArray([]);

    function addInstrument(instrument, linkAttribute) {
      const observable = ko.observable(instrument);

      observable.linkAttribute = ko.observable(linkAttribute);
      instruments.push(observable);

      observable.subscribe(function (instrument) {
        relationship.attributes.remove(observable.linkAttribute.peek());
        if (instrument.gid) {
          observable.linkAttribute(relationship.addAttribute(instrument.gid));
        } else {
          observable.linkAttribute(null);
        }
      });
    }

    function focusLastInput() {
      $(element).find('.ui-autocomplete-input:last').focus();
    }

    _.each(relationship.attributes.peek(), function (attribute) {
      if (attribute.type.root_id === 14) {
        addInstrument(MB.entity(attribute.type, 'instrument'), attribute);
      }
    });

    if (!instruments.peek().length) {
      addInstrument(new MB.entity.Instrument({}));
    }

    const vm = {
      addItem: function () {
        addInstrument(new MB.entity.Instrument({}));
        focusLastInput();
      },

      instruments: instruments,

      removeItem: function (item) {
        let index = instruments.indexOf(item);

        instruments.remove(item);
        relationship.attributes.remove(item.linkAttribute.peek());

        index = index === instruments().length ? index - 1 : index;
        const $nextButton = $(element).find('button.remove-item:eq(' + index + ')');

        if ($nextButton.length) {
          $nextButton.focus();
        } else {
          focusLastInput();
        }
      },
    };

    const childBindingContext = bindingContext.createChildContext(vm);
    ko.applyBindingsToDescendants(childBindingContext, element);

    return {controlsDescendantBindings: true};
  },
};

const Dialog = (options) => {
  const viewModel = options.viewModel;
  const source = options.source;
  const target = options.target;

  if (options.relationship) {
    setTarget(options.relationship.target(source));
  } else {
    const [relationship, setRelationship] = setState(options.relationship = viewModel.getRelationship({
      direction: options.direction,
      target: target,
    }, source));

    options.relationship.linkTypeID(
      defaultLinkType({
        children: linkedEntities
          .link_type_tree[options.relationship.entityTypes],
      }),
    );
  }

  const [targetType, setTargetType] = useState(target.entityType);
  targetType.subscribe(targetTypeChanged);
  const [
    changeOtherRelationshipCredits,
    setChangeOtherRelationshipCredits,
  ] = useState({
    source: false,
    target: false,
  });
  const [
    selectedRelationshipCredits,
    setSelectedRelationshipCredits,
  ] = useState({
    source: 'all',
    target: 'all',
  });
  setupUI();

  const open = function () {
    this.viewModel.activeDialog(this);

    const widget = this.widget;

    this.positionBy(positionBy);

    if (!widget.isOpen()) {
      widget.open();
    }

    if (widget.uiDialog.width() > widget.options.maxWidth) {
      widget.uiDialog.width(widget.options.maxWidth);
    }

    // Call this.positionBy twice to prevent jumping in Opera
    this.positionBy(positionBy);

    this.$dialog.find('.link-type').focus();
  };
};
