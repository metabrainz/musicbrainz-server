/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';

import 'knockout-arraytransforms';

import {compare} from '../../common/i18n';
import linkedEntities from '../../common/linkedEntities';
import MB from '../../common/MB';
import {compactMap, sortByString} from '../../common/utility/arrays';
import {uniqueId} from '../../common/utility/strings';
import deferFocus from '../../edit/utility/deferFocus';

import mergeDates from './mergeDates';

import '../../common/entity';

function isBackward(relationship, source) {
  const entities = relationship.entities();

  if (source === entities[0]) {
    return false;
  }

  if (source === entities[1]) {
    return true;
  }

  throw 'source not in the entities array';
}

const RE = MB.relationshipEditor = MB.relationshipEditor || {};

const coreEntityPrototype = MB.entity.CoreEntity.prototype;

coreEntityPrototype._afterCoreEntityCtor = function () {
  if (this.uniqueID == null) {
    this.uniqueID = uniqueId('entity-');
  }
  this.relationshipElements = {};
};

Object.assign(coreEntityPrototype, {

  parseRelationships: function (relationships) {
    const self = this;

    if (!relationships || !relationships.length) {
      return;
    }

    const newRelationships = compactMap(
      relationships,
      data => MB.getRelationship(data, self),
    );

    const allRelationships = [...new Set([
      ...this.relationships.peek(),
      ...newRelationships,
    ])];

    // Sort allRelationships by their lower-case phrase.
    this.relationships(sortByString(
      allRelationships,
      r => r.lowerCasePhrase(self),
      compare,
    ));

    for (const data of relationships) {
      MB.entity(data.target).parseRelationships(data.target.relationships);
    }
  },

  displayableRelationships: cacheByID(function (vm) {
    return vm._sortedRelationships(this.relationshipsInViewModel(vm), this);
  }),

  relationshipsInViewModel: cacheByID(function (vm) {
    return this.relationships.filter(function (relationship) {
      return vm === relationship.parent;
    });
  }),

  groupedRelationships: cacheByID(function (vm) {
    const self = this;

    function linkPhrase(relationship) {
      return relationship.groupingLinkPhrase(self);
    }

    function openAddDialog(source, event) {
      const relationships = this.values();
      const firstRelationship = relationships[0];

      const dialog = new RE.UI.AddDialog({
        source: self,
        target: MB.entity({}, firstRelationship.target(self).entityType),
        backward: isBackward(firstRelationship, self),
        viewModel: vm,
      });

      const relationship = dialog.relationship();
      relationship.linkTypeID(firstRelationship.linkTypeID());

      const [firstAttributeSet, ...remainingAttributeSets] =
        relationships.map(x => new Set(x.attributes()));

      const commonAttributes = [...firstAttributeSet].filter(x => (
        !isFreeText(x) && remainingAttributeSets.every(y => y.has(x))
      ));

      relationship.setAttributes(commonAttributes.map(attr => (
        {type: {gid: attr.type.gid}}
      )));

      deferFocus('input.name', '#dialog');
      dialog.open(event.target);
      return dialog;
    }

    return this.displayableRelationships(vm)
      .groupBy(linkPhrase)
      .sortBy('key')
      .map(function (group) {
        group.openAddDialog = openAddDialog;
        group.canBeOrdered = ko.observable(false);

        const relationships = group.values.peek();
        if (!relationships.length) {
          return group;
        }
        const linkType = relationships[0].getLinkType();

        if (linkType && linkType.orderable_direction > 0) {
          group.canBeOrdered = group.values.all(function (r) {
            return r.entityCanBeReordered(r.target(self));
          });
        }

        if (ko.unwrap(group.canBeOrdered)) {
          const hasOrdering = group.values.any(function (r) {
            return r.linkOrder() > 0;
          });

          group.hasOrdering = ko.computed({
            read: hasOrdering,
            write: function (newValue) {
              const currentValue = hasOrdering.peek();

              if (currentValue && !newValue) {
                for (const r of group.values.slice(0)) {
                  r.linkOrder(0);
                }
              } else if (newValue && !currentValue) {
                group.values.slice(0).forEach(function (r, i) {
                  r.linkOrder(i + 1);
                });
              }
            },
          });
        }

        return group;
      });
  }),

  groupedRelationshipsLabel: function (key) {
    return addColon(key);
  },

  /*
   * Searches this entity's relationships for potential duplicate "rel"
   * if it is a duplicate, remove and merge it
   */

  mergeRelationship: function (rel) {
    const relationships = this.relationships();

    for (let i = 0; i < relationships.length; i++) {
      const other = relationships[i];

      if (rel !== other && rel.isDuplicate(other)) {
        const obj = {...rel.editData()};
        delete obj.id;

        obj.begin_date = mergeDates(rel.begin_date, other.begin_date);
        obj.end_date = mergeDates(rel.end_date, other.end_date);

        other.fromJS(obj);
        rel.remove();

        return true;
      }
    }
    return false;
  },

  getRelationshipGroup: function (relationship, viewModel) {
    /*
     * Returns all relationships that belong to the same 'ordering'
     * group as `relationship`, i.e. that have the same link type and
     * direction. Used in fields.js to recalculate link orders when an
     * item is moved. Since displayableRelationships is used,
     * it should be in the same order as it appears in the UI.
     */
    const linkTypeID = String(relationship.linkTypeID());
    const backward = isBackward(relationship, this);

    return this.displayableRelationships(viewModel)().filter(
      r => (
        String(r.linkTypeID()) === linkTypeID &&
        isBackward(r, this) === backward
      ),
    );
  },
});

const recordingPrototype = MB.entity.Recording.prototype;

recordingPrototype._afterRecordingCtor = function () {
  this.performances = this.relationships.filter(isPerformance);
};

function isPerformance(relationship) {
  return relationship.entityTypes === 'recording-work';
}

function isFreeText(linkAttribute) {
  return linkedEntities.link_attribute_type[linkAttribute.type.id].free_text;
}

function cacheByID(func) {
  const cacheID = uniqueId('cache-');

  return function (vm) {
    const cache = this[cacheID] = this[cacheID] || {};
    return cache[vm.uniqueID] || (cache[vm.uniqueID] = func.call(this, vm));
  };
}
