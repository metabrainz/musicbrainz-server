/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2012 MetaBrainz Foundation

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

$(function() {

var activeSelect = null, cache = {}, canRemoveItems = true;

function killEvent(event) {
    event.stopPropagation();
    event.preventDefault();
}

function moveCursor(event) {
    if (activeSelect === null) return;

    var activeItem = activeSelect.activeItem(),
        activeOption = activeSelect.activeOption(), nextItem, eq = 0;

    switch (event.keyCode) {
        case 27: // esc
            activeSelect.hide();
            activeSelect.search.focus();
            break;
        case 33: // page up
            eq = 10;
        case 38: // up
            if (activeItem) {
                var prev = activeSelect.prev(activeItem);
                prev && prev.focus();

            } else if (activeOption) {
                var prev = activeSelect.prev(activeOption, eq);
                prev ? activeSelect.activateOption(prev): activeSelect.search.focus();
            }
            break;
        case 34: // page down
            eq = 10;
        case 9: // tab
            if (activeItem)
                nextItem = activeSelect.next(activeItem);

            if (event.keyCode == 9 && !activeOption && !nextItem) {
                if (activeSelect.menu.style.display == "none" && !activeItem)
                    activeSelect = null;
                return;
            }
        case 40: // down
            nextItem = nextItem || activeSelect.next(activeItem);

            if (activeItem) {
                nextItem ? nextItem.focus() : activeSelect.search.focus();

            } else if (activeOption) {
                var nextOption = activeSelect.next(activeOption, eq);
                nextOption && activeSelect.activateOption(nextOption);
            }
            break;
    }

    switch (event.keyCode) {
        case 9: // tab
        case 27: // esc
        case 33: // page up
        case 34: // page down
        case 38: // up
        case 40: // down
            killEvent(event);
    }
}

$("body")
    .on("keydown", moveCursor)
    .on("click", function() {

        if (activeSelect) {
            activeSelect.hide();
            activeSelect = null;
        }
    })
    .on("click", "div.multiselect > div.menu > a", function(event) {
        killEvent(event);
        // XXX figure out why hitting the enter key on invisible menu options gets us here
        if (this.style.display == "none") return;
        activeSelect.select(this);
    })
    .on("mouseenter", "div.multiselect > div.menu > a", function(event) {
        var menu = this.parentNode;

        if (activeSelect && activeSelect.menu === menu) {

            if (activeSelect.hoverOption)
                activeSelect.hoverOption.className = "";

            this.className = "hover";
            activeSelect.hoverOption = this;
        }
    })
    .on("keydown", function(event) {
        if (event.isPropagationStopped()) return;
        if (activeSelect === null) return;

        var activeOption = activeSelect.activeOption();

        if (event.keyCode == 13) { // enter
            var activeItem = activeSelect.activeItem();

            if (activeItem) {
                canRemoveItems && activeItem.click();

            } else if (activeOption) {
                activeSelect.select(activeOption);

            } else return;
             killEvent(event);
        } else {
            activeOption && activeSelect.search.focus();
        }
    });

// opera incorrectly fires keypress events for special keys (in *addition* to
// keydown events), against the spec. these need to be killed so that their
// default action doesn't occur. (this is fixed in 12.10 and above.)
// http://www.quirksmode.org/dom/events/keys.html

$(document).on("keypress", function(event) {
    if (activeSelect)
        switch (event.keyCode) {
            case 9: // tab
            case 27: // esc
            case 33: // page up
            case 34: // page down
            case 38: // up
            case 40: // down
            case 13: // enter
                killEvent(event);
                return false;
        }
    return true;
});

var multiselect = function(input, placeholder, cacheKey) {
    var self = this, inputFired = false, lastTerm = "";
    this.hoverOption = null;
    this.values = $(input).val() || [];
    this.term = "";

    this.input = input;
    input.style.display = "none";

    this.container = document.createElement("div");
    this.container.className = "multiselect";

    this.menu = document.createElement("div");
    this.menu.className = "menu";
    this.menu.style.display = "none";

    this.search = document.createElement("input");
    this.search.setAttribute("placeholder", placeholder);

    this.items = document.createElement("div");
    this.items.className = "items";

    this.selectedOptions = [];
    this.buildOptions(cacheKey);

    $(this.search).on("click", function(event) {
        killEvent(event);

        if (self.menu.style.display != "none") {
            self.hide();
        } else {
            self.show();
            var activeOption = self.activeOption() || self.firstOption();
            activeOption ? self.activateOption(activeOption) : self.hide();
        }
    })
    .on("keydown", function(event) {
        if (event.keyCode == 13) { // enter
            if (self.hoverOption) {
                self.select(self.hoverOption);
                killEvent(event);
            }
        } else if (event.keyCode == 38) { // up
            // opera skips these when tabbing, so focus them explicitly.
            if (!self.activeOption() && self.items.lastChild) {
                self.hide();
                self.items.lastChild.focus();
                killEvent(event);
            }
        } else if (event.keyCode == 40) { // down
            self.show();

            // in self.show() we use a timeout of 0 to work around a chrome bug.
            // self.activateOption() must run after setting the scrollTop,
            // otherwise the page will jump after setting focus.
            setTimeout(function() {
                var option = self.activeOption() || self.firstOption();
                option ? self.activateOption(option) : self.hide();
            }, 1);

            killEvent(event);
        }
    })
    .on("input", function(event) {
        self.lookup(this.value);
        inputFired = true;
        lastTerm = this.value;
    })
    // IE9 doesn't fire input for backspace, etc. IE8 doesn't support input.
    .on("keyup", function() {
        if (!inputFired && lastTerm != this.value)
            $(this).trigger("input");
        inputFired = false;
    });

    this.container.appendChild(this.items);
    this.container.appendChild(this.search);
    this.container.appendChild(this.menu);
    input.parentNode.insertBefore(this.container, input.nextSibling);

    if (this.values) {
        $(this.options)
            .filter(function() {
                return self.values.indexOf(this.getAttribute("data-value")) > -1;
            })
            .each(function() {
                this.style.display = "none";
                self.select(this);
            });
    }
};

multiselect.prototype.activeItem = function() {
    return this.items.querySelectorAll("a:focus")[0];
};

multiselect.prototype.activeOption = function() {
    var opt = this.menu.querySelectorAll("a:focus")[0];
    return opt && (opt.style.display != "none" ? opt : undefined);
};

// these are optimized methods - they can be done in one line with jQuery, but
// make a difference in slower browsers.

multiselect.prototype.firstOption = function() {
    var opt = this.menu.firstChild;
    while (opt) {
        if (opt.style.display != "none")
            return opt;
        opt = opt.nextSibling;
    }
    return undefined;
};

multiselect.prototype.prev = function(a, skip) {
    skip = skip || 0;
    var i = 0;
    while (a) {
        if (i++ > skip && a.style.display != "none") return a;
        a = a.previousSibling;
    }
};

multiselect.prototype.next = function(a, skip) {
    skip = skip || 0;
    var i = 0;
    while (a) {
        if (i++ > skip && a.style.display != "none") return a;
        a = a.nextSibling;
    }
};

multiselect.prototype.activateOption = function(option, focus) {
    if (!option) return;
    if (focus !== false) option.focus();
    if (option === this.hoverOption) return;

    this.hoverOption && (this.hoverOption.className = "");
    this.hoverOption = option;
    option.className = "hover";
};

multiselect.prototype.select = function(option) {
    var self = this, value = option.getAttribute("data-value");
    option.style.display = "none";

    if (this.values.indexOf(value) === -1) {
        this.values.push(value);
        $(this.input).val(this.values).change();
    }
    this.selectedOptions.push(option);

    var item = document.createElement("a");
    item.href = "#";
    item.innerHTML = "&#215; " + $.trim(option.textContent || option.innerText);

    $(item).on("click", function(event) {
        killEvent(event);
        canRemoveItems = false;
        self.hide();
        item.focus();

        var value = option.getAttribute("data-value"),
            index = self.values.indexOf(value), next;

        if (index > -1) self.values.splice(index, 1);
        $(self.input).val(self.values).change();

        next = self.next(item) || self.prev(item);
        next ? next.focus() : (self.hide() || self.search.focus());

        index = self.selectedOptions.indexOf(option);
        if (index > -1) self.selectedOptions.splice(index, 1);
        if (self.matchesTerm(option)) option.style.display = "block";

        $(item).slideUp(100, function() {
            self.items.removeChild(item);
            canRemoveItems = true;
        });
    });

    this.items.appendChild(item);
    this.hide();
    this.search.value = "";
    this.search.focus();
};

multiselect.prototype.matchesTerm = function(option) {
    var name = option.textContent || option.innerText;
    var unac = option.getAttribute("data-unaccented") || name;
    var index = unac.toLowerCase().indexOf(this.term);

    if (index > -1) {
        option.innerHTML = (name.substring(0, index) + "<em>" +
            name.substring(index, index + this.term.length) + "</em>" +
            name.substring(index + this.term.length, name.length));
        return true;
    }
    option.innerHTML = name;
    return false;
}

multiselect.prototype.lookup = function(term) {
    var self = this, first = Boolean(term);
    this.term = term.toLowerCase();
    if (!this.term) this.hide();

    var $options = $(this.options)
        .not(this.selectedOptions)
        .filter(function() {
            var match = self.matchesTerm(this);
            this.style.display = match ? "block" : "none";

            // in browsers with slow js engines (e.g. opera 10), calling
            // activateOption right away inside the filter prevents ugly
            // flickering/jumping from occuring.
            if (match && first) {
                self.activateOption(this, false);
                first = false;
            }
            return match;
        });

    if (this.term) {
        $options.length ? this.show() : this.hide();
    }
};

multiselect.prototype.show = function() {
    var self = this;

    this.menu.style.top = $(this.container).outerHeight() + "px";
    this.menu.style.display = "block";
    activeSelect = this;

    setTimeout(function() {
        // chrome bug: setting scrollTop to 0 does nothing. but if you set it
        // to 1 first...
        self.menu.scrollTop = 1;
        self.menu.scrollTop = 0;
    }, 0);
};

multiselect.prototype.hide = function() {
    this.menu.style.display = "none";
    this.hoverOption && (this.hoverOption.className = "");
    this.hoverOption = null;
};

multiselect.prototype.buildOptions = function(cacheKey) {
    var doc, self = this;
    var leadingSpace = /^(\s+)(.+)$/;

    if (cacheKey && cache.hasOwnProperty(cacheKey)) {
        doc = cache[cacheKey];
    } else {
        var doc = document.createDocumentFragment(), opt = this.input.firstChild, unac;

        while (opt) {
            if (opt.tagName.toLowerCase() == "option") {
                var a = document.createElement("a");
                var text = opt.textContent || opt.innerText;

                // <option>s are typically padded with non-breaking spaces to
                // indicate hierarchy. The spaces cause problems in matchesTerm,
                // and aren't necessary here, as we can use CSS padding instead.
                var match = text.match(leadingSpace);
                if (match) {
                    a.style.paddingLeft = (match[1].length * 5) + "px";
                    a.innerHTML = match[2];
                } else {
                    a.innerHTML = text;
                }

                a.href = "#";
                a.setAttribute("data-value", opt.value);
                if (unac = opt.getAttribute("data-unaccented"))
                    a.setAttribute("data-unaccented", unac);
                if (self.values.indexOf(opt.value) > -1) a.className = "selected";
                doc.appendChild(a);
            }
            opt = opt.nextSibling;
        }
        if (cacheKey) cache[cacheKey] = doc;
    }
    this.menu.appendChild(doc.cloneNode(true));
    this.options = this.menu.querySelectorAll("a");
};

$.fn.multiselect = function(placeholder, cacheKey) {
    this.each(function(i, e) {new multiselect(e, placeholder || "", cacheKey)});
};

});
