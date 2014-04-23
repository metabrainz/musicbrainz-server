// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

(function (externalLinks) {

    var RE = MB.relationshipEditor;


    externalLinks.Relationship = aclass(MB.entity.Relationship, {

        augment$init: function (data, source, parent) {
            this.linkTypeDescription = ko.observable("");
            this.faviconClass = ko.observable("");
            this.error = (parent.errorType || ko.observable)(data.error || "");
            this.removed = ko.observable(!!data.removed);
            this.removeButtonFocused = ko.observable(false);

            this.url = ko.observable(this.target(source).name);
            this.url.subscribe(this.urlChanged, this);
            this.linkTypeID.subscribe(this.linkTypeIDChanged, this);
        },

        around$linkPhrase: function (supr) {
            return supr(this.parent.source);
        },

        urlChanged: function (value) {
            var entities = this.entities().slice(0);
            var backward = this.parent.source === entities[1];

            entities[backward ? 0 : 1] = MB.entity.URL({ name: value });
            this.entities(entities);

            if (!this.error()) {
                var key, class_, classes = MB.faviconClasses;

                for (key in classes) {
                    if (value.indexOf(key) > 0) {
                        this.faviconClass(classes[key] + "-favicon");
                        return;
                    }
                }
            }
            this.faviconClass("");
            this.parent.ensureOneEmptyLinkExists(this);
        },

        linkTypeIDChanged: function (value) {
            var typeInfo = MB.typeInfoByID[value];

            if (typeInfo) {
                this.linkTypeDescription(
                    MB.i18n.expand(MB.text.MoreDocumentation, {
                        description: typeInfo.description,
                        url: "/relationship/" + typeInfo.gid
                    })
                );
            }
            else {
                this.linkTypeDescription("");
            }
            this.parent.ensureOneEmptyLinkExists(this);
        },

        matchesType: function () {
            var currentType = this.linkTypeID();

            var guessedType = this.cleanup.guessType(
                this.parent.source.entityType, this.url()
            );

            return currentType == guessedType;
        },

        showTypeSelection: function () {
            var hasError = !!this.error();
            var hasMatch = this.matchesType();
            var isEmpty = this.isEmpty();

            return hasError || !(hasMatch || isEmpty);
        },

        remove: function () {
            var linksArray = _.reject(this.parent.links(), function (link) {
                return link.removed() || link.isEmpty();
            });

            var index = linksArray.indexOf(this);

            if (this.id) {
                this.removed(true);

                // The original data won't be used, but the new data could
                // have errors that prevents everything from validating, so
                // we have to revert it.
                this.linkTypeID(this.original.linkTypeID);
                this.entities(this.original.entities.slice(0));
            }
            else {
                // this.cleanup is undefined for tests that don't deal with
                // markup (since it's set by the urlCleanup bindingHandler).
                this.cleanup && this.cleanup.toggleEvents("off");
                this.parent.source.relationships.remove(this);
            }

            // Clear errors so the form can be submitted (MBS-7340).
            this.error("");

            var linkToFocus = linksArray[index + 1] || linksArray[index - 1];

            if (linkToFocus) {
                linkToFocus.removeButtonFocused(true);
            }
            else {
                $("#add-external-link").focus();
            }
        },

        isEmpty: function () {
            return !(this.linkTypeID() || this.url());
        },

        isOnlyLink: function () {
            var links = this.parent.links();
            return links.length === 1 && links[0] === this;
        }
    });


    externalLinks.ViewModel = aclass(RE.ViewModel, {

        relationshipClass: externalLinks.Relationship,
        fieldName: "url",

        around$init: function (supr, options) {
            this.errorType = options.errorType;

            supr(options);

            this.ensureOneEmptyLinkExists();

            this.bubbleDoc = MB.Control.BubbleDoc("Information").extend({
                canBeShown: function (link) {
                    var url = link.url();

                    // Theoretically, if the URL isn't valid then the URLCleanup
                    // should've set an error. However, this callback runs before
                    // the URLCleanup code kicks in, so we need to check ourselves.
                    return (url && MB.utility.isValidURL(url) && !link.error()) ||
                            link.linkTypeDescription();
                }
            });
        },

        links: function () {
            return this.source.displayRelationships(this);
        },

        around$sortedRelationships: function (supr, relationships) {
            return _.sortBy(supr(relationships), linkIsEmpty);
        },

        typesAreAccepted: function (sourceType, targetType) {
            return sourceType === "url" || targetType === "url";
        },

        ensureOneEmptyLinkExists: function (activeLink) {
            var relationships = this.source.relationships;

            var emptyLinks = _.filter(
                this.links(), function (link) { return link.isEmpty() }
            );

            if (!emptyLinks.length) {
                var data = { target: MB.entity.URL({}) };

                relationships.push(this.getRelationship(data, this.source));
            }
            else if (emptyLinks.length > 1) {
                relationships.removeAll(_.without(emptyLinks, activeLink));
            }
        }
    });


    function linkIsEmpty(relationship) {
        return relationship.isEmpty();
    }


    externalLinks.applyBindings = function (options) {
        var containerNode = $("#external-links-editor")[0];
        var bubbleNode = $("#external-link-bubble")[0];
        var viewModel = this.ViewModel(options);

        ko.applyBindingsToNode(containerNode, {
            delegatedHandler: "click",
            affectsBubble: viewModel.bubbleDoc
        }, viewModel);

        ko.applyBindings(viewModel, containerNode);
        ko.applyBindingsToNode(bubbleNode, { bubble: viewModel.bubbleDoc }, viewModel);

        return viewModel;
    };

}(MB.Control.externalLinks = MB.Control.externalLinks || {}));


// Applies MB.Control.URLCleanup to an element containing a <select>
// (for the link type) and a <input type="text"> (for the URL).

ko.bindingHandlers.urlCleanup = {

    init: function (element, valueAccessor, allBindings, viewModel) {
        var $element = $(element);
        var $textInput = $element.find("input[type=text]");

        var cleanup = MB.Control.URLCleanup({
            sourceType:         valueAccessor(),
            typeControl:        $element.find("select"),
            urlControl:         $textInput,
            errorObservable:    viewModel.error,
            handleErrors:       false,
            typeInfoByID:       MB.typeInfoByID
        });

        viewModel.cleanup = cleanup;
        viewModel.urlChanged(viewModel.url());
        viewModel.linkTypeIDChanged(viewModel.linkTypeID());

        // Force validation on any initial data in the fields, i.e. when seeding.
        // The _.defer is because the knockout bindings haven't applied yet.
        _.defer(function () { $textInput.change() });
    }
};
