// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import $ from 'jquery';
import _ from 'lodash';
import ko from 'knockout';

import linkedEntities from '../../common/linkedEntities';
import clean from '../../common/utility/clean';
import deferFocus from '../../edit/utility/deferFocus';

    class Multiselect {

        constructor(params, $element) {
            this.$element = $element;
            this.$menu = $element.find("div.menu").data("multiselect", this);
            this.$items = $element.find("div.items");

            var self = this;

            this.$menu
                .on("keydown", $.proxy(this.menuKeydown, this))
                .on("click", "a", function (event) {
                    event.preventDefault();
                    self.select(event.target.optionData);
                });

            this.$items.on("click", "a", $.proxy(this.deselect, this));

            $element.find(".multiselect-input").on({
                "keydown": $.proxy(this.inputKeydown, this),
                "click": $.proxy(this.inputClick, this),
            });

            this.placeholder = params.placeholder || "";
            this.relationship = params.relationship;

            this.term = ko.observable("");
            this.term.subscribe(this.termChanged, this);
            this.inputHasFocus = ko.observable(false);

            this.menuVisible = ko.observable(false);
            this.menuVisible.subscribe(this.menuVisibleChanged, this);

            var options = params.options;
            var optionNodes = [];

            for (var i = 0, node, option; option = options[i]; i++) {
                node = document.createElement("a")
                node.href = "#";
                node.style.paddingLeft = option.depth + "em";
                node.appendChild(document.createTextNode(option.text));
                node.optionData = option;
                optionNodes.push(node);
            }

            this.selectedAttributes = ko.computed(function () {
                return _.filter(params.relationship.attributes(), function (attribute) {
                    return attribute.type.root === params.attribute;
                });
            });

            this.optionNodes = optionNodes.slice(0);
            this.$menu.empty().append(optionNodes);
            this.firstVisibleOption = ko.observable(this.optionNodes[0]);
        }

        termChanged(term) {
            term = clean(term);
            this.updateOptions(term);
            this.menuVisible(!!term);
        }

        menuVisibleChanged(visible) {
            if (visible) {
                this.$menu.css("top", this.$element.outerHeight() + "px");
            }
        }

        updateOptions(term) {
            var selected = this.relationship.attributes.peek();
            var self = this;
            var menu = this.$menu[0];

            var previousDisplay = menu.style.display;
            menu.style.display = "none";

            var optionNodes = _.filter(this.optionNodes, function (node) {
                var option = node.optionData;
                var typeGID = option.value;

                var visible = matchIndex(option, term) >= 0 && (
                    linkedEntities.link_attribute_type[typeGID].creditable ||
                    _.findIndex(selected, function (a) { return a.type.gid === typeGID }) < 0
                );

                node.style.display = visible ? "block" : "none";
                return visible;
            });

            menu.style.display = previousDisplay;
            this.firstVisibleOption(optionNodes[0]);
        }

        select(option) {
            this.relationship.addAttribute(option.value);
            this.menuVisible(false);
            this.term("");
            this.inputHasFocus(true);
            this.updateOptions("");
        }

        deselect(event) {
            event.preventDefault();

            var attribute = ko.dataFor(event.target);
            var typeGID = attribute.type.gid;

            this.relationship.attributes.remove(attribute);
            this.menuVisible(false);
            this.updateOptions(this.term.peek());

            var nodes = this.optionNodes, node;
            var nextIndex = _.findIndex(nodes, function (node) {
                return node.optionData.value === typeGID;
            });

            while (node = nodes[++nextIndex]) {
                if (node.style.display === "block") {
                    ++nextIndex;
                    break;
                }
            }
            --nextIndex;

            if (nextIndex >= 0) {
                deferFocus("a:eq(" + nextIndex + ")", this.$items);
            } else {
                this.inputHasFocus(true);
            }
        }

        inputClick(event) {
            this.menuVisible(!this.menuVisible());
            event.preventDefault();
        }

        inputKeydown(event) {
            var keyCode = event.keyCode;
            var menuVisible = this.menuVisibleWithOptions();

            switch (keyCode) {
                case 13: // enter
                    if (menuVisible) {
                        this.select(this.firstVisibleOption().optionData);
                        event.preventDefault();
                    }
                    break;
                case 27: // esc
                    if (menuVisible) {
                        this.menuVisible(false);
                        event.preventDefault();
                    }
                    break;
                case 40: // down arrow
                    if (menuVisible) {
                        this.firstVisibleOption().focus();
                        event.preventDefault();
                    }
                    else if (this.firstVisibleOption()) {
                        this.menuVisible(true);
                        event.preventDefault();
                    }
                    break;
            }
        }

        menuKeydown(event) {
            var keyCode = event.keyCode;
            var activeElement = document.activeElement;
            var menuItemActive = activeElement.parentNode === this.$menu[0];

            switch (keyCode) {
                case 27: // esc
                    if (this.menuVisibleWithOptions()) {
                        this.menuVisible(false);
                        event.preventDefault();
                        event.preventDefault();
                    }
                    break;
                case 38: // up arrow
                    if (menuItemActive) {
                        var nextItem = activeElement.previousSibling;

                        while (nextItem && nextItem.style.display === "none") {
                            nextItem = nextItem.previousSibling;
                        }

                        nextItem ? nextItem.focus() : this.inputHasFocus(true);
                        event.preventDefault();
                    }
                    break;
                case 40: // down arrow
                    if (menuItemActive) {
                        var nextItem = activeElement.nextSibling;

                        while (nextItem && nextItem.style.display === "none") {
                            nextItem = nextItem.nextSibling;
                        }

                        (nextItem || this.firstVisibleOption()).focus();
                        event.preventDefault();
                    }
                    break;
            }
        }

        menuVisibleWithOptions() {
            return this.menuVisible() && this.firstVisibleOption();
        }
    }

    function matchIndex(option, term) {
        return option.text.toLowerCase().indexOf(term.toLowerCase());
    }


    ko.components.register("multiselect", {
        viewModel: {
            createViewModel: function (params, componentInfo) {
                return new Multiselect(params, $(componentInfo.element));
            },
        },
        template: { fromScript: "template.multiselect" },
    });
