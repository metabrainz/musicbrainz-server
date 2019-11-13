// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import ko from 'knockout';
import _ from 'lodash';

import 'knockout-arraytransforms';

import linkedEntities from '../../common/linkedEntities';
import MB from '../../common/MB';
import deferFocus from '../../edit/utility/deferFocus';

import mergeDates from './mergeDates';

import '../../common/entity';

function getDirection(relationship, source) {
  let entities = relationship.entities();

  if (source === entities[0]) {
    return 'forward';
  }

  if (source === entities[1]) {
    return 'backward';
  }
}

const RE = MB.relationshipEditor = MB.relationshipEditor || {};

    const coreEntityPrototype = MB.entity.CoreEntity.prototype;

    coreEntityPrototype._afterCoreEntityCtor = function () {
        if (this.uniqueID == null) {
            this.uniqueID = _.uniqueId("entity-");
        }
        this.relationshipElements = {};
    };

    Object.assign(coreEntityPrototype, {

        parseRelationships: function (relationships) {
            var self = this;

            if (!relationships || !relationships.length) {
                return;
            }

            var newRelationships = _(relationships)
                .map(function (data) { return MB.getRelationship(data, self) })
                .compact()
                .value();

            var allRelationships = _(this.relationships.peek())
                .union(newRelationships)
                .sortBy(function (r) { return r.lowerCasePhrase(self) })
                .value();

            this.relationships(allRelationships);

            _.each(relationships, function (data) {
                MB.entity(data.target).parseRelationships(data.target.relationships);
            });
        },

        displayableRelationships: cacheByID(function (vm) {
            return vm._sortedRelationships(this.relationshipsInViewModel(vm), this);
        }),

        relationshipsInViewModel: cacheByID(function (vm) {
            var self = this;
            return this.relationships.filter(function (relationship) {
                return vm === relationship.parent;
            });
        }),

        groupedRelationships: cacheByID(function (vm) {
            var self = this;

            function linkPhrase(relationship) {
                return relationship.groupingLinkPhrase(self);
            }

            function openAddDialog(source, event) {
                var relationships = this.values(),
                    firstRelationship = relationships[0];

                var dialog = new RE.UI.AddDialog({
                    source: self,
                    target: MB.entity({}, firstRelationship.target(self).entityType),
                    direction: getDirection(firstRelationship, self),
                    viewModel: vm,
                });

                var relationship = dialog.relationship();
                relationship.linkTypeID(firstRelationship.linkTypeID());

                var attributeLists = _.invokeMap(relationships, "attributes");

                var commonAttributes = _.map(
                    _.reject(_.intersection.apply(_, attributeLists), isFreeText),
                    function (attr) {
                        return {type: {gid: attr.type.gid}};
                    },
                );

                relationship.setAttributes(commonAttributes);
                deferFocus("input.name", "#dialog");
                dialog.open(event.target);
                return dialog;
            }

            return this.displayableRelationships(vm)
                .groupBy(linkPhrase).sortBy("key").map(function (group) {
                    group.openAddDialog = openAddDialog;
                    group.canBeOrdered = ko.observable(false);

                    var relationships = group.values.peek();
                    if (!relationships.length) {
                        return group;
                    }
                    var linkType = relationships[0].getLinkType();

                    if (linkType && linkType.orderable_direction > 0) {
                        group.canBeOrdered = group.values.all(function (r) {
                            return r.entityCanBeReordered(r.target(self));
                        });
                    }

                    if (ko.unwrap(group.canBeOrdered)) {
                        var hasOrdering = group.values.any(function (r) { return r.linkOrder() > 0 });

                        group.hasOrdering = ko.computed({
                            read: hasOrdering,
                            write: function (newValue) {
                                var currentValue = hasOrdering.peek();

                                if (currentValue && !newValue) {
                                    _.each(group.values.slice(0), function (r) { r.linkOrder(0) });
                                } else if (newValue && !currentValue) {
                                    _.each(group.values.slice(0), function (r, i) { r.linkOrder(i + 1) });
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

        // searches this entity's relationships for potential duplicate "rel"
        // if it is a duplicate, remove and merge it

        mergeRelationship: function (rel) {
            var relationships = this.relationships();

            for (var i = 0; i < relationships.length; i++) {
                var other = relationships[i];

                if (rel !== other && rel.isDuplicate(other)) {
                    var obj = _.omit(rel.editData(), "id");

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
            // Returns all relationships that belong to the same 'ordering'
            // group as `relationship`, i.e. that have the same link type and
            // direction. Used in fields.js to recalculate link orders when an
            // item is moved. Since displayableRelationships is used, it should
            // be in the same order as it appears in the UI.
            let linkTypeID = String(relationship.linkTypeID());
            let direction = getDirection(relationship, this);

            return _.filter(
                this.displayableRelationships(viewModel)(),
                r => String(r.linkTypeID()) === linkTypeID && getDirection(r, this) === direction,
            );
        },
    });

    const recordingPrototype = MB.entity.Recording.prototype;

    recordingPrototype._afterRecordingCtor = function () {
        this.performances = this.relationships.filter(isPerformance);
    };

    function isPerformance(relationship) {
        return relationship.entityTypes === "recording-work";
    }

    function isFreeText(linkAttribute) {
        return linkedEntities.link_attribute_type[linkAttribute.type.id].free_text;
    }

    function cacheByID(func) {
        var cacheID = _.uniqueId("cache-");

        return function (vm) {
            var cache = this[cacheID] = this[cacheID] || {};
            return cache[vm.uniqueID] || (cache[vm.uniqueID] = func.call(this, vm));
        };
    }
