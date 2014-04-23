// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

(function (RE) {

    var UI = RE.UI = RE.UI || {};


    RE.GenericEntityViewModel = aclass(RE.ViewModel, {

        activeDialog: ko.observable(),
        fieldName: "rel",

        after$init: function () {
            this.editNote = ko.observable("");
            this.asAutoEditor = ko.observable(true);

            this.submissionLoading = ko.observable(false);
            this.submissionError = ko.observable("");
        },

        typesAreAccepted: function (sourceType, targetType) {
            return sourceType !== "url" && targetType !== "url";
        },

        hasChanges: function (entity) {
            return entity.changedRelationships(this).length > 0;
        },

        getEdits: function (addChanged) {
            _.each(this.source.changedRelationships(this), addChanged);
        },

        submit: function (data, event) {
            event.preventDefault();

            var edits = [];
            var alreadyAdded = {};

            this.submissionLoading(true);

            function addChanged(relationship) {
                if (alreadyAdded[relationship.uniqueID]) {
                    return;
                }
                alreadyAdded[relationship.uniqueID] = true;

                var editData = relationship.editData();

                if (relationship.added()) {
                    edits.push(MB.edit.relationshipCreate(editData));
                }
                else if (relationship.edited()) {
                    edits.push(MB.edit.relationshipEdit(editData, relationship.original));
                }
                else if (relationship.removed()) {
                    edits.push(MB.edit.relationshipDelete(editData));
                }
            }

            this.getEdits(addChanged);

            if (edits.length == 0) {
                this.submissionLoading(false);
                this.submissionError(MB.text.NoChanges);
                return;
            }

            var data = {
                editNote: this.editNote(),
                asAutoEditor: this.asAutoEditor(),
                edits: edits
            };

            var beforeUnload = window.onbeforeunload;
            if (beforeUnload) window.onbeforeunload = undefined;

            MB.edit.create(data, this)
                .always(function () {
                    this.submissionLoading(false);
                })
                .done(this.submissionDone)
                .fail(function (jqXHR) {
                    try {
                        var response = JSON.parse(jqXHR.responseText);
                        var message = _.isObject(response.error) ?
                                        response.error.message : response.error;

                        this.submissionError(message);
                    }
                    catch (e) {
                        this.submissionError(jqXHR.responseText);
                    }

                    if (beforeUnload) window.onbeforeunload = beforeUnload;
                });
        },

        submissionDone: function () {
            window.location.reload();
        },

        openAddDialog: function (source, event) {
            var targetType = this.allowedRelations[source.entityType][0];

            UI.AddDialog({
                source: source,
                target: MB.entity({}, targetType),
                viewModel: this
            }).open(event.target);
        },

        openEditDialog: function (relationship, event) {
            if (!relationship.removed()) {
                UI.EditDialog({
                    relationship: relationship,
                    source: ko.contextFor(event.target).$parents[1],
                    viewModel: this
                }).open(event.target);
            }
        },

        removeRelationship: function (relationship) {
            if (relationship.added()) {
                relationship.remove();
            } else if (relationship.removed()) {
                relationship.removed(false);
            } else {
                if (relationship.edited()) {
                    relationship.fromJS(relationship.original);
                }
                relationship.removed(true);
            }
        }
    });


    ko.bindingHandlers.relationshipStyling = {

        update: function (element) {
            var relationship = arguments[3];
            var added = relationship.added();

            $(element)
                .toggleClass("rel-add", added)
                .toggleClass("rel-remove", relationship.removed())
                .toggleClass("rel-edit", !added && relationship.edited());
        }
    };

}(MB.relationshipEditor = MB.relationshipEditor || {}));
