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

            this.xhr = $.ajax(this.lookupHook({
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
        }
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
            var entity;

            try {
                entity = MB.entity(data.item, self.entity);
            } catch (e) {
                entity = data.item;
            }

            self.currentSelection(entity);
            self.element.trigger("lookup-performed", [entity]);

            // Returning false prevents the search input's text from changing.
            // We've already changed it in setSelection.
            return false;
        };

        // End of options callbacks.

        this.element.on("input", function (event) {
            var selection = self.currentSelection.peek();

            if (selection) {
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

        this.changeEntity(this.options.entity);
    },

    // Overrides $.ui.autocomplete.prototype.close
    // The default method cancels in-progress searches, which we don't want,
    // because the show-more and indexed-search buttons break otherwise.
    close: function (event) {
        this._close(event);
    },

    clear: function (clearAction) {
        this.clearSelection(clearAction);
        this._resetPage();
        this.close();
    },

    clearSelection: function (clearAction) {
        this.currentSelection({ name: clearAction ? "" : this._value() });
        this.element.trigger("cleared", [clearAction]);
    },

    _resetPage: function () {
        this.currentPage = 1;
        this.currentResults = [];
    },

    _searchAgain: function (toggle) {
        // cancelBlur prevents the menu from closing after a click event
        this.cancelBlur = true;

        if (toggle) {
            this.indexedSearch = !this.indexedSearch;
        }
        this._resetPage();
        this.term = this._value();
        this._search(this.term);
    },

    _showMore: function () {
        this.cancelBlur = true;
        this.currentPage += 1;
        this._search(this._value());
    },

    setSelection: function (data) {
        data = data || {};
        this._value(data.name || "");

        if (this.options.showStatus) {
            var hasID = !!(data.id || data.gid);
            var error = !(data.name || hasID || this.options.allowEmpty);

            this.element
                .toggleClass("error", error)
                .toggleClass("lookup-performed", hasID);
        }
        this.term = data.name || "";
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
        clearTimeout(this.searching);

        var value = this._value();
        var mbidMatch = value.match(this.mbidRegex);

        if (mbidMatch === null) {
            // only search if the value has changed
            if (value && this.term !== value) {
                this.searching = this._delay(
                    function () {
                        this.selectedItem = null;
                        this.search(null, event);
                    },
                    this.options.delay
                );
            }
        } else {
            this._lookupMBID(mbidMatch[0]);
        }
    },

    _lookupMBID: function (mbid) {
        var self = this;

        this.close();
        this.element.prop("disabled", true);

        $.ajax({
            url: "/ws/js/entity/" + mbid,

            dataType: "json",

            success: function (data) {
                if (data.type != self.entity) {
                    // Only RelateTo boxes and relationship-editor dialogs
                    // support changing the entity type.
                    var setEntity = self.options.setEntity;

                    if (!setEntity || setEntity(data.type) === false) {
                        self.clear();
                        return;
                    }
                }
                self.currentSelection(data);
            },

            error: _.bind(this.clear, this),

            complete: function () {
                self.element.prop("disabled", false).focus();
            }
        });
    },

    lookupHook: _.identity,
    resultHook: _.identity,

    _lookupSuccess: function (response, data, result, request) {
        var pager = _.last(data);
        var jumpTo = this.currentResults.length;

        data = this.resultHook(_.initial(data));
        this.currentResults.push.apply(this.currentResults, data);

        this.currentPage = parseInt(pager.current, 10);
        this.totalPages = parseInt(pager.pages, 10);

        response(this.currentResults);

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

    _renderMenu: function (ul, items) {
        this._super(ul, items);

        // We're not always here because a search occurred, so adding the
        // buttons below doesn't always make sense. e.g. the recent entities
        // list in the relationship editor.
        if (this.pending === 0 || items.length === 0) {
            return;
        }

        if (ul.children().length === 0) {
            this._renderAction(ul, "(" + MB.text.NoResults + ")");

        } else if (this.currentPage < this.totalPages) {
            this._renderAction(ul, MB.text.ShowMore, _.bind(this._showMore, this));
        }

        var msg = this.indexedSearch ? MB.text.SwitchToDirectSearch :
                                       MB.text.SwitchToIndexedSearch;
        this._renderAction(ul, msg, _.bind(this._searchAgain, this, true));
    },

    _renderAction: function (ul, message, action) {
        return $("<li>")
            .css("text-align", "center")
            .append($("<a>").text(message))
            .appendTo(ul)
            .data("ui-autocomplete-item", { action: action });
    },

    _renderItem: function (ul, item) {
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

    select: function (event) {
        var active = this.active || $(event.target).closest(".ui-menu-item");
        var item = active.data("ui-autocomplete-item");

        if (item && $.isFunction(item.action)) {
            item.action();
            event.preventDefault();
        } else {
            this._super(event);
        }
    }
});


MB.Control.autocomplete_formatters = {
    "generic": function (ul, item) {
        var a = $("<a>").text (item.name);

        var comment = [];

        if (item.sortname && !MB.utility.is_ascii (item.name))
        {
            comment.push (item.sortname);
        }

        if (item.comment)
        {
            comment.push (item.comment);
        }

        if (comment.length)
        {
            a.append (' <span class="autocomplete-comment">(' +
                      MB.utility.escapeHTML (comment.join (", ")) + ')</span>');
        }

        return $("<li>").append (a).appendTo (ul);
    },

    "recording": function (ul, item) {
        var a = $("<a>").text (item.name);

        if (item.length && item.length !== '' && item.length !== '?:??')
        {
            a.prepend ('<span class="autocomplete-length">' + item.length + '</span>');
        }

        if (item.comment)
        {
            a.append ('<span class="autocomplete-comment">(' +
                      MB.utility.escapeHTML (item.comment) + ')</span>');
        }

        if (item.video)
        {
            a.append ('<span class="autocomplete-video">(video)</span>');
        }

        a.append ('<br /><span class="autocomplete-comment">by ' +
                  MB.utility.escapeHTML (item.artist) + '</span>');

        if (item.appears_on && item.appears_on.hits > 0)
        {
            var rgs = [];
            $.each (item.appears_on.results, function (idx, item) {
                rgs.push (item.name);
            });

            if (item.appears_on.hits > item.appears_on.results.length)
            {
                rgs.push ('...');
            }

            a.append ('<br /><span class="autocomplete-appears">appears on: ' +
                      MB.utility.escapeHTML (rgs.join (", ")) + '</span>');
        }
        else {
            a.append ('<br /><span class="autocomplete-appears">standalone recording</span>');
        }

        if (item.isrcs.length)
        {
            a.append ('<br /><span class="autocomplete-isrcs">isrcs: ' +
                      MB.utility.escapeHTML (item.isrcs.join (", ")) + '</span>');
        }

        return $("<li>").append (a).appendTo (ul);
    },

    "release-group": function (ul, item) {
        var a = $("<a>").text (item.name);

        if (item.comment)
        {
            a.append ('<span class="autocomplete-comment">(' +
                      MB.utility.escapeHTML (item.comment) + ')</span>');
        }

        a.append ('<br /><span class="autocomplete-comment">' + item.typeName + ' by ' +
                  MB.utility.escapeHTML (item.artist) + '</span>');

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
                      MB.utility.escapeHTML (comment.join (", ")) + ')</span>');
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
                        MB.utility.escapeHTML (toRender.join (", ")) + '</span>');
            }
        };

        artistRenderer("Writers", item.artists.writers);
        artistRenderer("Artists", item.artists.artists);

        return $("<li>").append (a).appendTo (ul);
    },

    "area": function (ul, item) {
        var a = $("<a>").text (item.name);

        if (item.comment)
        {
            a.append ('<span class="autocomplete-comment">(' +
                      MB.utility.escapeHTML (item.comment) + ')</span>');
        }

        if (item.typeName || item.parentCountry) {
             a.append ('<br /><span class="autocomplete-comment">' +
                       (item.typeName ? MB.utility.escapeHTML(item.typeName) : '') +
                       (item.typeName && item.parentCountry ? ', ' : '') +
                       (item.parentCountry ? MB.utility.escapeHTML(item.parentCountry) : '') +
                       '</span>');
        };

        return $("<li>").append (a).appendTo (ul);
    },

    "place": function (ul, item) {
        var a = $("<a>").text (item.name);

        var comment = [];

        if (item.comment)
        {
            comment.push (item.comment);
        }

        if (comment.length)
        {
            a.append (' <span class="autocomplete-comment">(' +
                      MB.utility.escapeHTML (comment.join (", ")) + ')</span>');
        }

        if (item.typeName || item.area) {
             a.append ('<br /><span class="autocomplete-comment">' +
                       (item.typeName ? MB.utility.escapeHTML(item.typeName) : '') +
                       (item.typeName && item.area ? ', ' : '') +
                       (item.area ? MB.utility.escapeHTML(item.area) : '') +
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

    autocomplete.currentSelection({
        name: $name.val(),
        id: $inputs.find("input.id").val(),
        gid: $inputs.find("input.gid").val()
    });

    autocomplete.currentSelection.subscribe(function (item) {
        $inputs.find(":input").val("");

        // We need to do this manually, rather than using $.each, due to recordings
        // having a 'length' property.
        for (key in item) {
            $inputs.find('input.' + key).val(item[key]).trigger('change');
        }
    });

    return autocomplete;
};


ko.bindingHandlers.autocomplete = {

    init: function (element, valueAccessor) {
        var options = valueAccessor();

        var autocomplete = $(element).autocomplete(options)
            .data("ui-autocomplete");

        }
    }
};
