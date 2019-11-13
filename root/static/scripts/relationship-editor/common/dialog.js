// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import $ from 'jquery';
import ko from 'knockout';
import _ from 'lodash';
import ReactDOMServer from 'react-dom/server';

import '../../../lib/jquery-ui';

import {ENTITY_NAMES, PART_OF_SERIES_LINK_TYPES}
    from '../../common/constants';
import {compare} from '../../common/i18n';
import expand2react from '../../common/i18n/expand2react';
import linkedEntities from '../../common/linkedEntities';
import MB from '../../common/MB';
import * as URLCleanup from '../../edit/URLCleanup';
import * as dates from '../../edit/utility/dates';
import {stripAttributes} from '../../edit/utility/linkPhrase';
import isBlank from '../../common/utility/isBlank';
import debounce from '../../common/utility/debounce';

const PART_OF_SERIES_LINK_TYPE_GIDS = _.values(PART_OF_SERIES_LINK_TYPES);

const RE = MB.relationshipEditor = MB.relationshipEditor || {};

    var UI = RE.UI = RE.UI || {};
    var fields = RE.fields = RE.fields || {};

    var incorrectEntityForSeries = {
        recording:      l("The series you’ve selected is for recordings."),
        release:        l("The series you’ve selected is for releases."),
        release_group:  l("The series you’ve selected is for release groups."),
        work:           l("The series you’ve selected is for works."),
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

                dialog.autocomplete = $(element).entitylookup({
                        entity: dialog.targetType(),

                        setEntity: function (type) {
                            if (dialog.disableTypeSelection) {
                                return false;
                            }

                            var possible = dialog.targetTypeOptions();

                            if (!_.find(possible, {value: type})) {
                                return false;
                            }

                            dialog.targetType(type);
                        },

                        resultHook: function (items) {
                            if (dialog.autocomplete.entity === "series" &&
                                    dialog.relationship().getLinkType().orderable_direction !== 0) {
                                return _.filter(items, function (item) {
                                    return item.type.item_entity_type === dialog.source.entityType;
                                });
                            }
                            return items;
                        },
                    }).data("mb-entitylookup");

                dialog.autocomplete.currentSelection.subscribe(changeTarget);

                var target = dialog.relationship().target(dialog.source);

                if (dialog instanceof UI.EditDialog) {
                    dialog.autocomplete.currentSelection(target);
                } else {
                    // Fills in the recording name in the add-related-work dialog.
                    dialog.autocomplete.currentSelection({name: target.name});
                }
            },
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
                if (attribute.type.root_id == 14) {
                    addInstrument(MB.entity(attribute.type, "instrument"), attribute);
                }
            });

            if (!instruments.peek().length) {
                addInstrument(new MB.entity.Instrument({}));
            }

            var vm = {
                instruments: instruments,

                addItem: function () {
                    addInstrument(new MB.entity.Instrument({}));
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
                },
            };

            var childBindingContext = bindingContext.createChildContext(vm);
            ko.applyBindingsToDescendants(childBindingContext, element);

            return {controlsDescendantBindings: true};
        },
    };


    class Dialog {

        constructor(options) {
            var self = this;

            this.viewModel = options.viewModel;

            var source = options.source;
            var target = options.target;

            if (options.relationship) {
                target = options.relationship.target(source);
            } else {
                options.relationship = this.viewModel.getRelationship({
                    target: target, direction: options.direction,
                }, source);

                options.relationship.linkTypeID(
                    defaultLinkType({children: linkedEntities.link_type_tree[options.relationship.entityTypes]}),
                );
            }

            this.relationship = ko.observable(options.relationship);
            this.source = source;

            this.targetType = ko.observable(target.entityType);
            this.targetType.subscribe(this.targetTypeChanged, this);

            this.changeOtherRelationshipCredits = {source: ko.observable(false), target: ko.observable(false)};
            this.selectedRelationshipCredits = {source: ko.observable('all'), target: ko.observable('all')};

            function tooShortYear(date) {
                const valid = dates.isYearFourDigits(date.year());
                return valid ? '' : l('The year should have four digits. If you want to enter a year earlier than 1000 CE, please pad with zeros, such as “0123”.');
            }

            this.tooShortBeginYearError = debounce(function () {
                const relationship = self.relationship();
                return tooShortYear(relationship.begin_date);
            });

            this.tooShortEndYearError = debounce(function () {
                const relationship = self.relationship();
                return tooShortYear(relationship.end_date);
            });

            this.setupUI();
        }

        open(positionBy) {
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
        }

        accept() {
            if (!this.hasErrors()) {
                if (this._accept) {
                    this._accept.apply(this, arguments);
                }
                for (var role in this.changeOtherRelationshipCredits) {
                    if (this.changeOtherRelationshipCredits[role]()) {
                        var vm = this.viewModel;
                        var relationship = this.relationship();
                        var target = role === 'source' ? this.source : relationship.target(this.source);
                        var targetCredit = relationship.creditField(target)();
                        var relationshipFilter = this.selectedRelationshipCredits[role]();

                        // XXX HACK XXX
                        // MB.entityCache isn't supposed to be exposed outside of
                        // whatever module it's defined in, but there's no easier
                        // way to iterate over all entities on the page.

                        _.each(MB.entityCache, function (entity, gid) {
                            if (gid === target.gid) {
                                _.each(entity.displayableRelationships(vm)(), function (r) {
                                    switch (relationshipFilter) {
                                      case 'same-entity-types': if (r.entityTypes !== relationship.entityTypes) { return; } break;
                                      case 'same-relationship-type': if (r.linkTypeID() !== relationship.linkTypeID()) { return; } break;
                                    }

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
                }

                this.close(false);
            }
        }

        close() {
            this.viewModel.activeDialog(null);
            this.widget && this.widget.close();
        }

        clickEvent(data, event) {
            if (!event.isDefaultPrevented()) {
                var $menu = this.$dialog.find(".menu");

                if ($menu.length) {
                    $menu.data("multiselect").menuVisible(false);
                }
            }

            return true;
        }

        keydownEvent(data, event) {
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
        }

        toggleAttributesHelp() {
            this.showAttributesHelp(!this.showAttributesHelp());
        }

        changeDirection() {
            var relationship = this.relationship.peek();
            relationship.entities(relationship.entities().slice(0).reverse());
        }

        backward() {
            return this.source === this.relationship().entities()[1];
        }

        toggleLinkTypeHelp() {
            this.showLinkTypeHelp(!this.showLinkTypeHelp.peek());
        }

        linkTypeName() {
            var linkType = this.relationship().getLinkType();
            if (!linkType) {
                return '';
            }
            return stripAttributes(
                linkType,
                l_relationships(
                  this.backward()
                    ? linkType.reverse_link_phrase
                    : linkType.link_phrase,
                ),
            );
        }

        linkTypeDescription() {
            var linkType = this.relationship().getLinkType();
            var description;

            if (linkType && linkType.description) {
                description = ReactDOMServer.renderToStaticMarkup(
                    exp.l("{description} ({url|more documentation})", {
                        description: expand2react(l_relationships(linkType.description)),
                        url: {href: "/relationship/" + linkType.gid, target: "_blank"},
                    }),
                );
            }

            return description || "";
        }

        positionBy(element) {
            this.widget._setOption("position", {
                my: "top center", at: "center", of: element,
            });
        }

        linkTypeOptions(entityTypes) {
            var options = MB.forms.linkTypeOptions(
                {children: linkedEntities.link_type_tree[entityTypes]}, this.backward(),
            );

            if (this.source.entityType === "series") {
                var itemType = MB.seriesTypesByID[this.source.typeID()].item_entity_type;

                options = _.reject(options, function (opt) {
                    var linkType = linkedEntities.link_type[opt.value];

                    if (_.includes(PART_OF_SERIES_LINK_TYPE_GIDS, linkType.gid) &&
                            linkType.gid !== PART_OF_SERIES_LINK_TYPES[itemType]) {
                        return true;
                    }
                });
            }

            return options;
        }

        targetTypeOptions() {
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
                return {value: type, text: ENTITY_NAMES[type]()};
            });

            options.sort(function (a, b) {
                return compare(a.text, b.text);
            });

            return options;
        }

        targetTypeChanged(newType) {
            if (!newType) return;

            var currentRelationship = this.relationship();
            var currentTarget = currentRelationship.target(this.source);

            var data = currentRelationship.editData();
            data.target = MB.entity({name: currentTarget.name}, newType);

            // Always keep any existing dates, even if the new relationship
            // doesn't support them. If they're not supported they'll be
            // hidden/ignored anyway, but if the user changes the target type
            // or link type again (to something that does support them), we
            // want to preserve what they previously entered.
            data.begin_date = MB.edit.fields.partialDate(currentRelationship.begin_date);
            data.end_date = MB.edit.fields.partialDate(currentRelationship.end_date);
            data.ended = !!currentRelationship.ended();

            delete data.entities;

            var entityTypes = [this.source.entityType, newType].sort().join("-");
            data.linkTypeID = defaultLinkType({children: linkedEntities.link_type_tree[entityTypes]});
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
        }

        linkTypeError() {
            var linkType = this.relationship().getLinkType();

            if (!linkType) {
                return l("Please select a relationship type.");
            } else if (!linkType.description) {
                return l("Please select a subtype of the currently selected relationship type. The selected relationship type is only used for grouping subtypes.");
            } else if (linkType.deprecated) {
                return l("This relationship type is deprecated and should not be used.");
            } else if (this.source.entityType === "url") {
                var checker = URLCleanup.validationRules[linkType.gid];

                if (checker && !checker(this.source.name())) {
                    return l("This URL is not allowed for the selected link type, or is incorrectly formatted.");
                }
            }

            return "";
        }

        targetEntityError() {
            var relationship = this.relationship();
            var target = relationship.target(this.source);
            var linkType = relationship.getLinkType() || {};

            if (!target.gid) {
                return l("Required field.");
            } else if (this.source === target) {
                return l("Entities in a relationship cannot be the same.");
            }

            if (target.entityType === "series" &&
                    _.includes(PART_OF_SERIES_LINK_TYPE_GIDS, linkType.gid) &&
                    target.type().entityType !== this.source.entityType) {
                return incorrectEntityForSeries[target.type().entityType];
            }

            return "";
        }

        dateError(date) {
            var valid = dates.isDateValid(date.year(), date.month(), date.day());
            return valid ? "" : l("The date you've entered is not valid.");
        }

        datePeriodError() {
            var relationship = this.relationship();

            var a = relationship.begin_date;
            var b = relationship.end_date;

            if (!this.dateError(a) && !this.dateError(b)) {
                if (!dates.isDatePeriodValid(ko.toJS(a), ko.toJS(b))) {
                    return l("The end date cannot precede the begin date.");
                }
            }

            return "";
        }

        hasErrors() {
            var relationship = this.relationship();

            return this.linkTypeError() ||
                   this.targetEntityError() ||
                   _(relationship.getLinkType().attributes)
                     .values().map(_.bind(relationship.attributeError, relationship)).some() ||
                   this.dateError(relationship.begin_date) ||
                   this.dateError(relationship.end_date) ||
                   this.tooShortBeginYearError() ||
                   this.tooShortEndYearError() ||
                   this.datePeriodError();
        }

        changeOtherRelationshipCreditsLabel(entity) {
            return ReactDOMServer.renderToStaticMarkup(
                exp.l('Change credits for other {entity} relationships on the page.', {entity: entity.reactElement()}),
            );
        }

        sameEntityTypesLabel($parent, relationship, entity) {
            const entityType = relationship.target(entity).entityType;
            return texp.l('Only relationships to {entity_type} entities.', {
                entity_type: ENTITY_NAMES[entityType](),
            });
        }

        sameRelationshipTypeLabel($parent, relationship, entity) {
            const entityType = relationship.target(entity).entityType;
            return texp.l('Only “{relationship_type}” relationships to {entity_type} entities.', {
                relationship_type: $parent.linkTypeName(),
                entity_type: ENTITY_NAMES[entityType](),
            });
        }
    }

    Object.assign(Dialog.prototype, {
        loading: ko.observable(false),
        showAttributesHelp: ko.observable(false),
        showLinkTypeHelp: ko.observable(false),

        uiOptions: {
            dialogClass: "rel-editor-dialog",
            draggable: false,
            resizable: false,
            autoOpen: false,
            width: "auto",
        },

        setupUI: _.once(function () {
            var $dialog = $("#dialog").dialog(this.uiOptions);

            var widget = $dialog.data("ui-dialog");
            widget.uiDialog.find(".ui-dialog-titlebar").remove();

            Object.assign(Dialog.prototype, {$dialog, widget});
            ko.applyBindings(this.viewModel, $dialog[0]);
        }),
    });

    function addRelationships(relationships, source, viewModel) {
        _.each(relationships, function (relationship) {
            if (source.mergeRelationship(relationship)) {
                return;
            }

            if (relationship.getLinkType().orderable_direction) {
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

    export class AddDialog extends Dialog {

        _accept() {
            addRelationships(splitByCreditableAttributes(this.relationship()), this.source, this.viewModel);
        }

        close(cancel) {
            if (cancel !== false) {
                this.relationship().remove();
            }
            super.close(cancel);
        }
    }

    Object.assign(AddDialog.prototype, {
        dialogTemplate: "template.relationship-dialog",
        disableTypeSelection: false,
    });

    export class EditDialog extends Dialog {

        constructor(options) {
            // originalRelationship is a copy of the relationship when the dialog
            // was opened, i.e. before the user edits it. if they cancel the
            // dialog, this is what gets copied back to revert their changes.
            const relationship = options.relationship;
            options.relationship = relationship.clone();
            super(options);
            this.originalRelationship = relationship.editData();
            this.editing = relationship;
        }

        _accept() {
            var relationships = splitByCreditableAttributes(this.relationship()),
                relationship = relationships.shift();

            this.editing.fromJS(relationship.editData());

            if (relationships.length) {
                addRelationships(relationships, this.source, this.viewModel);
            }
        }

        close(cancel) {
            if (cancel !== false) {
                var relationship = this.relationship();

                if (!_.isEqual(this.originalRelationship, relationship.editData())) {
                    relationship.fromJS(this.originalRelationship);
                }
            }
            super.close(cancel);
        }
    }

    Object.assign(EditDialog.prototype, {
        dialogTemplate: "template.relationship-dialog",
        disableTypeSelection: true,
    });

    export class BatchRelationshipDialog extends Dialog {

        constructor(options) {
            options.source = MB.entity({}, options.sources[0].entityType);
            options.target = options.target || new MB.entity.Artist({});

            super(options);

            this.sources = options.sources;
        }

        _accept(callback) {
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
    }

    Object.assign(BatchRelationshipDialog.prototype, {
        dialogTemplate: "template.batch-relationship-dialog",
        disableTypeSelection: false,
    });

    export class BatchCreateWorksDialog extends BatchRelationshipDialog {

        constructor(options) {
            super(Object.assign(options, {target: new MB.entity.Work({})}));
            this.error = ko.observable(false);
        }

        accept() {
            var workType = this.workType(),
                workLang = this.workLanguage();

            this.loading(true);

            var edits = _.map(this.sources, function (source) {
                var editData = MB.edit.fields.work({
                    name: source.name,
                    typeID: workType,
                    languages: isBlank(workLang) ? [] : [workLang],
                });

                return MB.edit.workCreate(editData);
            });

            this.createEdits(edits)
                .done((data) => {
                    var works = _.map(data.edits, "entity");

                    super.accept(function (relationshipData) {
                        relationshipData.target = MB.entity(works.shift(), "work");
                        return true;
                    });

                    this.loading(false);
                })
                .fail(() => {
                    this.loading(false);
                    this.error(true);
                });
        }

        createEdits(edits) {
            return MB.edit.create({editNote: "", makeVotable: false, edits: edits});
        }

        targetEntityError() { return "" }
    }

    Object.assign(BatchCreateWorksDialog.prototype, {
        dialogTemplate: "template.batch-create-works-dialog",
        workType: ko.observable(null),
        workLanguage: ko.observable(null),
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
                var extra = _.tail(attributes);
                relationship.attributes.removeAll(extra);
                _.each(extra, split);
            });

        return relationships;
    }

    UI.AddDialog = AddDialog;
    UI.EditDialog = EditDialog;
    UI.BatchRelationshipDialog = BatchRelationshipDialog;
    UI.BatchCreateWorksDialog = BatchCreateWorksDialog;
