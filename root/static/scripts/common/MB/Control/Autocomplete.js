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

        return $("<li>").data ("ui-autocomplete-item", item).append (a).appendTo (ul);
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

        return $("<li>").data ("ui-autocomplete-item", item).append (a).appendTo (ul);
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

        return $("<li>").data ("ui-autocomplete-item", item).append (a).appendTo (ul);
    },

    "work": function (ul, item) {
        var a = $("<a>").text (item.name);

        if (item.comment)
        {
            a.append ('<span class="autocomplete-comment">(' +
                      MB.utility.escapeHTML (item.comment) + ')</span>');
        }

        if (item.artists && item.artists.hits > 0)
        {
            var artists = item.artists.results;
            if (item.artists.hits > item.artists.results.length)
            {
                artists.push ('...');
            }

            a.append ('<br /><span class="autocomplete-comment">by ' +
                      MB.utility.escapeHTML (artists.join (", ")) + '</span>');
        }

        return $("<li>").data ("ui-autocomplete-item", item).append (a).appendTo (ul);
    },

    "area": function (ul, item) {
        var a = $("<a>").text (item.name);

        if (item.typeName || item.parentCountry) {
             a.append ('<br /><span class="autocomplete-comment">' +
                       (item.typeName ? MB.utility.escapeHTML(item.typeName) : '') +
                       (item.typeName && item.parentCountry ? ', ' : '') +
                       (item.parentCountry ? MB.utility.escapeHTML(item.parentCountry) : '') +
                       '</span>');
        };

        return $("<li>").data ("ui-autocomplete-item", item).append (a).appendTo (ul);
    }
};


MB.Control.Autocomplete = function (options) {
    var self = MB.Object();
    var cancelSearch = true;

    var formatPager = function (ul, item) {
        if (ul.children ().length === 0)
        {
            var span = $('<span>(' + MB.text.NoResults + ')</span>');

            return $("<li>")
                .data ("ui-autocomplete-item", item)
                .addClass("ui-menu-item")
                .css ('text-align', 'center')
                .append (span)
                .appendTo (ul);
        }

        if (item.current == item.pages)
        {
            return $();
        }

        item.action = function () {
            self.currentPage += 1;
            self.autocomplete._search(self.$input.val());
        };

        return $('<li>')
            .data ("ui-autocomplete-item", item)
            .css ('text-align', 'center')
            .append ($("<a>").text(MB.text.ShowMore))
            .appendTo (ul);
    };

    var formatMessage = function (ul, item) {

        var message = $("<a>").text (item.message);

        var li = $('<li>')
            .data ("ui-autocomplete-item", item)
            .css ('text-align', 'center')
            .append (message)
            .appendTo (ul);

        return li;
    };

    self.resetPage = function () {
        self.currentPage = 1;
        self.currentResults = [];
    };

    self.searchAgain = function (toggle) {
        if (toggle) {
            self.indexed_search = !self.indexed_search;
        }
        self.resetPage();
        self.autocomplete._search(self.$input.val());
    };

    self.close = function (event) {
        self.$input.focus();

        // If the menu is closing for good (i.e. not just temporarily after
        // hitting "Show more..."), clear the current page and results.
        if (cancelSearch) {
            self.resetPage();
        }

        cancelSearch = true;
    };

    self.open = function (event) {
        var menu = self.autocomplete.menu;
        menu.focus(event, menu.element.children("li:eq(0)"));

        // XXX MBS-1675
        if ($(document).height () > $('body').height ()) {
            $('body').height ($(document).height ());
        }
    };

    self.lookup = function (request, response) {
        if (request.term != self.page_term)
        {
            /* always reset to first page if we're looking for something new. */
            self.resetPage();
            self.page_term = request.term;
        }

        $.ajax(self.lookupHook ({
            url: self.url,
            data: { q: request.term, page: self.currentPage, direct: !self.indexed_search },
            success: function (data, result, request) {
                data = self.resultHook(data);
                var jumpTo = self.currentResults.length;
                self.currentResults.push.apply(self.currentResults, data.slice(0, -1));
                var pager = data.pop();
                data = self.currentResults.slice(0);
                data.push(pager);

                if (options.allow_empty) {
                    data.push ({
                        "action": function () { self.clear (true) },
                        "message": MB.text.RemoveLinkedEntity[self.entity]
                    });
                }

                data.push ({
                    "action": function () { self.searchAgain (true); },
                    "message": self.indexed_search ?
                        MB.text.SwitchToDirectSearch :
                        MB.text.SwitchToIndexedSearch
                });

                var re = response(data, result, request);

                self.autocomplete._delay(function () {
                    var menu = self.autocomplete.menu;
                    var $ul = menu.element;

                    if (menu.active) {
                        menu.active.children("a").removeClass("ui-state-focus");
                    }

                    var $item = menu.active = $ul.children("li:eq(" + jumpTo + ")");
                    $item.children("a").addClass("ui-state-focus");

                    if (self.currentPage > 1) {
                        $ul.scrollTop($item.position().top + $ul.scrollTop());
                    }
                });

                return re;
            }
        }));
    };

    self.select = function (event, data) {
        event.preventDefault();
        var item = self.currentSelection = data.item;

        if (item.action) {
            cancelSearch = false;
            item.action();
            self.autocomplete.menu.mouseHandled = false;
        } else {
            cancelSearch = true;
            options.select(event, item);
        }
    };

    self.clear = function (clearAction) {
        self.currentSelection = null;
        self.resetPage();
        if (options.clear)
        {
            options.clear (clearAction);
        }
    };

    // Prevent menu item focus from changing the input value
    self.focus = function (event, data) {
        return false;
    };

    self.initialize = function () {
        self.changeEntity (options.entity);

        var entity_regex = /[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/;

        self.$input.on('input', function (event) {
            var match = this.value.match(entity_regex);
            if (match === null) {
                $(this).trigger("keydown.autocomplete");
                return;
            }
            cancelSearch = true;
            self.autocomplete.close();
            // MBS-6385: prevent the autocomplete from searching the entered
            // URL/MBID as an entity name. After a short timeout, a search is
            // only performed if "term" differs from the input value.
            self.autocomplete.term = this.value;
            var mbid = match[0];

            $(this).trigger("blur.autocomplete").prop("disabled", true);

            $.ajax({
                url: "/ws/js/entity/" + mbid,
                dataType: "json",
                success: function (data) {
                    var type = data["type"];
                    if (type != self.entity) {
                        // Only RelateTo boxes and relationship-editor dialogs
                        // support changing the entity type.
                        if (!options.setEntity || options.setEntity(type) === false) {
                            self.clear();
                            return;
                        }
                    }
                    self.select (event, { item: data });
                    self.autocomplete.term = data.name;
                    self.autocomplete.selectedItem = null;
                },
                error: function () {
                    self.clear();
                },
                complete: function () {
                    self.$input.prop("disabled", false).focus();
                }
            });
        });

        self.$input.autocomplete ($.extend({}, options, {
            source:    self.lookup,
            minLength: options.minLength ? options.minLength : 1,
            select:    self.select,
            close:     self.close,
            open:      self.open,
            focus:     self.focus
        }));

        self.autocomplete = self.$input.data ('ui-autocomplete');

        self.$input.on('blur', function(event) {
            if (!self.currentSelection) return;
            if (self.currentSelection.name !== self.$input.val()) {
                self.clear (false);
            }
        });

        self.$search.on('click.mb', function (event) {
            self.searchAgain ();
            self.$input.focus ();
        });

        self.autocomplete._renderItem = function (ul, item) {
            return item['pages'] ? self.formatPager (ul, item) :
                item['message'] ? self.formatMessage (ul, item) :
                self.formatItem (ul, item);
        };

        /* Click events inside the menu, but outside of a relate-to box,
           should not cause the box to close. */
        self.autocomplete.menu.element.click(function (event) {
            event.stopPropagation();
        });

        self.autocomplete.close = function (event) {
            // XXX selecting the show-more or direct-search buttons closes the
            // menu, which stops the in-progress searches.
            if (cancelSearch) {
                self.autocomplete.cancelSearch = true;
            }
            self.autocomplete._close(event);
        };
    };

    self.changeEntity = function (entity) {
        self.entity = entity.replace ('_', '-');
        self.url = options.url || "/ws/js/" + self.entity;

        if (options.formatItem)
        {
            self.formatItem = options.formatItem;
        }
        else
        {
            self.formatItem = MB.Control.autocomplete_formatters[self.entity] ||
                MB.Control.autocomplete_formatters['generic'];
        }
    };

    self.currentSelection = null;

    self.$input = options.input;
    self.$search = self.$input.closest ('span.autocomplete').find('img.search');

    self.lookupHook = options.lookupHook || function (r) { return r; };
    self.resultHook = options.resultHook || function (r) { return r; };
    self.page_term = '';
    self.currentPage = 1;
    self.currentResults = [];
    self.selected_item = 0;
    self.indexed_search = true;

    self.formatPager = options.formatPager || formatPager;
    self.formatMessage = options.formatMessage || formatMessage;

    return self;
};


/*
   MB.Control.EntityAutocomplete is a helper class which simplifies using
   Autocomplete to look up entities.  It takes care of setting 'error' and
   'lookup-performed' classes on the search input, and setting id and gid
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
    var $inputs = options.inputs;

    delete options.inputs;

    var $name = $inputs.find ('input.name');
    var $id = $inputs.find ('input.id');
    var $gid = $inputs.find ('input.gid');

    if (!options.hasOwnProperty ('show_status'))
    {
        /* default to showing error and lookup-performed status by adding those
           classes (red/green background) to lookup fields. */
        options.show_status = true;
    }

    if (!options.entity)
    {
        /* guess the entity from span classes. */
        $.each (MB.constants.ENTITIES, function (idx, entity) {
            if ($inputs.hasClass (entity))
            {
                options.entity = entity;
            }
        });
    }

    options.input = $name;

    options.select = function (event, item) {
        // We need to do this manually, rather than using $.each, due to recordings
        // having a 'length' property.
        for (key in item) {
            $inputs.find('input.' + key).val(item[key]);
        }

        $name.removeClass('error');
        if (options.show_status)
        {
            $name.addClass ('lookup-performed');
        }
        $name.data ('lookup-result', item);
        $name.trigger ('lookup-performed', [ item ]);
    };

    var self = MB.Control.Autocomplete(options);

    /* if clearAction is set, also clear the autocomplete input itself,
       otherwise only clear the lookup / selection. */
    self.clear = function (clearAction) {
        $inputs.find ('input').each (function (idx, elem) {
            if (! $(elem).hasClass ('name') || clearAction)
            {
                $(elem).val ('');
            }
        });

        if (options.show_status && $name.val () !== '')
        {
            $name.addClass('error');
        }
        $name.removeClass ('lookup-performed');
        $name.data ('lookup-result', null);
        $name.trigger ('cleared');
    };

    var parent_initialize = self.initialize;

    self.initialize = function () {
        parent_initialize ();

        if ($id.val () === '' && $gid.val () === '')
        {
            $name.removeClass ('lookup-performed');
            if ($name.val () !== '' && options.show_status)
            {
                $name.addClass('error');
            }
        }
        else
        {
            $name.removeClass('error');
            if (options.show_status)
            {
                $name.addClass ('lookup-performed');
            }

            self.currentSelection = {
                name: $name.val (),
                id: $id.val (),
                gid: $gid.val ()
            };
        }
    }

    options.input = $name;

    self.initialize ();

    return self;
}

