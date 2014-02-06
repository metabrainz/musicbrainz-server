// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2013 MetaBrainz Foundation
// Released under the GPLv2 license: http://www.gnu.org/licenses/gpl-2.0.txt

MB.Control.BubbleBase = aclass({

    // Organized by group, where only one bubble from each group can be
    // visible on the page at once.
    activeBubbles: {},

    // Whether the bubble should close when we click outside of it. Used for
    // track artist credit bubbles.
    closeWhenFocusIsLost: false,

    // The default observable equality comparer returns false if the values
    // aren't primitive, even if the values are equal.
    targetEqualityComparer: function (a, b) { return a === b },

    init: function (group) {
        this.group = group || 0;

        // this.target is the current viewModel that the bubble is pointing at.
        this.target = ko.observable(null);
        this.target.equalityComparer = this.targetEqualityComparer;

        this.visible = ko.observable(false);
    },

    show: function (control) {
        this.control = control;
        this.target(ko.dataFor(control));
        this.visible(true);

        var $control = $(control);

        if ($control.is(":button") && !this.$bubble.isTrapping()) {
            this.$bubble.trap();
        }

        var activeBubble = this.activeBubbles[this.group];

        if (activeBubble && activeBubble !== this) {
            activeBubble.hide(false);
        }
        this.activeBubbles[this.group] = this;
    },

    hide: function (stealFocus) {
        this.visible(false);
        this.target(null);

        var $control = $(this.control);
        this.control = null;

        if (stealFocus !== false && $control.is(":button")) {
            $control.focus();
        }

        var activeBubble = this.activeBubbles[this.group];

        if (activeBubble === this) {
            this.activeBubbles[this.group] = null;
        }
    },

    toggle: function (control) {
        if (this.visible.peek()) {
            this.hide();
        } else {
            this.show(control);
        }
    },

    canBeShown: function () {
        return true;
    },

    redraw: function () {
        if (this.visible.peek()) {
            // It's possible that the control we're pointing at has been
            // removed, hence why MutationObserver has triggered a redraw. If
            // that's the case, we want to hide the bubble, not show it.

            if ($(this.control).parents("html").length === 0) {
                this.hide(false);
            }
            else {
                this.show(this.control);
            }
        }
    },

    targetIs: function (data) {
        return this.target() === data;
    }
});


/* BubbleDoc turns a documentation div into a bubble pointing at an
   input to the left of it.
*/
MB.Control.BubbleDoc = aclass(MB.Control.BubbleBase, {

    after$show: function (control) {
        var $bubble = this.$bubble,
            $parent = $bubble.parent();

        $bubble
            .width($parent.width() - 24)
            .position({
                my: "left top-30",
                at: "right center",
                of: control,
                collision: "fit none",
                within: $parent
            })
            .addClass("left-tail");
    }
});


MB.Control.ArtistCreditBubbleBase = {

    removeArtistCreditName: function (name, event) {
        // Prevent track artist bubbles from closing.
        event.stopPropagation();

        var artistCredit = this.target();
        artistCredit.removeName(name);

        // Move focus to the previous remove icon
        this.$bubble.find("input.icon.remove-artist-credit:last").focus();
    },

    copyArtistCredit: function () {
        var names = this.target().toJSON();
        if (names.length === 0) names.push({});

        localStorage.copiedArtistCredit = JSON.stringify(names);
    },

    pasteArtistCredit: function () {
        var names = JSON.parse(localStorage.copiedArtistCredit || "[{}]");
        this.target().setNames(names);
    }
};


MB.Control.ArtistCreditBubbleDoc = aclass(MB.Control.BubbleDoc)
    .extend(MB.Control.ArtistCreditBubbleBase);


// Knockout's visible binding only toggles the display style between "none"
// and "". When it's an empty string, the display falls back to whatever
// overriding CSS rule is in place, which in our case is "display: none".
// This explicitly sets it to "block".

ko.bindingHandlers.show = {

    update: function (element, valueAccessor) {
        element.style.display = ko.unwrap(valueAccessor()) ? "block" : "none";
    }
};


ko.bindingHandlers.bubble = {

    init: function (element, valueAccessor, allBindingsAccessor,
                    viewModel, bindingContext) {

        var bubble = valueAccessor();
        element.bubbleDoc = bubble;
        bubble.$bubble = $(element);

        var childContext = bindingContext.createChildContext(viewModel);
        childContext.$bubble = bubble;

        ko.applyBindingsToNode(element,
            { show: bubble.visible, with: bubble.target }, childContext);
    }
};


ko.bindingHandlers.controlsBubble = {

    init: function (element, valueAccessor, allBindingsAccessor, viewModel) {
        var bubble = valueAccessor();

        element.bubbleDoc = bubble;
        viewModel["bubbleControl" + bubble.group] = element;

        // We may be here because a template was redrawn. Since the old control
        // we pointed at is gone, we have to update it to the new one.
        if (bubble.visible.peek() && bubble.targetIs(viewModel)) {
            bubble.control = element;
        }

        ko.computed({
            read: function () { return !!bubble.canBeShown(viewModel) },
            disposeWhenNodeIsRemoved: element
        })
        .subscribe(function (show) {
            if (show !== bubble.visible()) {
                bubble.toggle(element);
            }
            else if (show && !bubble.targetIs(viewModel)) {
                bubble.show(element);
            }
        });
    }
};


$(function () {

    // Handle click and focus events that might cause a bubble to be shown or
    // hidden. This event could be attached individually in controlsBubble, but
    // since there can be a lot of bubble controls on the page, event
    // delegation is better for performance.

    function bubbleHandler(event) {
        var control = event.target;
        var bubble = control.bubbleDoc;

        if (!bubble) {
            // If the user clicked outside of the active bubble, hide it.
            var $active = $("div.bubble:visible:eq(0)");

            if ($active.length && !$active.has(control).length) {
                bubble = $active[0].bubbleDoc;

                if (bubble.closeWhenFocusIsLost) {
                    bubble.hide(false);
                }
            }
            return;
        }

        var isButton = $(control).is(":button");
        var buttonClicked = isButton && event.type === "click";
        var inputFocused = !isButton && event.type === "focusin";
        var viewModel = ko.dataFor(control);

        // If this is false, the bubble should already be hidden. See the
        // computed in controlsBubble.
        if (bubble.canBeShown(viewModel)) {
            var wasOpen = bubble.visible() && bubble.targetIs(viewModel);

            if (buttonClicked && wasOpen) {
                bubble.hide();

            } else if (inputFocused || (buttonClicked && !wasOpen)) {
                bubble.show(control);

                if (buttonClicked) {
                    bubble.$bubble.find(":input:first").focus();
                }
            }
        }
        // Prevent the default action from occuring.
        return false;
    }

    $("body").on("click focusin", bubbleHandler);
});


// Helper function for use outside the release editor.
MB.Control.initializeBubble = function (bubble, control, vm, canBeShown) {
    vm = vm || {};

    var bubbleDoc = MB.Control.BubbleDoc();

    if (canBeShown) {
        bubbleDoc.canBeShown = canBeShown;
    }

    ko.applyBindingsToNode($(bubble)[0], { bubble: bubbleDoc }, vm);
    ko.applyBindingsToNode($(control)[0], { controlsBubble: bubbleDoc }, vm);
};
