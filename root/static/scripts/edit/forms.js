// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2013 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

MB.forms = {

    buildOptionsTree: function (root, textAttr, valueAttr, callback, sortFunc) {
        var options = [];
        var nbsp = String.fromCharCode(160);

        function buildOptions(parent, indent) {
            var i = 0, children = parent.children, child;
            if (!children) { return; }

            if (callback) {
                while (child = children[i++]) {
                    callback(child);
                }
                i = 0;
            }

            if (sortFunc) {
                children = children.concat().sort(sortFunc);
            }

            while (child = children[i++]) {
                var opt = {};

                opt.value = child[valueAttr];
                opt.text = _.str.repeat(nbsp, indent * 2) + child[textAttr];
                opt.data = child;
                options.push(opt);

                buildOptions(child, indent + 1);
            }
        }

        buildOptions(root, 0);
        return options;
    },

    linkTypeOptions: function (root, backward) {
        var textAttr = (backward ? "reversePhrase" : "phrase") + "Clean";
        var attributeRegex = /\{(.*?)(?::(.*?))?\}/g;

        function mapNameToID(result, info, id) {
            result[info.attribute.name] = id;
        }

        function callback(data, option) {
            if (data[textAttr]) return;

            var phrase = backward ? data.reversePhrase : data.phrase;

            if (!_.isEmpty(MB.attrInfo)) {
                var attrIDs = _.transform(data.attributes, mapNameToID);

                // remove {foo} {bar} junk, unless it's for a required attribute.
                phrase = phrase.replace(attributeRegex, function (match, name, alt) {
                    var id = attrIDs[name];

                    if (data.attributes[id].min < 1) {
                        return (alt ? alt.split("|")[1] : "") || "";
                    }
                    return match;
                });
            }

            data[textAttr] = phrase;
        }

        function sortFunc(a, b) {
            return (a.childOrder - b.childOrder) || MB.i18n.compare(a[textAttr], b[textAttr]);
        }

        var options = MB.forms.buildOptionsTree(root, textAttr, "id", callback, sortFunc);

        for (var i = 0, len = options.length, option; i < len; i++) {
            if ((option = options[i]) && !option.data.description) {
                option.disabled = true;
            }
        }

        return options;
    },

    setDisabledOption: function (option, data) {
        if (data && data.disabled) {
            option.disabled = true;
        }
    }
};


ko.bindingHandlers.loop = {

    init: function (parentNode, valueAccessor, allBindings, viewModel, bindingContext) {
        var options = valueAccessor(), observableArray = options.items;

        // The way this binding handler works is by using the "arrayChange"
        // event found on observableArrays, which notifies a list of changes
        // we can apply to the UI.

        if (!ko.isObservable(observableArray) || !observableArray.cacheDiffForKnownOperation) {
            throw new Error("items must an an observableArray");
        }

        var idAttribute = options.id,
            elements = options.elements || {},
            template = [],
            node = parentNode.firstChild;

        while (node) {
            if (node.nodeType === Node.ELEMENT_NODE) {
                template.push(node);
            }
            node = node.nextSibling;
        }

        delete node;
        ko.utils.emptyDomNode(parentNode);

        function update(changes) {
            var activeElement = document.activeElement,
                items = observableArray.peek(),
                removals = [];

            for (var i = 0, change, j, node; change = changes[i]; i++) {
                var status = change.status;

                if (status === "retained") {
                    continue;
                }

                var item = change.value,
                    itemID = item[idAttribute],
                    currentElements = elements[itemID],
                    nextItem = items[change.index + 1];

                if (status === "added") {
                    if (change.moved === undefined) {
                        var newContext = bindingContext.createChildContext(item);

                        if (!currentElements) {
                            currentElements = [];
                            for (j = 0; node = template[j];  j++) {
                                currentElements.push(node.cloneNode(true));
                            }
                            elements[itemID] = currentElements;
                        }

                        for (j = 0; node = currentElements[j]; j++) {
                            if (!ko.contextFor(node)) {
                                ko.applyBindings(newContext, node);
                            }
                        }
                    }
                } else if (status === "deleted") {
                    if (change.moved === undefined) {
                        for (j = 0; node = currentElements[j]; j++) {
                            parentNode.removeChild(node);
                            removals.push({ node: node, itemID: itemID });
                        }
                    }
                    // When knockout detects a moved item, it sends both "added"
                    // and "deleted" changes for it. We only need to handle the
                    // former.
                    continue;
                }

                var elementsToInsert, elementsToInsertBefore, elementToInsertBefore;
                if (currentElements.length === 1) {
                    elementsToInsert = currentElements[0];
                } else {
                    elementsToInsert = document.createDocumentFragment();
                    for (j = 0; node = currentElements[j]; j++) {
                        elementsToInsert.appendChild(node);
                    }
                }

                if (nextItem && (elementsToInsertBefore = elements[nextItem[idAttribute]])
                             && (parentNode.contains(elementToInsertBefore = elementsToInsertBefore[0]))) {
                    parentNode.insertBefore(elementsToInsert, elementToInsertBefore);
                } else {
                    parentNode.appendChild(elementsToInsert);
                }
            }

            // Brief timeout in case a removed item gets re-added.
            setTimeout(function () {
                for (var i = 0, removal; removal = removals[i]; i++) {
                    if (!document.contains(removal.node)) {
                        ko.cleanNode(removal.node);
                        delete elements[removal.itemID];
                    }
                }
            }, 100);

            if (parentNode.contains(activeElement)) {
                activeElement.focus();
            }
        }

        var changeSubscription = observableArray.subscribe(update, null, "arrayChange");

        function nodeDisposal() {
            ko.utils.domNodeDisposal.removeDisposeCallback(parentNode, nodeDisposal);
            changeSubscription.dispose();
        }

        ko.utils.domNodeDisposal.addDisposeCallback(parentNode, nodeDisposal);

        update(_.map(observableArray.peek(), function (value, index) {
            return { status: "added", value: value, index: index };
        }));

        return { controlsDescendantBindings: true };
    }
};


/* Helper binding that matches an input and label (assuming a table layout)
   together in a foreach loop, by assigning an id composed of a prefix
   concatenated with the index of the item in the loop.

   So if you have something like this in the template:

    <!-- ko foreach: items -->
    <tr>
      <td><label>Foo</label></td>
      <td><input data-bind="withLabel: 'foo'" /></td>
    <tr>
    <!-- /ko -->

   It'll result in this markup once rendered (assuming two items):

    <tr>
      <td><label for="foo-0">Foo</label></td>
      <td><input id="foo-0" data-bind="withLabel: 'foo'" /></td>
    <tr>
    <tr>
      <td><label for="foo-1">Foo</label></td>
      <td><input id="foo-1" data-bind="withLabel: 'foo'" /></td>
    <tr>
*/
ko.bindingHandlers.withLabel = {

    update: function (element, valueAccessor, allBindings,
                      viewModel, bindingContext) {

        var name = valueAccessor() + "-" + bindingContext.$index();

        $(element).attr("id", name)
            .parents("td").prev("td").find("label").attr("for", name);
    }
};
