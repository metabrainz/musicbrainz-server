// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2013 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

MB.Control.externalLinksEditor = function (options) {

    // Applies MB.Control.URLCleanup to an element containing a <select>
    // (for the link type) and a <input type="text"> (for the URL).

    ko.bindingHandlers.urlCleanup = {

        init: function (element, valueAccessor, allBindings, viewModel) {
            var $element = $(element);
            var $textInput = $element.find("input[type=text]");

            var cleanup = MB.Control.URLCleanup(
                options.entityType,
                $element.find("select"),
                $textInput,
                viewModel.errors,
                false // showErrors
            );

            $textInput.parent().append(cleanup.errorList);
            viewModel.cleanup = cleanup;

            viewModel.textChanged(viewModel.text());
            viewModel.linkTypeChanged(viewModel.linkType());
        }
    };


    var URL = aclass({

        init: function (data) {
            if (data.relationship_id) {
                this.relationship = data.relationship_id;
            }

            this.text = ko.observable(data.text || "");
            this.label = ko.observable("");
            this.linkType = ko.observable(data.link_type_id);
            this.matchesType = ko.observable(!!data.link_type_id);
            this.faviconClass = ko.observable("");
            this.errors = ko.observableArray([]);

            this.text.subscribe(this.textChanged, this);
            this.linkType.subscribe(this.linkTypeChanged, this);
        },

        textChanged: function (value) {
            if (this.errors().length === 0) {
                var key, class_, classes = options.faviconClasses;

                for (key in classes) {
                    if (value.indexOf(key) > 0) {
                        this.faviconClass(classes[key] + "-favicon");
                        return;
                    }
                }
            }
            this.faviconClass("");
            linksModel.ensureEmptyLinkExists();
        },

        linkTypeChanged: function (value) {
            var typeInfo = options.typeInfo[value];

            if (typeInfo) {
                this.label(typeInfo.phrase);

                if (typeInfo.deprecated == 1) {
                    this.cleanup.errors([ MB.text.RelationshipTypeDeprecated ]);
                }
            }
            linksModel.ensureEmptyLinkExists();
        },

        showTypeSelection: function () {
            return this.errors().length > 0 ||
                (!this.matchesType() && (this.text() || this.linkType()));
        },

        remove: function () {
            var linksArray = linksModel.links();
            var index = linksArray.indexOf(this);

            linksModel.links[this.relationship ? "destroy" : "remove"](this);

            var linkToFocus = linksArray[index] || linksArray[index - 1];

            if (linkToFocus) {
                linkToFocus.cleanup.urlControl.siblings("button.remove").focus();
            }
            else {
                $("#add-external-link").focus();
            }

            linksModel.ensureEmptyLinkExists();
        },

        isEmpty: function () {
            return !(this.linkType() || this.text());
        },

        isOnlyLink: function () {
            var links = linksModel.links();
            return links.length === 1 && links[0] === this;
        }
    });


    var linksModel = {

        links: ko.observableArray(_.map(options.relationships,
            function (relationship, index) {
                var link = URL(relationship);
                var errors = options.fieldErrors[index];

                if (errors) {
                    if (errors.link_type_id) {
                        link.errors.push(errors.link_type_id);
                    }
                    if (errors.text) {
                        link.errors.push(errors.text);
                    }
                }
                return link;
            })),

        hiddenInputs: function () {
            var fieldPrefix = options.formName + ".url";

            return _.flatten(_.map(this.links(), function (link, index) {
                var prefix = fieldPrefix + "." + index;
                var hidden = [];

                if (link.relationship) {
                    hidden.push({
                        name: prefix + ".relationship_id",
                        value: link.relationship
                    });
                }

                if (link._destroy) {
                    hidden.push({ name: prefix + ".removed", value: 1 });
                } else {
                    hidden.push({ name: prefix + ".text", value: link.text() });
                }

                hidden.push({ name: prefix + ".link_type_id", value: link.linkType() });
                return hidden;
            }));
        },

        ensureEmptyLinkExists: function () {
            var emptyLinkExists = _.any(this.links(), function (link) {
                return link.isEmpty();
            });

            if (!emptyLinkExists) {
                this.links.push(URL({}));
            }
        }
    };


    linksModel.ensureEmptyLinkExists();

    var containerNode = $("#external-links-editor")[0];

    ko.applyBindingsToNode(containerNode, { delegatedHandler: "click" }, linksModel);
    ko.applyBindings(linksModel, containerNode);


    linksModel.links(_.chain(linksModel.links())
        .sortBy(function (link) { return link.label().toLowerCase() })
        .sortBy(function (link) { return link.isEmpty() }).value());


    $(document)
        .on("mb.matchedLinkType", "select", function () {
            ko.dataFor(this).matchesType(true);
        })
        .on("mb.unknownLinkType", "select", function () {
            ko.dataFor(this).matchesType(false);
        });
};
