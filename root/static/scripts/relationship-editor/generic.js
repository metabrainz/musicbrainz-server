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
            return targetType !== "url";
        },

        getEdits: function (addChanged) {
            var source = this.source;
            _.each(source.relationships(), function (r) {
                addChanged(r, source);
            });
        },

        submit: function (data, event) {
            event.preventDefault();

            var self = this;
            var edits = [];
            var alreadyAdded = {};

            this.submissionLoading(true);

            function addChanged(relationship, source) {
                if (alreadyAdded[relationship.uniqueID]) {
                    return;
                }
                if (!self.containsRelationship(relationship, source)) {
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
        },

        _sortedRelationships: function (relationships, source) {
            var self = this, sorted;

            sorted = relationships.sortBy(function (relationship) {
                return relationship.lowerCaseTargetName(source);
            }).sortBy("linkOrder");

            if (source.entityType === "series") {
                sorted = sorted.sortBy(function (relationship) {
                    if (+source.orderingTypeID() === MB.constants.SERIES_ORDERING_TYPE_AUTOMATIC) {
                        return relationship.paddedSeriesNumber();
                    }
                    return "";
                });
            }

            return sorted;
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


    function addHiddenInputs(vm) {
        var fieldPrefix = vm.formName + "." + vm.fieldName;
        var relationships = vm.source.relationshipsInViewModel(vm)();
        var hiddenInputs = document.createDocumentFragment();
        var index = 0;

        function pushInput(prefix, name, value) {
            var input = document.createElement("input");
            input.type = "hidden";
            input.name = prefix + "." + name;
            input.value = value;
            hiddenInputs.appendChild(input);
        }

        for (var i = 0, len = relationships.length; i < len; i++) {
            var relationship = relationships[i],
                editData = relationship.editData(),
                prefix = fieldPrefix + "." + index;

            if (!editData.linkTypeID) {
                continue;
            }

            if (relationship.id) {
                pushInput(prefix, "relationship_id", relationship.id);
            }

            if (relationship.removed()) {
                pushInput(prefix, "removed", 1);
            }

            var target = relationship.target(vm.source),
                attributes = editData.attributes,
                attributeTextValues = editData.attributeTextValues,
                attrTextIndex = 0;

            if (target.entityType === "url") {
                pushInput(prefix, "text", target.name);
            } else {
                pushInput(prefix, "target", target.gid);
            }

            for (var j = 0, id; id = attributes[j]; j++) {
                pushInput(prefix, "attributes." + j, id);
            }

            for (id in attributeTextValues) {
                var value = attributeTextValues[id],
                    attrTextPrefix = prefix + ".attribute_text_values." + (attrTextIndex++);

                pushInput(attrTextPrefix, "attribute", id);
                pushInput(attrTextPrefix, "text_value", value);
            }

            var beginDate = editData.beginDate,
                endDate = editData.endDate,
                ended = editData.ended;

            if (beginDate) {
                pushInput(prefix, "period.begin_date.year", beginDate.year);
                pushInput(prefix, "period.begin_date.month", beginDate.month);
                pushInput(prefix, "period.begin_date.day", beginDate.day);
            }

            if (endDate) {
                pushInput(prefix, "period.end_date.year", endDate.year);
                pushInput(prefix, "period.end_date.month", endDate.month);
                pushInput(prefix, "period.end_date.day", endDate.day);
            }

            if (ended) {
                pushInput(prefix, "period.ended", 1);
            }

            if (vm.source !== relationship.entities()[0]) {
                pushInput(prefix, "backward", 1);
            }

            pushInput(prefix, "link_type_id", editData.linkTypeID || "");

            var original = relationship.original;
            if (original) {
                var oldLinkOrder = original.linkOrder || 0,
                    newLinkOrder = editData.linkOrder;

                if (oldLinkOrder !== newLinkOrder) {
                    pushInput(prefix, "link_order", newLinkOrder);
                }
            }

            index++;
        }

        $("#relationship-editor").append(hiddenInputs);
    }

    $(document).on("submit", "form", function () {
        if (MB.sourceRelationshipEditor) {
            addHiddenInputs(MB.sourceRelationshipEditor);
        }

        if (MB.sourceExternalLinksEditor) {
            addHiddenInputs(MB.sourceExternalLinksEditor);
        }
    });

}(MB.relationshipEditor = MB.relationshipEditor || {}));
