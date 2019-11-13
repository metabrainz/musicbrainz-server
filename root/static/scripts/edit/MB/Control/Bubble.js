// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2013 MetaBrainz Foundation
// Released under the GPLv2 license: http://www.gnu.org/licenses/gpl-2.0.txt

import $ from 'jquery';
import _ from 'lodash';
import ko from 'knockout';

import MB from '../../../common/MB';
import deferFocus from '../../utility/deferFocus';

class BubbleBase {

    // The default observable equality comparer returns false if the values
    // aren't primitive, even if the values are equal.
    targetEqualityComparer(a, b) { return a === b }

    constructor(group) {
        this.group = group || 0;

        // this.target is the current viewModel that the bubble is pointing at.
        this.target = ko.observable(null);
        this.target.equalityComparer = this.targetEqualityComparer;

        this.visible = ko.observable(false);
    }

    show(control, stealFocus) {
        this.control = control;
        this.target(ko.dataFor(control));
        this.visible(true);

        var $bubble = this.$bubble;

        if (stealFocus !== false && $(control).is(":button")) {
            deferFocus(":input:first", $bubble);
        }

        var activeBubble = this.activeBubbles[this.group];

        if (activeBubble && activeBubble !== this) {
            activeBubble.hide(false);
        }
        this.activeBubbles[this.group] = this;

        _.defer(function () {
            $bubble.find("a").attr("target", "_blank");
        });
    }

    hide(stealFocus) {
        this.visible(false);

        var $control = $(this.control);
        this.control = null;

        if (stealFocus !== false && $control.is(":button")) {
            $control.focus();
        }

        var activeBubble = this.activeBubbles[this.group];

        if (activeBubble === this) {
            this.activeBubbles[this.group] = null;
        }
    }

    // Action upon pressing enter in an input. Defaults to hide.
    submit() { this.hide() }

    toggle(control) {
        if (this.visible.peek()) {
            this.hide();
        } else {
            this.show(control);
        }
    }

    canBeShown() {
        return true;
    }

    redraw(stealFocus) {
        if (this.visible.peek()) {
            // It's possible that the control we're pointing at has been
            // removed, hence why MutationObserver has triggered a redraw. If
            // that's the case, we want to hide the bubble, not show it.

            if ($(this.control).parents("html").length === 0) {
                this.hide(false);
            }
            else {
                this.show(this.control, !!stealFocus, true /* isRedraw */);
            }
        }
    }

    targetIs(data) {
        return this.target() === data;
    }
}

// Organized by group, where only one bubble from each group can be
// visible on the page at once.
BubbleBase.prototype.activeBubbles = {};

// Whether the bubble should close when we click outside of it. Used for
// track artist credit bubbles.
BubbleBase.prototype.closeWhenFocusIsLost = false;

/* BubbleDoc turns a documentation div into a bubble pointing at an
   input to the left of it.
*/
class BubbleDoc extends BubbleBase {

    show(control) {
        super.show(control);

        var $bubble = this.$bubble,
            $parent = $bubble.parent();

        $bubble
            .width($parent.width() - 24)
            .position({
                my: "left top-30",
                at: "right center",
                of: control,
                collision: "fit none",
                within: $parent,
            })
            .addClass("left-tail");
    }
}

MB.Control.BubbleDoc = BubbleDoc;

// Knockout's visible binding only toggles the display style between "none"
// and "". When it's an empty string, the display falls back to whatever
// overriding CSS rule is in place, which in our case is "display: none".
// This explicitly sets it to "block".

ko.bindingHandlers.show = {

    update: function (element, valueAccessor) {
        element.style.display = ko.unwrap(valueAccessor()) ? "block" : "none";
    },
};


ko.bindingHandlers.bubble = {

    init: function (element, valueAccessor, allBindingsAccessor,
                    viewModel, bindingContext) {

        var bubble = valueAccessor();
        element.bubbleDoc = bubble;
        bubble.$bubble = $(element);

        var childContext = bindingContext.createChildContext(bubble);

        ko.applyBindingsToNode(element, {show: bubble.visible}, childContext);
        ko.applyBindingsToDescendants(childContext, element);

        return {controlsDescendantBindings: true};
    },
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
            disposeWhenNodeIsRemoved: element,
        })
        .subscribe(function (show) {
            if (show !== bubble.visible()) {
                bubble.toggle(element);
            }
            else if (show && !bubble.targetIs(viewModel)) {
                bubble.show(element);
            }
        });
    },
};


// Used to watch for DOM changes, so that doc bubbles stay pointed at the
// correct position.
//
// See https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver
// for browser support.

ko.bindingHandlers.affectsBubble = {

    init: function (element, valueAccessor) {
        if (!window.MutationObserver) {
            return;
        }

        var observer = new MutationObserver(_.throttle(function () {
            _.delay(function () { valueAccessor().redraw() }, 100);
        }, 100));

        observer.observe(element, {childList: true, subtree: true});

        ko.utils.domNodeDisposal.addDisposeCallback(element, function () {
            observer.disconnect();
        });
    },
};


// Handle click and focus events that might cause a bubble to be shown or
// hidden. This event could be attached individually in controlsBubble, but
// since there can be a lot of bubble controls on the page, event
// delegation is better for performance.

function bubbleControlHandler(event) {
    var control = event.target;
    var bubble = control.bubbleDoc;

    if (!bubble) {
        // If the user clicked outside of the active bubble, hide it.
        var $active = $("div.bubble:visible:eq(0)");

        if ($active.length && !$active.has(control).length) {
            bubble = $active[0].bubbleDoc;

            if (bubble && bubble.closeWhenFocusIsLost &&
                !event.isDefaultPrevented() &&

                // Close unless focus was moved to a dialog above this
                // one, i.e. when adding a new entity.
                !$(event.target).parents(".ui-dialog").length) {

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
        }
    }
    // Prevent the default action from occuring.
    return false;
}


// Pressing enter should close the bubble or perform a custom action (i.e.
// going to the next track). Pressing escape should always close it.

function bubbleKeydownHandler(event) {
    if (event.isDefaultPrevented()) {
        return;
    }

    var $target = $(event.target);
    var $bubble = $target.parents("div.bubble");
    var bubbleDoc = $bubble[0].bubbleDoc;

    if (!bubbleDoc) {
        return;
    }

    var pressedEsc = event.which === 27;
    var pressedEnter = event.which === 13;

    if (pressedEsc || (pressedEnter && $target.is(":not(:button)"))) {
        event.preventDefault();

        // This causes any "value" binding on the input to update its
        // associated observable. e.g. if the user types something in a
        // join phrase field and hits esc., the join phrase in the view
        // model should update. This should run before the code below,
        // because the view model for the bubble may change.
        $target.trigger("change");

        if (pressedEsc) {
            bubbleDoc.hide();
        }
        else if (pressedEnter) {
            bubbleDoc.submit();
        }
    }
}

$("body")
    .on("click focusin", bubbleControlHandler)
    .on("keydown", "div.bubble :input", bubbleKeydownHandler);


// Helper function for use outside the release editor.
MB.Control.initializeBubble = function (bubble, control, vm, canBeShown) {
    vm = vm || {};

    var bubbleDoc = new BubbleDoc();

    if (canBeShown) {
        bubbleDoc.canBeShown = canBeShown;
    }

    ko.applyBindingsToNode($(bubble)[0], {bubble: bubbleDoc}, vm);
    ko.applyBindingsToNode($(control)[0], {controlsBubble: bubbleDoc}, vm);

    return bubbleDoc;
};

export const initializeBubble = MB.Control.initializeBubble;
