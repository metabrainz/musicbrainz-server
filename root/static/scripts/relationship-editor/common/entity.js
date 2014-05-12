// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

(function (RE) {

    var rateLimitOptions = {
        rateLimit: { method: "notifyWhenChangesStop", timeout: 100 }
    };


    MB.entity.CoreEntity.extend({

        parseRelationships: function (relationships, viewModel) {
            var self = this;

            if (!relationships || !relationships.length) {
                return;
            }

            var newRelationships = _(relationships)
                .map(function (data) { return viewModel.getRelationship(data, self) })
                .compact()
                .sortBy(function (r) { return r.lowerCasePhrase(self) })
                .value();

            var existingRelationships = this.relationships.peek();
            this.relationships(_.union(existingRelationships, newRelationships));
        },

        displayRelationships: function (viewModel) {
            var self = this;

            return _.filter(this.relationships(), function (relationship) {
                var types = relationship.entityTypes.split("-");
                var targetType = self.entityType === types[0] ? types[1] : types[0];

                if (!viewModel.typesAreAccepted(self.entityType, targetType)) {
                    return false;
                }

                return viewModel.goodCardinality(
                    relationship.linkTypeID(),
                    self.entityType,
                    self === relationship.entities()[1]
                );
            });
        },

        // searches this entity's relationships for potential duplicate "rel"
        // if it is a duplicate, remove and merge it

        mergeRelationship: function (rel) {
            var relationships = this.relationships();

            for (var i = 0; i < relationships.length; i++) {
                var other = relationships[i];

                if (rel !== other && rel.isDuplicate(other)) {
                    var obj = _.omit(rel.editData(), "id");

                    obj.beginDate = MB.utility.mergeDates(
                        rel.period.beginDate, other.period.beginDate
                    );

                    obj.endDate = MB.utility.mergeDates(
                        rel.period.endDate, other.period.endDate
                    );

                    other.fromJS(obj);
                    rel.remove();

                    return true;
                }
            }
            return false;
        },

        changedRelationships: function (viewModel) {
            return _.filter(this.displayRelationships(viewModel), hasChanges);
        },

        groupedRelationships: function (viewModel) {
            var self = this;
            var oldGroups = this.__groupedRelationships = this.__groupedRelationships || [];
            var newGroups = [];

            function sortKey(relationship) {
                var targetType = relationship.target(self).entityType;
                var linkTypeID = relationship.linkTypeID();
                var linkPhrase = relationship.phraseAndExtraAttributes(self);

                return targetType + "\0" + linkTypeID + "\0" + linkPhrase[0];
            }

            // This is mostly designed so that the knockout foreach binding
            // doesn't wastefully redraw the entire list (and break the active
            // focus in the process).

            _(self.displayRelationships(viewModel))
                .groupBy(sortKey)
                .each(function (relationships, key) {
                    var group = _.findWhere(oldGroups, { sortKey: key });
                    var attributes = _.intersection.apply(_, _.invoke(relationships, "attributes"));

                    relationships = viewModel.orderedRelationships(
                        _(relationships)
                            .sortBy(function (r) { return r.lowerCasePhrase(self) })
                            .sortBy(function (r) { return r.lowerCaseTargetName(self) })
                            .value(), self
                    );

                    if (group) {
                        group.relationships(relationships);
                    } else {
                        var keyParts = key.split("\0");

                        group = {
                            sortKey: key,
                            targetType: keyParts[0],
                            linkTypeID: +keyParts[1],
                            linkPhrase: keyParts[2],
                            relationships: ko.observableArray(relationships),

                            openAddDialog: function (source, event) {
                                var backward = source === group.relationships()[0].entities()[1];

                                var dialog = RE.UI.AddDialog({
                                    source: source,
                                    target: MB.entity({}, keyParts[0]),
                                    direction: backward ? "backward" : "forward",
                                    viewModel: viewModel
                                });

                                var relationship = dialog.relationship();
                                relationship.linkTypeID(keyParts[1]);
                                relationship.attributes(attributes.slice(0));

                                MB.utility.deferFocus("input.name", "#dialog");

                                dialog.open(event.target);
                            }
                        };
                    }

                    newGroups.push(group);
                    delete relationships;
                    delete key;
                });

            // jQuery UI dialogs have an "opener" property that points to the
            // button or other element that opened the dialog, so that focus
            // can be returned once the dialog is closed. Because updating
            // groupedRelationships may cause knockout to remove the opener,
            // we update it based on the ID of the previous one.

            var dialog = viewModel.activeDialog.peek();

            if (dialog && dialog.widget.isOpen()) {
                _.defer(function () {
                    dialog.widget.opener = $("#" + dialog.widget.opener.attr("id"));
                });
            }

            return (this.__groupedRelationships = _.sortBy(newGroups, "sortKey"));
        },

        getRelationshipGroup: function (linkTypeID, viewModel) {
            return _(this.groupedRelationships(viewModel))
                .values().where({ linkTypeID: +linkTypeID })
                .invoke("relationships").flatten().value();
        }
    });


    function hasChanges(relationship) {
        return relationship.hasChanges();
    }

    function filterPerformances() {
        return _.filter(this.relationships(), { entityTypes: "recording-work" });
    }


    MB.entity.Recording.extend({

        performances: filterPerformances,

        around$changedRelationships: function (supr, viewModel) {
            return supr(viewModel).concat(
                _.transform(this.performances(), function (result, relationship) {
                    if (relationship.hasChanges()) result.push(relationship);

                    result.push.apply(
                        result,
                        relationship.entities()[1].changedRelationships(viewModel)
                    );
                })
            );
        }
    });


    MB.entity.Release.extend({

        around$changedRelationships: function (supr, viewModel) {
            return supr(viewModel).concat(
                _.transform(this.mediums(), function (result, medium) {
                    _.each(medium.tracks, function (track) {
                        result.push.apply(
                            result,
                            track.recording.changedRelationships(viewModel)
                        );
                    });
                })
            );
        }
    });


    MB.entity.Work.extend({

        performanceCount: function () {
            return filterPerformances.call(this).length;
        }
    });

}(MB.relationshipEditor = MB.relationshipEditor || {}));
