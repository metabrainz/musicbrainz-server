/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2010,2011 MetaBrainz Foundation

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

$.widget("ui.autocomplete", $.ui.autocomplete, {

    mbidRegex: /[a-f\d]{8}-[a-f\d]{4}-[a-f\d]{4}-[a-f\d]{4}-[a-f\d]{12}/,

    options: {
        minLength: 1,
        allowEmpty: true,

        // default to showing error and lookup-performed status by adding
        // those classes (red/green background) to lookup fields.
        showStatus: true,

        // Prevent menu item focus from changing the input value
        focus: function (event, data) {
            return false;
        },

        source: function (request, response) {
            // always reset to first page if we're looking for something new.
            if (request.term != this.pageTerm) {
                this._resetPage();
                this.pageTerm = request.term;
            }

            if (this.xhr) {
                this.xhr.abort();
            }

            this.xhr = $.ajax(this.options.lookupHook({
                url: "/ws/js/" + this.entity,
                data: {
                    q: request.term,
                    page: this.currentPage,
                    direct: !this.indexedSearch
                },
                dataType: "json",
                success: $.proxy(this._lookupSuccess, this, response),
                error: $.proxy(response, null, [])
            }));
        },

        resultHook: _.identity,
        lookupHook: _.identity
    },

    _create: function () {
        this._super();

        this.currentResults = [];
        this.currentPage = 1;
        this.totalPages = 1;
        this.pageTerm = "";
        this.indexedSearch = true;

        this.setObservable(
            this.options.currentSelection || ko.observable({
                name: this._value()
            })
        );

        this.$input = this.element;
        this.$search = this.element
            .closest("span.autocomplete").find("img.search");

        var self = this;

        // The following callbacks are triggered by jQuery UI. They're defined
        // here, and not in the "options" definition above, because they need
        // access to current instance.

        this.options.open = function (event) {
            // Automatically focus the first item in the menu.
            self.menu.focus(event, self.menu.element.children("li:eq(0)"));
        };

        this.options.select = function (event, data) {
            var entity = self._dataToEntity(data.item);

            self.currentSelection(entity);
            self.element.trigger("lookup-performed", [entity]);

            // Returning false prevents the search input's text from changing.
            // We've already changed it in setSelection.
            return false;
        };

        // End of options callbacks.

        this.element.on("input", function (event) {
            var selection = self.currentSelection.peek();

            // XXX The condition shouldn't be necessary, because the input
            // event should only fire if the value has changed. But Opera
            // doesn't fire an input event if you paste text into a field,
            // only if you type it [1]. Pressing enter after pasting an MBID,
            // then, has the effect of firing the input event too late, and
            // clearing the field. Checking the current selection against the
            // current value is done to prevent this.
            // [1] https://developer.mozilla.org/en-US/docs/Web/Reference/Events/input
            if (selection && selection.name !== this.value) {
                self.clearSelection(false);
            }
        });

        this.element.on("blur", function (event) {
            // Stop searching if someone types something and then tabs out of
            // the field.
            self.cancelSearch = true;

            var selection = self.currentSelection.peek();

            if (selection && selection.name !== self._value()) {
                self.clear(false);
            }
        });

        this.$search.on("click.mb", function (event) {
            if (self.element.is(":enabled")) {
                self.element.focus();

                if (self._value()) {
                    self._searchAgain();
                }
            }
        });

        // Click events inside the menu should not cause the box to close.
        this.menu.element.on("click", function (event) {
            event.stopPropagation();
        });

        this.changeEntity(this.options.entity);
    },

    _dataToEntity: function (data) {
        try {
            if (this.options.entityConstructor) {
                return this.options.entityConstructor(data);
            }
            return MB.entity(data, this.entity);
        } catch (e) {
            return data;
        }
    },

    // Overrides $.ui.autocomplete.prototype.close
    // Reset the currentPage and currentResults on menu close.
    close: function (event) {
        this._super(event);
        this._resetPage();
    },

    clear: function (clearAction) {
        this.clearSelection(clearAction);
        this.close();
    },

    clearSelection: function (clearAction) {
        var name = clearAction ? "" : this._value();
        var currentSelection = this.currentSelection.peek();

        // If the current entity doesn't have a GID, it's already "blank" and
        // we don't need to unnecessarily create a new one. Doing so can even
        // have unintended effects, e.g. wiping other useful data on the
        // entity (like release group types).

        if (currentSelection.gid) {
            this.currentSelection(this._dataToEntity({ name: name }));
        }
        else {
            currentSelection.name = name;
            this.currentSelection.notifySubscribers(currentSelection);
        }

        this.element.trigger("cleared", [clearAction]);
    },

    _resetPage: function () {
        this.currentPage = 1;
        this.currentResults = [];
    },

    _searchAgain: function (toggle) {
        if (toggle) {
            this.indexedSearch = !this.indexedSearch;
        }
        this._resetPage();
        this.term = this._value();
        this._search(this.term);
    },

    _showMore: function () {
        this.currentPage += 1;
        this._search(this._value());
    },

    setSelection: function (data) {
        data = data || {};
        var name = ko.unwrap(data.name) || "";

        if (this._value() !== name) {
            this._value(name);
        }

        if (this.options.showStatus) {
            var hasID = !!(data.id || data.gid);
            var error = !(name || hasID || this.options.allowEmpty);

            this.element
                .toggleClass("error", error)
                .toggleClass("lookup-performed", hasID);
        }
        this.term = name || "";
        this.selectedItem = data;
    },

    setObservable: function (observable) {
        if (this._selectionSubscription) {
            this._selectionSubscription.dispose();
        }
        this.currentSelection = observable;

        if (observable) {
            this._selectionSubscription =
                observable.subscribe(this.setSelection, this);
            this.setSelection(observable.peek());
        }
    },

    // Overrides $.ui.autocomplete.prototype._searchTimeout
    _searchTimeout: function (event) {
        var oldTerm = this.term;
        var newTerm = this._value();
        var mbidMatch = newTerm.match(this.mbidRegex);

        if (mbidMatch === null) {
            if (!newTerm) {
                clearTimeout(this.searching);
                this.close();

            // only search if the value has changed
            } else if (oldTerm !== newTerm && this.completedTerm !== newTerm) {
                clearTimeout(this.searching);
                this.completedTerm = oldTerm;

                this.searching = this._delay(
                    function () {
                        delete this.completedTerm;
                        this.selectedItem = null;
                        this.search(null, event);
                    },
                    this.options.delay
                );
            }
        } else {
            clearTimeout(this.searching);
            this._lookupMBID(mbidMatch[0]);
        }
    },

    _lookupMBID: function (mbid) {
        var self = this;

        this.close();

        if (this.xhr) {
            this.xhr.abort();
        }

        this.xhr = $.ajax({
            url: "/ws/js/entity/" + mbid,

            dataType: "json",

            success: function (data) {
                if (data.entityType != self.entity) {
                    // Only RelateTo boxes and relationship-editor dialogs
                    // support changing the entity type.
                    var setEntity = self.options.setEntity;

                    if (!setEntity || setEntity(data.entityType) === false) {
                        self.clear();
                        return;
                    }
                }
                self.options.select(null, { item: data });
            },

            error: _.bind(this.clear, this)
        });
    },

    _lookupSuccess: function (response, data) {
        var self = this;
        var pager = _.last(data);
        var jumpTo = this.currentResults.length;

        data = this.options.resultHook(_.initial(data));

        // "currentResults" will contain action items that aren't results,
        // e.g. ShowMore, SwitchToDirectSearch, etc. Filter these actions out
        // before appending the new results (we re-add them below).

        var results = this.currentResults = _.filter(
            this.currentResults, function (item) {
                return !item.action;
            });

        results.push.apply(results, data);

        this.currentPage = parseInt(pager.current, 10);
        this.totalPages = parseInt(pager.pages, 10);

        if (results.length === 0) {
            results.push({
                label: "(" + MB.text.NoResults + ")",
                action: _.bind(this.close, this)
            });
        }

        if (this.currentPage < this.totalPages) {
            results.push({
                label: MB.text.ShowMore,
                action: _.bind(this._showMore, this)
            });
        }

        results.push({
            label: this.indexedSearch ? MB.text.SwitchToDirectSearch :
                                        MB.text.SwitchToIndexedSearch,
            action: _.bind(this._searchAgain, this, true)
        });

        var allowCreation = window === window.top,
            entity = this.entity.replace("-", "_");

        if (allowCreation && MB.text.AddANewEntity[entity]) {
            results.push({
                label: MB.text.AddANewEntity[entity],
                action: function () {
                    $("<div>").appendTo("body").createEntityDialog({
                        name: self._value(),
                        entity: entity,
                        callback: function (item) {
                            self.options.select(null, { item: item });
                        }
                    });
                }
            });
        }

        response(results);

        this._delay(function () {
            // Once everything's rendered, jump to the first item that was
            // added. This makes the menu scroll after hitting "Show More."
            var menu = this.menu;
            var $ul = menu.element;

            if (menu.active) {
                menu.active.children("a").removeClass("ui-state-focus");
            }

            var $item = menu.active = $ul.children("li:eq(" + jumpTo + ")");
            $item.children("a").addClass("ui-state-focus");

            if (this.currentPage > 1) {
                $ul.scrollTop($item.position().top + $ul.scrollTop());
            }
        });
    },

    _renderAction: function (ul, item) {
        return $("<li>")
            .css("text-align", "center")
            .append($("<a>").text(item.label))
            .appendTo(ul);
    },

    _renderItem: function (ul, item) {
        if (item.action) {
            return this._renderAction(ul, item);
        }
        var formatters = MB.Control.autocomplete_formatters;
        return (formatters[this.entity] || formatters.generic)(ul, item);
    },

    changeEntity: function (entity) {
        this.entity = entity.replace("_", "-");
    }
});


$.widget("ui.menu", $.ui.menu, {

    // When a result is normally selected from an autocomplete menu, the menu
    // is closed and the text of the search input is changed. This is not what
    // we want to happen for menu items associated with an action (e.g. show
    // more, switch to indexed search, clear artist, etc.). To support the
    // desired behavior, the "select" method for jQuery UI menus is overridden
    // below to check if an action function is associated with the selected
    // item. If it is, the action is executed. Otherwise we fall back to the
    // default menu behavior.

    _selectAction: function (event) {
        var active = this.active || $(event.target).closest(".ui-menu-item");
        var item = active.data("ui-autocomplete-item");

        if (item && $.isFunction(item.action)) {
            item.action();

            // If this is a click event on the <a>, make sure the event
            // doesn't reach the parent <li>, or the select action will
            // close the menu.
            event.stopPropagation();
            event.preventDefault();

            return true;
        }
    },

    _create: function () {
        this._super();
        this._on({ "click .ui-menu-item > a": this._selectAction });
    },

    select: function (event) {
        if (!this._selectAction(event)) {
            this._super(event);
        }
        // When mouseHandled is true, $.ui ignores future mouse events. It only
        // gets reset to false if you click outside of the menu, but we want
        // it to be false no matter what.
        this.mouseHandled = false;
    }
});


MB.Control.autocomplete_formatters = {
    "generic": function (ul, item) {
        var a = $("<a>").text (item.name);

        var comment = [];

        if (item.primary_alias && item.primary_alias != item.name)
        {
            comment.push (item.primary_alias);
        }

        if (item.sortName && !MB.utility.is_latin (item.name) && item.sortName != item.name)
        {
            comment.push (item.sortName);
        }

        if (item.comment)
        {
            comment.push (item.comment);
        }

        if (comment.length)
        {
            a.append (' <span class="autocomplete-comment">(' +
                      _.escape(comment.join (", ")) + ')</span>');
        }

        return $("<li>").append (a).appendTo (ul);
    },

    "recording": function (ul, item) {
        var a = $("<a>").text (item.name);

        if (item.length)
        {
            a.prepend ('<span class="autocomplete-length">' +
                MB.utility.formatTrackLength(item.length) + '</span>');
        }

        if (item.comment)
        {
            a.append ('<span class="autocomplete-comment">(' +
                      _.escape(item.comment) + ')</span>');
        }

        if (item.video)
        {
            a.append(
                $('<span class="autocomplete-video"></span>')
                    .text("(" + MB.text.Video + ")")
            );
        }

        a.append ('<br /><span class="autocomplete-comment">by ' +
                  _.escape(item.artist) + '</span>');

        if (item.appearsOn && item.appearsOn.hits > 0)
        {
            var rgs = [];
            $.each (item.appearsOn.results, function (idx, item) {
                rgs.push (item.name);
            });

            if (item.appearsOn.hits > item.appearsOn.results.length)
            {
                rgs.push ('...');
            }

            a.append ('<br /><span class="autocomplete-appears">appears on: ' +
                      _.escape(rgs.join (", ")) + '</span>');
        }
        else if (item.appearsOn && item.appearsOn.hits === 0) {
            a.append ('<br /><span class="autocomplete-appears">standalone recording</span>');
        }

        if (item.isrcs && item.isrcs.length)
        {
            a.append ('<br /><span class="autocomplete-isrcs">isrcs: ' +
                      _.escape(item.isrcs.join (", ")) + '</span>');
        }

        return $("<li>").append (a).appendTo (ul);
    },

    "release-group": function (ul, item) {
        var a = $("<a>").text (item.name);

        if (item.firstReleaseDate)
        {
            a.append ('<span class="autocomplete-comment">(' +
                        item.firstReleaseDate + ')</span>');
        }

        if (item.comment)
        {
            a.append ('<span class="autocomplete-comment">(' +
                      _.escape(item.comment) + ')</span>');
        }

        if (item.typeName) {
            a.append ('<br /><span class="autocomplete-comment">' + item.typeName + ' by ' +
                    _.escape(item.artist) + '</span>');
        }

        return $("<li>").append (a).appendTo (ul);
    },

    "work": function (ul, item) {
        var a = $("<a>").text (item.name);
        var comment = [];

        if (item.language)
        {
            a.prepend ('<span class="autocomplete-length">' + item.language + '</span>');
        }

        if (item.primary_alias && item.primary_alias != item.name)
        {
            comment.push (item.primary_alias);
        }

        if (item.comment)
        {
            comment.push (item.comment);
        }

        if (comment.length)
        {
            a.append (' <span class="autocomplete-comment">(' +
                      _.escape(comment.join (", ")) + ')</span>');
        }

        var artistRenderer = function(prefix, artists) {
            if (artists && artists.hits > 0)
            {
                var toRender = artists.results;
                if (artists.hits > toRender.length)
                {
                    toRender.push ('...');
                }

                a.append ('<br /><span class="autocomplete-comment">' +
                        prefix + ': ' +
                        _.escape(toRender.join (", ")) + '</span>');
            }
        };

        if (item.artists) {
            artistRenderer("Writers", item.artists.writers);
            artistRenderer("Artists", item.artists.artists);
        }

        return $("<li>").append (a).appendTo (ul);
    },

    "area": function (ul, item) {
        var a = $("<a>").text (item.name);

        if (item.comment)
        {
            a.append ('<span class="autocomplete-comment">(' +
                      _.escape(item.comment) + ')</span>');
        }

        if (item.typeName || item.parentCountry || item.parentSubdivision || item.parentCity) {
             var items = [];
             if (item.typeName) items.push(_.escape(item.typeName));
             if (item.parentCity) items.push(_.escape(item.parentCity));
             if (item.parentSubdivision) items.push(_.escape(item.parentSubdivision));
             if (item.parentCountry) items.push(_.escape(item.parentCountry));
             a.append ('<br /><span class="autocomplete-comment">' +
                       items.join(", ") +
                       '</span>');
        };

        return $("<li>").append (a).appendTo (ul);
    },

    "place": function (ul, item) {
        var a = $("<a>").text (item.name);

        var comment = [];

        if (item.primary_alias && item.primary_alias != item.name)
        {
            comment.push (item.primary_alias);
        }

        if (item.comment)
        {
            comment.push (item.comment);
        }

        if (comment.length)
        {
            a.append (' <span class="autocomplete-comment">(' +
                      _.escape(comment.join (", ")) + ')</span>');
        }

        if (item.typeName || item.area) {
             a.append ('<br /><span class="autocomplete-comment">' +
                       (item.typeName ? _.escape(item.typeName) : '') +
                       (item.typeName && item.area ? ', ' : '') +
                       (item.area ? _.escape(item.area) : '') +
                       '</span>');
        };

        return $("<li>").append (a).appendTo (ul);
    }

};


/*
   MB.Control.EntityAutocomplete is a helper class which simplifies using
   Autocomplete to look up entities.  It takes care of setting id and gid
   values on related hidden inputs.

   It expects to see html looking like this:

       <span class="ENTITY autocomplete">
          <img class="search" src="search.png" />
          <input type="text" class="name" />
          <input type="hidden" class="id" />
          <input type="hidden" class="gid" />
       </span>

   Do a lookup of the span with jQuery and pass it into EntityAutocomplete
   as options.inputs, for example, for a release group do this:

       MB.Control.EntityAutocomplete ({ inputs: $('span.release-group.autocomplete') });

   The 'lookup-performed' and 'cleared' events will be triggered on the input.name
   element (though you can just bind on the span, as events will bubble up).
*/

MB.Control.EntityAutocomplete = function (options) {
    var $inputs = options.inputs || $();
    var $name = options.input || $inputs.find("input.name");

    if (!options.entity) {
        // guess the entity from span classes.
        $.each(MB.constants.ENTITIES, function (idx, entity) {
            if ($inputs.hasClass(entity)) {
                options.entity = entity;
            }
        });
    }

    $name.autocomplete(options);
    var autocomplete = $name.data("ui-autocomplete");

    autocomplete.currentSelection(MB.entity({
        name: $name.val(),
        id: $inputs.find("input.id").val(),
        gid: $inputs.find("input.gid").val()
    }, options.entity));

    autocomplete.currentSelection.subscribe(function (item) {
        var $hidden = $inputs.find("input[type=hidden]").val("");

        // We need to do this manually, rather than using $.each, due to recordings
        // having a 'length' property.
        for (key in item) {
            if (item.hasOwnProperty(key)) {
                $hidden.filter("input." + key)
                    .val(item[key]).trigger("change");
            }
        }
    });

    return autocomplete;
};


ko.bindingHandlers.autocomplete = {

    init: function (element, valueAccessor) {
        var options = valueAccessor();

        var autocomplete = $(element).autocomplete(options)
            .data("ui-autocomplete");

        if (options.artistCredit) {
            options.artistCredit.setAutocomplete(autocomplete, element);
        }
    }
};
