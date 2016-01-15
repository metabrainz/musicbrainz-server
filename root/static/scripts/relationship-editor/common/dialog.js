// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

const {PART_OF_SERIES_LINK_TYPES} = require('../../common/constants');
const i18n = require('../../common/i18n');
const URLCleanup = require('../../edit/URLCleanup');
const dates = require('../../edit/utility/dates');

const PART_OF_SERIES_LINK_TYPE_GIDS = _.values(PART_OF_SERIES_LINK_TYPES);

(function (RE) {

    var UI = RE.UI = RE.UI || {};
    var fields = RE.fields = RE.fields || {};

    var incorrectEntityForSeries = {
        recording:      i18n.l("The series you’ve selected is for recordings."),
        release:        i18n.l("The series you’ve selected is for releases."),
        release_group:  i18n.l("The series you’ve selected is for release groups."),
        work:           i18n.l("The series you’ve selected is for works.")
    };

    ko.bindingHandlers.relationshipEditorAutocomplete = (function () {
        var dialog;

        function changeTarget(data) {
            if (!data || !data.gid) {
                return;
            }
            var relationship = dialog.relationship();
            var entities = relationship.entities().slice(0);

            entities[dialog.backward() ? 0 : 1] = MB.entity(data);
            relationship.entities(entities);
        }

        return {
            init: function (element, valueAccessor, allBindings, viewModel, bindingContext) {
                dialog = valueAccessor();

                dialog.autocomplete = $(element).autocomplete({
                        entity: dialog.targetType(),

                        setEntity: function (type) {
                            if (dialog.disableTypeSelection) {
                                return false;
                            }

                            var possible = dialog.targetTypeOptions();

                            if (!_.find(possible, { value: type })) {
                                return false;
                            }

                            dialog.targetType(type);
                        },

                        resultHook: function (items) {
                            if (dialog.autocomplete.entity === "series" &&
                                    dialog.relationship().linkTypeInfo().orderableDirection !== 0) {
                                return _.filter(items, function (item) {
                                    return item.type.series_entity_type === dialog.source.entityType;
                                });
                            } else {
                                return items;
                            }
                        }
                    }).data("ui-autocomplete");

                dialog.autocomplete.currentSelection.subscribe(changeTarget);

                var target = dialog.relationship().target(dialog.source);

                if (dialog instanceof UI.EditDialog) {
                    dialog.autocomplete.currentSelection(target);
                } else {
                    // Fills in the recording name in the add-related-work dialog.
                    dialog.autocomplete.currentSelection({ name: target.name });
                }
            }
        };
    }());


    ko.bindingHandlers.instrumentSelect = {

        init: function (element, valueAccessor, allBindings, viewModel, bindingContext) {
            var relationship = valueAccessor();
            var instruments = ko.observableArray([]);

            function addInstrument(instrument, linkAttribute) {
                var observable = ko.observable(instrument);

                observable.linkAttribute = ko.observable(linkAttribute);
                instruments.push(observable);

                observable.subscribe(function (instrument) {
                    relationship.attributes.remove(observable.linkAttribute.peek())
                    if (instrument.gid) {
                        observable.linkAttribute(relationship.addAttribute(instrument.gid));
                    } else {
                        observable.linkAttribute(null);
                    }
                });
            }

            function focusLastInput() {
                $(element).find(".ui-autocomplete-input:last").focus();
            }

            _.each(relationship.attributes.peek(), function (attribute) {
                if (attribute.type.rootID == 14) {
                    addInstrument(MB.entity(attribute.type, "instrument"), attribute);
                }
            });

            if (!instruments.peek().length) {
                addInstrument(MB.entity.Instrument({}));
            }

            var vm = {
                instruments: instruments,

                addItem: function () {
                    addInstrument(MB.entity.Instrument({}));
                    focusLastInput();
                },

                removeItem: function (item) {
                    var index = instruments.indexOf(item);

                    instruments.remove(item);
                    relationship.attributes.remove(item.linkAttribute.peek());

                    index = index === instruments().length ? index - 1 : index;
                    var $nextButton = $(element).find("button.remove-item:eq(" + index + ")");

                    if ($nextButton.length) {
                        $nextButton.focus();
                    } else {
                        focusLastInput();
                    }
                }
            };

            var childBindingContext = bindingContext.createChildContext(vm);
            ko.applyBindingsToDescendants(childBindingContext, element);

            return { controlsDescendantBindings: true };
        }
    };


    var Dialog = aclass({

        loading: ko.observable(false),
        showAttributesHelp: ko.observable(false),
        showLinkTypeHelp: ko.observable(false),

        uiOptions: {
            dialogClass: "rel-editor-dialog",
            draggable: false,
            resizable: false,
            autoOpen: false,
            width: "auto"
        },

        init: function (options) {
            var self = this;

            this.viewModel = options.viewModel;

            var source = options.source;
            var target = options.target;

            if (options.relationship) {
                target = options.relationship.target(source);
            } else {
                options.relationship = this.viewModel.getRelationship({
                    target: target, direction: options.direction
                }, source);

                options.relationship.linkTypeID(
                    defaultLinkType({ children: MB.typeInfo[options.relationship.entityTypes] })
                );
            }

            this.relationship = ko.observable(options.relationship);
            this.source = source;

            this.targetType = ko.observable(target.entityType);
            this.targetType.subscribe(this.targetTypeChanged, this);

            this.changeAllRelationshipCredits = ko.observable(false);
            this.setupUI();
        },

        setupUI: _.once(function () {
            var $dialog = $("#dialog").dialog(this.uiOptions);

            var widget = $dialog.data("ui-dialog");
            widget.uiDialog.find(".ui-dialog-titlebar").remove();

            Dialog.extend({ $dialog: $dialog, widget: widget });
            ko.applyBindings(this.viewModel, $dialog[0]);
        }),

        open: function (positionBy) {
            this.viewModel.activeDialog(this);

            var widget = this.widget;

            this.positionBy(positionBy);

            if (!widget.isOpen()) {
                widget.open();
            }

            if (widget.uiDialog.width() > widget.options.maxWidth) {
                widget.uiDialog.width(widget.options.maxWidth);
            }

            // Call this.positionBy twice to prevent jumping in Opera
            this.positionBy(positionBy);

            this.$dialog.find(".link-type").focus();
        },

        accept: function (inner) {
            if (!this.hasErrors()) {
                inner && inner.apply(this, _.toArray(arguments).slice(1));

                if (this.changeAllRelationshipCredits()) {
                    var vm = this.viewModel;
                    var relationship = this.relationship();
                    var target = relationship.target(this.source);
                    var targetCredit = relationship.creditField(target)();

                    // XXX HACK XXX
                    // MB.entityCache isn't supposed to be exposed outside of
                    // whatever module it's defined in, but there's no easier
                    // way to iterate over all entities on the page.

                    _.each(MB.entityCache, function (entity, gid) {
                        if (gid === target.gid) {
                            _.each(entity.displayableRelationships(vm)(), function (r) {
                                var entities = r.entities();

                                if (entities[0].gid === gid) {
                                    r.entity0_credit(targetCredit);
                                }

                                if (entities[1].gid === gid) {
                                    r.entity1_credit(targetCredit);
                                }
                            });
                        }
                    });
                }

                this.close(false);
            }
        },

        close: function () {
            this.viewModel.activeDialog(null);
            this.widget && this.widget.close();
        },

        clickEvent: function (data, event) {
            if (!event.isDefaultPrevented()) {
                var $menu = this.$dialog.find(".menu");

                if ($menu.length) {
                    $menu.data("multiselect").menuVisible(false);
                }
            }

            return true;
        },

        keydownEvent: function (data, event) {
            if (event.isDefaultPrevented()) {
                return;
            }

            var nodeName = event.target.nodeName.toLowerCase();
            var self = this;

            // Firefox needs a small delay in order to allow for the change
            // event to trigger on <select> menus, and Opera 12.0* needs it
            // triggered explicitly, so do that first.

            if (event.keyCode === 13 && /^input|select$/.test(nodeName)) {
                $(event.target).trigger('change');

                if (!this.hasErrors()) {
                    // Opera 12.0* also has a bug where the pencil icon is
                    // clicked if the dialog is closed too fast, which makes
                    // it immediately reopen, hence the added delay here.
                    _.defer(function () { self.accept() });
                }
            } else if (event.keyCode === 27 && nodeName !== "select") {
                this.close();
            }

            return true;
        },

        toggleAttributesHelp: function () {
            this.showAttributesHelp(!this.showAttributesHelp());
        },

        changeDirection: function () {
            var relationship = this.relationship.peek();
            relationship.entities(relationship.entities().slice(0).reverse());
        },

        backward: function () {
            return this.source === this.relationship().entities()[1];
        },

        toggleLinkTypeHelp: function () {
            this.showLinkTypeHelp(!this.showLinkTypeHelp.peek());
        },

        linkTypeDescription: function () {
            var typeInfo = this.relationship().linkTypeInfo();
            var description;

            if (typeInfo) {
                description = i18n.l("{description} ({url|more documentation})", {
                    description: typeInfo.description,
                    url: { href: "/relationship/" + typeInfo.gid, target: "_blank" }
                });
            }

            return description || "";
        },

        positionBy: function (element) {
            this.widget._setOption("position", {
                my: "top center", at: "center", of: element
            });
        },

        linkTypeOptions: function (entityTypes) {
            var options = MB.forms.linkTypeOptions(
                { children: MB.typeInfo[entityTypes] }, this.backward()
            );

            if (this.source.entityType === "series") {
                var itemType = MB.seriesTypesByID[this.source.typeID()].series_entity_type;

                options = _.reject(options, function (opt) {
                    var info = MB.typeInfoByID[opt.value];

                    if (_.contains(PART_OF_SERIES_LINK_TYPE_GIDS, info.gid) &&
                            info.gid !== PART_OF_SERIES_LINK_TYPES[itemType]) {
                        return true;
                    }
                });
            }

            return options;
        },

        targetTypeOptions: function () {
            var sourceType = this.source.entityType;
            var targetTypes = _.without(MB.allowedRelations[sourceType], 'url');

            if (sourceType === "series") {
                var self = this;

                targetTypes = _.filter(targetTypes, function (targetType) {
                    var key = [sourceType, targetType].sort().join("-");

                    if (self.linkTypeOptions(key).length) {
                        return true;
                    }
                })
            }

            var options = _.map(targetTypes, function (type) {
                return { value: type, text: i18n.strings.entityName[type] };
            });

            options.sort(function (a, b) {
                return i18n.compare(a.text, b.text);
            });

            return options;
        },

        targetTypeChanged: function (newType) {
            if (!newType) return;

            var currentRelationship = this.relationship();
            var currentTarget = currentRelationship.target(this.source);

            var data = currentRelationship.editData();
            data.target = MB.entity({ name: currentTarget.name }, newType);

            // Always keep any existing dates, even if the new relationship
            // doesn't support them. If they're not supported they'll be
            // hidden/ignored anyway, but if the user changes the target type
            // or link type again (to something that does support them), we
            // want to preserve what they previously entered.
            var period = currentRelationship.period;
            data.beginDate = MB.edit.fields.partialDate(period.beginDate);
            data.endDate = MB.edit.fields.partialDate(period.endDate);
            data.ended = !!period.ended();

            delete data.entities;

            var entityTypes = [this.source.entityType, newType].sort().join("-");
            data.linkTypeID = defaultLinkType({ children: MB.typeInfo[entityTypes] });
            data.attributes = [];

            var newRelationship = this.viewModel.getRelationship(data, this.source);

            this.relationship(newRelationship);

            // XXX knockout is stupid and unsets the linkTypeID for no apparent
            // reason, so do it again...
            newRelationship.linkTypeID(data.linkTypeID);

            currentRelationship.remove();

            var ac = this.autocomplete;

            if (ac) {
                ac.clear();
                ac.changeEntity(newType);
            }
        },

        linkTypeError: function () {
            var typeInfo = this.relationship().linkTypeInfo();

            if (!typeInfo) {
                return i18n.l("Please select a relationship type.");
            } else if (!typeInfo.description) {
                return i18n.l("Please select a subtype of the currently selected relationship type. The selected relationship type is only used for grouping subtypes.");
            } else if (typeInfo.deprecated) {
                return i18n.l("This relationship type is deprecated and should not be used.");
            } else if (this.source.entityType === "url") {
                var checker = URLCleanup.validationRules[typeInfo.gid];

                if (checker && !checker(this.source.name())) {
                    return i18n.l("This URL is not allowed for the selected link type, or is incorrectly formatted.");
                }
            }

            return "";
        },

        targetEntityError: function () {
            var relationship = this.relationship();
            var target = relationship.target(this.source);
            var typeInfo = relationship.linkTypeInfo() || {};

            if (!target.gid) {
                return i18n.l("Required field.");
            } else if (this.source === target) {
                return i18n.l("Entities in a relationship cannot be the same.");
            }

            if (target.entityType === "series" &&
                    _.contains(PART_OF_SERIES_LINK_TYPE_GIDS, typeInfo.gid) &&
                    target.type().entityType !== this.source.entityType) {
                return incorrectEntityForSeries[target.type().entityType];
            }

            return "";
        },

        dateError: function (date) {
            var valid = dates.isDateValid(date.year(), date.month(), date.day());
            return valid ? "" : i18n.l("The date you've entered is not valid.");
        },

        datePeriodError: function () {
            var period = this.relationship().period;

            var a = period.beginDate;
            var b = period.endDate;

            if (!this.dateError(a) && !this.dateError(b)) {
                if (!dates.isDatePeriodValid(ko.toJS(a), ko.toJS(b))) {
                    return i18n.l("The end date cannot precede the begin date.");
                }
            }

            return "";
        },

        hasErrors: function () {
            var relationship = this.relationship();

            return this.linkTypeError() ||
                   this.targetEntityError() ||
                   _(relationship.linkTypeInfo().attributes)
                     .values().map(_.bind(relationship.attributeError, relationship)).any() ||
                   this.dateError(relationship.period.beginDate) ||
                   this.dateError(relationship.period.endDate) ||
                   this.datePeriodError();
        }
    });

    function addRelationships(relationships, source, viewModel) {
        _.each(relationships, function (relationship) {
            if (source.mergeRelationship(relationship)) {
                return;
            }

            if (relationship.linkTypeInfo().orderableDirection) {
                var group = source.getRelationshipGroup(relationship, viewModel);
                var maxLinkOrder = -Infinity;

                _.each(group, function (other) {
                    maxLinkOrder = Math.max(maxLinkOrder, other.linkOrder.peek() || 0);
                });

                if (maxLinkOrder === 0 || !_.isFinite(maxLinkOrder)) {
                    // Leave unordered relationships unordered.
                    relationship.linkOrder(0);
                } else {
                    relationship.linkOrder(maxLinkOrder + 1);
                }
            }

            relationship.show();
        });
    }

    UI.AddDialog = aclass(Dialog, {

        dialogTemplate: "template.relationship-dialog",
        disableTypeSelection: false,

        augment$accept: function () {
            addRelationships(splitByCreditableAttributes(this.relationship()), this.source, this.viewModel);
        },

        before$close: function (cancel) {
            if (cancel !== false) {
                this.relationship().remove();
            }
        }
    });


    UI.EditDialog = aclass(Dialog, {

        dialogTemplate: "template.relationship-dialog",
        disableTypeSelection: true,

        before$init: function (options) {
            // originalRelationship is a copy of the relationship when the dialog
            // was opened, i.e. before the user edits it. if they cancel the
            // dialog, this is what gets copied back to revert their changes.
            this.originalRelationship = options.relationship.editData();
            this.editing = options.relationship;
            options.relationship = this.editing.clone();
        },

        augment$accept: function () {
            var relationships = splitByCreditableAttributes(this.relationship()),
                relationship = relationships.shift();

            this.editing.fromJS(relationship.editData());

            if (relationships.length) {
                addRelationships(relationships, this.source, this.viewModel);
            }
        },

        before$close: function (cancel) {
            if (cancel !== false) {
                var relationship = this.relationship();

                if (!_.isEqual(this.originalRelationship, relationship.editData())) {
                    relationship.fromJS(this.originalRelationship);
                }
            }
        }
    });


    UI.BatchRelationshipDialog = aclass(Dialog, {

        dialogTemplate: "template.batch-relationship-dialog",
        disableTypeSelection: false,

        around$init: function (supr, options) {
            this.sources = options.sources;

            options.source = MB.entity({}, this.sources[0].entityType);
            options.target = options.target || MB.entity.Artist({});

            supr(options);
        },

        augment$accept: function (callback) {
            var vm = this.viewModel;
            var model = _.omit(this.relationship().editData(), "id", "entities");

            model.target = this.relationship().target(this.source);
            model.direction = this.backward() ? "backward" : "forward";

            _.each(this.sources, function (source) {
                model = _.clone(model);

                if (!callback || callback(model)) {
                    addRelationships(splitByCreditableAttributes(vm.getRelationship(model, source)), source, vm);
                }
            });
        }
    });


    UI.BatchCreateWorksDialog = aclass(UI.BatchRelationshipDialog, {

        dialogTemplate: "template.batch-create-works-dialog",
        workType: ko.observable(null),
        workLanguage: ko.observable(null),

        around$init: function (supr, options) {
            this.error = ko.observable(false);
            supr(_.assign(options, { target: MB.entity.Work({}) }));
        },

        around$accept: function (supr) {
            var self = this,
                workType = this.workType(),
                workLang = this.workLanguage();

            this.loading(true);

            var edits = _.map(this.sources, function (source) {
                var editData = MB.edit.fields.work({
                    name: source.name,
                    typeID: workType,
                    languageID: workLang
                });

                return MB.edit.workCreate(editData);
            });

            MB.edit.create({ editNote: "", makeVotable: false, edits: edits })
                .done(function (data) {
                    var works = _.pluck(data.edits, "entity");

                    supr(function (relationshipData) {
                        relationshipData.target = MB.entity(works.shift(), "work");
                        return true;
                    });

                    self.loading(false);
                })
                .fail(function () {
                    self.loading(false);
                    self.error(true);
                });
        },

        targetEntityError: function () { return "" }
    });


    function defaultLinkType(root) {
        var child, id, i = 0;

        while (child = root.children[i++]) {
            if (child.description && !child.deprecated) {
                return child.id;
            }
            if (child.children && (id = defaultLinkType(child))) {
                return id;
            }
        }
    }

    function isCreditable(attribute) {
        return attribute.type.creditable;
    }

    function linkAttributeTypeID(attribute) {
        return attribute.type.id;
    }

    function splitByCreditableAttributes(relationship) {
        var attributes = relationship.attributes(),
            creditable = _.filter(attributes, isCreditable),
            relationships = [relationship];

        if (!creditable.length) {
            return relationships;
        }

        var notCreditable = _.reject(attributes, isCreditable);

        function split(attribute) {
            var newRelationship = relationship.clone();
            newRelationship.setAttributes(notCreditable.concat([attribute]));
            relationships.push(newRelationship);
        }

        _(creditable)
            .groupBy(linkAttributeTypeID)
            .each(function (attributes) {
                var extra = _.rest(attributes);
                relationship.attributes.removeAll(extra);
                _.each(extra, split);
            })
            .value();

        return relationships;
    }

}(MB.relationshipEditor = MB.relationshipEditor || {}));
