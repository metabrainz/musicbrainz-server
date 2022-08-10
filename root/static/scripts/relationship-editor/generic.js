/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import ko from 'knockout';

import {SERIES_ORDERING_TYPE_AUTOMATIC} from '../common/constants.js';
import MB from '../common/MB.js';
import {sortByString} from '../common/utility/arrays.js';
import formatDate from '../common/utility/formatDate.js';
import {hasSessionStorage} from '../common/utility/storage.js';
import * as validation from '../edit/validation.js';

import {ViewModel} from './common/viewModel.js';

const RE = MB.relationshipEditor = MB.relationshipEditor || {};

var UI = RE.UI = RE.UI || {};

export class GenericEntityViewModel extends ViewModel {
  constructor(options) {
    super(options);

    MB.sourceRelationshipEditor = this;

    var source = this.source;

    this.incompleteRelationships = validation.errorField(
      source.displayableRelationships(this).any(function (r) {
        return !r.linkTypeID() || !r.target(source).gid;
      }),
    );
  }

  openAddDialog(source, event) {
    var targetType = MB.allowedRelations[source.entityType].find(
      typeName => typeName !== 'url',
    );

    new UI.AddDialog({
      source: source,
      target: MB.entity({}, targetType),
      viewModel: this,
    }).open(event.target);
  }

  openEditDialog(relationship, event) {
    if (!relationship.removed()) {
      new UI.EditDialog({
        relationship: relationship,
        source: ko.contextFor(event.target).$parents[1],
        viewModel: this,
      }).open(event.target);
    }
  }

  _sortedRelationships(relationships, source) {
    var result = super._sortedRelationships(relationships, source);

    if (source.entityType === 'series') {
      var sorted = ko.observableArray(result());

      ko.computed(function () {
        var seriesType = source.type();
        const seriesOrderingFunc = seriesType
          ? seriesOrdering[seriesType.item_entity_type]
          : undefined;
        if (seriesOrderingFunc) {
          sorted(seriesOrderingFunc(result(), source));
        } else {
          sorted(result());
        }
      });

      return sorted.sortBy(function (relationship) {
        if (+source.orderingTypeID() === SERIES_ORDERING_TYPE_AUTOMATIC) {
          return relationship.paddedSeriesNumber();
        }
        return '';
      });
    }

    return result;
  }
}

GenericEntityViewModel.prototype.fieldName = 'rel';

var seriesOrdering = {
  event: function (relationships, series) {
    return sortByString(relationships, (r) => {
      const event = r.target(series);
      return (
        (event.begin_date ?? '') + '\0' +
                    (event.end_date ?? '') + '\0' +
                    (event.time ?? '')
      );
    });
  },
  release: function (relationships, series) {
    return sortByString(relationships, (r) => {
      const release = r.target(series);
      const firstDate = release.events?.map(getDate).sort()[0];
      const firstCatNo = release.labels?.map(getCatalogNumber).sort()[0];
      return (firstDate ?? '') + '\0' + (firstCatNo ?? '');
    });
  },
  release_group: function (relationships, series) {
    return sortByString(relationships, (r) => {
      const releaseGroup = r.target(series);
      return releaseGroup.firstReleaseDate ?? '';
    });
  },
};

function getDate(x) {
  return formatDate(x.date);
}

function getCatalogNumber(x) {
  return x.catalogNumber || '';
}

ko.bindingHandlers.relationshipStyling = {

  update: function (element, valueAccessor) {
    var relationship = ko.unwrap(valueAccessor());
    var added = relationship.added();

    $(element)
      .toggleClass('rel-add', added)
      .toggleClass('rel-remove', relationship.removed())
      .toggleClass('rel-edit', !added && relationship.edited());
  },
};


function addHiddenInputs(pushInput, vm, formName) {
  var fieldPrefix = formName + '.' + vm.fieldName;
  var relationships = vm.source.relationshipsInViewModel(vm)();
  var index = 0;

  for (var i = 0, len = relationships.length; i < len; i++) {
    const relationship = relationships[i];
    const editData = relationship.editData();
    const prefix = fieldPrefix + '.' + index;

    if (!editData.linkTypeID) {
      continue;
    }

    if (relationship.id) {
      pushInput(prefix, 'relationship_id', relationship.id);
    }

    if (relationship.removed()) {
      pushInput(prefix, 'removed', 1);
    }

    pushInput(prefix, 'target', relationship.target(vm.source).gid);

    var changeData = MB.edit.relationshipEdit(
      editData,
      relationship.original,
      relationship,
    );
    changeData.attributes?.forEach(function (attribute, i) {
      var attrPrefix = prefix + '.attributes.' + i;

      pushInput(attrPrefix, 'type.gid', attribute.type.gid);

      if (attribute.credited_as) {
        pushInput(attrPrefix, 'credited_as', attribute.credited_as);
      }

      if (attribute.text_value) {
        pushInput(attrPrefix, 'text_value', attribute.text_value);
      }

      if (attribute.removed) {
        pushInput(attrPrefix, 'removed', 1);
      }
    });

    if (typeof changeData.entity0_credit === 'string') {
      pushInput(prefix, 'entity0_credit', changeData.entity0_credit);
    }

    if (typeof changeData.entity1_credit === 'string') {
      pushInput(prefix, 'entity1_credit', changeData.entity1_credit);
    }

    var beginDate = changeData.begin_date;
    var endDate = changeData.end_date;

    if (beginDate) {
      pushInput(prefix, 'period.begin_date.year', beginDate.year);
      pushInput(prefix, 'period.begin_date.month', beginDate.month);
      pushInput(prefix, 'period.begin_date.day', beginDate.day);
    }

    if (endDate) {
      pushInput(prefix, 'period.end_date.year', endDate.year);
      pushInput(prefix, 'period.end_date.month', endDate.month);
      pushInput(prefix, 'period.end_date.day', endDate.day);
    }

    if (changeData.ended !== undefined) {
      pushInput(prefix, 'period.ended', changeData.ended ? 1 : 0);
    }

    if (vm.source !== relationship.entities()[0]) {
      pushInput(prefix, 'backward', 1);
    }

    pushInput(prefix, 'link_type_id', editData.linkTypeID || '');

    if (relationship.getLinkType().orderable_direction !== 0) {
      if (relationship.added() || nonEmpty(changeData.linkOrder)) {
        pushInput(prefix, 'link_order', editData.linkOrder);
      }
    }

    index++;
  }
}

export function prepareSubmission(formName) {
  var submitted = [];
  var vm;
  var source = MB.sourceEntity;
  var hiddenInputs = document.createDocumentFragment();
  var fieldCount = 0;

  function pushInput(prefix, name, value) {
    var input = document.createElement('input');
    input.type = 'hidden';
    input.name = prefix + '.' + name;
    input.value = value;
    hiddenInputs.appendChild(input);
    ++fieldCount;
  }

  $('#page form button[type=submit]').prop('disabled', true);
  $('input[type=hidden]', '#relationship-editor').remove();

  if ((vm = MB.sourceRelationshipEditor)) {
    addHiddenInputs(pushInput, vm, formName);
    submitted = submitted.concat(source.relationshipsInViewModel(vm)());
  }

  if (submitted.length && hasSessionStorage) {
    window.sessionStorage.setItem('submittedRelationships', JSON.stringify(
      submitted.map(function (relationship) {
        var data = relationship.editData();

        data.target = relationship.target(source);
        data.removed = relationship.removed();

        if (data.entities[1].gid === source.gid) {
          data.backward = true;
        }

        return data;
      }),
    ));
  }

  if ((vm = MB.sourceExternalLinksEditor?.current)) {
    vm.getFormData(formName + '.url', fieldCount, pushInput);

    if (hasSessionStorage && vm.state.links.length) {
      window.sessionStorage.setItem(
        'submittedLinks',
        JSON.stringify(vm.state.links),
      );
    }
  }

  $('#relationship-editor').append(hiddenInputs);
}

if (typeof document !== 'undefined') {
  let submissionInProgress = false;
  $(document).on(
    'submit',
    '#page form:not(#relationship-editor-form)',
    function () {
      if (!submissionInProgress) {
        submissionInProgress = true;
        const formName = $('#relationship-editor').data('form-name');
        if (formName) {
          prepareSubmission(formName);
        }
      }
    },
  );
}

RE.prepareSubmission = prepareSubmission;
