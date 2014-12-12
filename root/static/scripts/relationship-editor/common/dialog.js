// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

(function (RE) {

    var UI = RE.UI = RE.UI || {};
    var fields = RE.fields = RE.fields || {};


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
                                    return item.type.entityType === dialog.source.entityType;
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
                    var gid = instrument.gid;
                    if (gid) {
                        observable.linkAttribute(relationship.addAttribute(gid));
                    } else {
                        relationship.attributes.remove(observable.linkAttribute.peek());
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
            // event to trigger on <select> menus.

            _.defer(function () {
                if (event.keyCode === 13 && /^input|select$/.test(nodeName) && !self.hasErrors()) {
                    self.accept();
                } else if (event.keyCode === 27 && nodeName !== "select") {
                    self.close();
                }
            });

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
                description = MB.i18n.expand(MB.text.MoreDocumentation, {
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
                var itemType = MB.seriesTypesByID[this.source.typeID()].entityType;

                options = _.reject(options, function (opt) {
                    var info = MB.typeInfoByID[opt.value];

                    if (_.contains(MB.constants.PART_OF_SERIES_LINK_TYPES, info.gid) &&
                            info.gid !== MB.constants.PART_OF_SERIES_LINK_TYPES_BY_ENTITY[itemType]) {
                        return true;
                    }
                });
            }

            return options;
        },

        targetTypeOptions: function () {
            var sourceType = this.source.entityType;
            var targetTypes = MB.allowedRelations[sourceType];

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
                return { value: type, text: MB.text.Entity[type] };
            });

            options.sort(function (a, b) {
                return MB.i18n.compare(a.text, b.text);
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
                return MB.text.PleaseSelectARType;
            } else if (!typeInfo.description) {
                return MB.text.PleaseSelectARSubtype;
            } else if (typeInfo.deprecated) {
                return MB.text.RelationshipTypeDeprecated;
            } else if (this.source.entityType === "url") {
                var checker = MB.editURLCleanup.validationRules[typeInfo.gid];

                if (checker && !checker(this.source.name())) {
                    return MB.text.URLNotAllowed;
                }
            }

            return "";
        },

        targetEntityError: function () {
            var target = this.relationship().target(this.source);

            if (!target.gid) {
                return MB.text.RequiredField;
            } else if (this.source === target) {
                return MB.text.DistinctEntities;
            }

            if (target.entityType === "series" &&
                    target.type().entityType !== this.source.entityType) {
                return MB.text.IncorrectEntityForSeries[target.type().entityType];
            }

            return "";
        },

        dateError: function (date) {
            var valid = MB.utility.validDate(date.year(), date.month(), date.day());
            return valid ? "" : MB.text.InvalidDate;
        },

        datePeriodError: function () {
            var period = this.relationship().period;

            var a = period.beginDate;
            var b = period.endDate;

            if (!this.dateError(a) && !this.dateError(b)) {
                if (!MB.utility.validDatePeriod(ko.toJS(a), ko.toJS(b))) {
                    return MB.text.InvalidEndDate;
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

    function addRelationships(source, relationships) {
        var linkType = relationships[0].linkTypeInfo();

        for (var i = 0, len = relationships.length; i < len; i++) {
            relationship = relationships[i];

            if (source.mergeRelationship(relationship)) {
                continue;
            }

            if (linkType.orderableDirection) {
                var maxLinkOrder = -Infinity,
                    sourceRelationships = source.relationships();

                for (var i = 0, r; r = sourceRelationships[i]; i++) {
                    if (r.linkTypeID.peek() === linkType.id) {
                        maxLinkOrder = Math.max(maxLinkOrder, r.linkOrder.peek() || 0);
                    }
                }
                relationship.linkOrder(_.isFinite(maxLinkOrder) ? (maxLinkOrder + 1) : 1);
            }
            relationship.show();
        }
    }

    UI.AddDialog = aclass(Dialog, {

        dialogTemplate: "template.relationship-dialog",
        disableTypeSelection: false,

        augment$accept: function () {
            addRelationships(this.source, splitByCreditableAttributes(this.relationship()));
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
                addRelationships(this.source, relationships);
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
                    addRelationships(source, splitByCreditableAttributes(vm.getRelationship(model, source)));
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

        _(creditable).groupBy(linkAttributeTypeID).each(function (attributes) {
            var extra = _.rest(attributes);
            relationship.attributes.removeAll(extra);
            _.each(extra, split);
        });

        return relationships;
    }

}(MB.relationshipEditor = MB.relationshipEditor || {}));
