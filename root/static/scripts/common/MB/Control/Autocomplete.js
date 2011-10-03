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

        return $("<li>").data ("item.autocomplete", item).append (a).appendTo (ul);
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

        return $("<li>").data ("item.autocomplete", item).append (a).appendTo (ul);
    },

    "release-group": function (ul, item) {
        var a = $("<a>").text (item.name);

        if (item.comment)
        {
            a.append ('<span class="autocomplete-comment">(' +
                      MB.utility.escapeHTML (item.comment) + ')</span>');
        }

        a.append ('<br /><span class="autocomplete-comment">by ' +
                  MB.utility.escapeHTML (item.artist) + '</span>');

        return $("<li>").data ("item.autocomplete", item).append (a).appendTo (ul);
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

        return $("<li>").data ("item.autocomplete", item).append (a).appendTo (ul);
    }
};


MB.Control.Autocomplete = function (options) {
    var self = MB.Object();

    var formatPager = function (ul, item) {
        self.number_of_pages = item.pages;
        self.pager_menu_item = null;

        if (ul.children ().length === 0)
        {
            var span = $('<span>(' + MB.text.NoResults + ')</span>');

            var li = $("<li>")
                .data ("item.autocomplete", item)
                .addClass("ui-menu-item")
                .css ('text-align', 'center')
                .append (span)
                .appendTo (ul);

            return li;
        }

        if (item.pages === 1)
        {
            return;
        }

        self.pager_menu_item = $("<a>").text ('(' + item.current + ' / ' + item.pages + ')');

        var li = $('<li>')
            .data ("item.autocomplete", item)
            .css ('text-align', 'center')
            .append (self.pager_menu_item)
            .appendTo (ul);

        return li;
    };

    var formatMessage = function (ul, item) {

        var message = $("<a>").text (item.message);

        var li = $('<li>')
            .data ("item.autocomplete", item)
            .css ('text-align', 'center')
            .append (message)
            .appendTo (ul);

        return li;
    };

    self.pagerButtons = function () {
        var li = self.pager_menu_item;

        if (!li)
        {
            return;
        }

        var prev = $('<button title="prev">prev</button>');
        var next = $('<button title="next">next</button>');

        li.append (prev).append (next);

        prev.addClass ("autocomplete-pager ui-icon ui-icon-triangle-1-w")
        next.addClass ("autocomplete-pager ui-icon ui-icon-triangle-1-e");

        prev.position ({ my: "left",  at: "left",  of: li, offset: "8 0" });
        next.position ({ my: "right", at: "right", of: li, offset: "-8 0" });

        prev.click (function (event) { self.switchPage (event, -1); });
        next.click (function (event) { self.switchPage (event,  1); });
    };

    self.pagerKeyEvent = function (event) {
        var menu = self.autocomplete.menu;

    if (!menu.element.is (":visible") ||
            !self.pager_menu_item ||
            !self.pager_menu_item.hasClass ('ui-state-hover'))
        {
            return;
        }

        var keyCode = $.ui.keyCode;

        switch (event.keyCode) {
        case keyCode.LEFT:
            self.switchPage (event, -1);
            event.preventDefault ();
            break;
        case keyCode.RIGHT:
            self.switchPage (event, 1);
            event.preventDefault ();
            break;
        };
    };

    self.switchPage = function (event, direction) {
        self.current_page = self.current_page + direction;

        if (self.current_page < 1)
        {
            self.current_page = 1;
            return;
        }
        else if (self.current_page > self.number_of_pages)
        {
            self.current_page = self.number_of_pages;
            return;
        }

        var menu = self.autocomplete.menu;

        if (menu.last ())
        {
            self.selected_item = -1;
        }
        else
        {
            self.selected_item = menu.active.prevAll (".ui-menu-item").length;
        }

        self.autocomplete.search (null, event);
    };

    self.searchAgain = function (toggle) {
        if (toggle) {
            self.indexed_search = ! self.indexed_search;
        }

        self.autocomplete.search (self.$input.val ());
    };

    self.close = function (event) { self.$input.focus (); };
    self.open = function (event) {
        var menu = self.autocomplete.menu;

        var newItem;
        if (self.selected_item === -1)
        {
            newItem = menu.element.children (".ui-menu-item:last");
        }
        else
        {
            newItem = menu.element.children (".ui-menu-item").eq(self.selected_item);
        }

        if (!newItem.length)
        {
            newItem = menu.element.children (".ui-menu-item:last");
        }

        if (newItem.length)
        {
            menu.activate (event, newItem);
        }

        self.pagerButtons ();

        if ($(document).height () > $('body').height ())
        {
            $('body').height ($(document).height ());
        }
    };

    self.lookup = function (request, response) {
        if (request.term != self.page_term)
        {
            /* always reset to first page if we're looking for something new. */
            self.current_page = 1;
            self.page_term = request.term;
        }

        $.ajax(self.lookupHook ({
            url: self.url,
            data: { q: request.term, page: self.current_page, direct: !self.indexed_search },
            success: function (data, result, request) {

                data = self.resultHook (data);

                if (options.allow_empty)
                {
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

                /* FIXME: this shouldn't be neccesary.  figure out why
                 * this gets cleared on page switches. */
                if (self.$input.val () == '')
                {
                    self.$input.val (self.page_term);
                }

                return response (data, result, request);
            }
        }));
    };

    self.select = function (event, data) {
        event.preventDefault ();
        self.currentSelection = data.item;
        return data.item.action ? data.item.action () : options.select (event, data.item);
    };

    self.clear = function (clearAction) {
        self.currentSelection = null;
        if (options.clear)
        {
            options.clear (clearAction);
        }
    };

    /* iamfeelinglucky is used in selenium tests.

       Operating the autocomplete menus is very cumbersome and unreliable
       from selenium, so instead a selenium test can trigger this event.
       This function will perform a direct search and select the first
       result (hence the name).

       To use this in selenium do (using release-artist as an example):

       FireEvent        "release-artist"                      "iamfeelinglucky"
       waitForNotValue  "id-artist_credit.names.0.artist_id"  ""

       Using an empty string with waitForNotValue means we wait for the value
       to not be the empty string.
    */
    self.iamfeelinglucky = function (event) {
        self.indexed_search = false;

        var fake_event = { preventDefault: function () {} };

        var term = self.$input.val ();
        self.lookup ({ "term": term }, function (data, result, request) {
            self.select (fake_event, { item: data[0] });
        });
    };

    self.initialize = function () {

        self.changeEntity (options.entity);

        self.$input.autocomplete ($.extend({}, options, {
            'source': self.lookup,
            'minLength': options.minLength ? options.minLength : 1,
            'select': self.select,
            'close': self.close,
            'open': self.open
        }));

        self.autocomplete = self.$input.data ('autocomplete');
        self.$input.bind ('keydown.mb', self.pagerKeyEvent);
        self.$input.bind ('propertychange.mb input.mb', function (event) {
            self.$input.trigger ("keydown");
        });
        self.$input.bind ('iamfeelinglucky', self.iamfeelinglucky);
        self.$input.bind ('blur', function(event) {
            if (!self.currentSelection) return;
            if (self.currentSelection.name !== self.$input.val()) {
                self.clear (false);
            }
        });

        self.$search.bind ('click.mb', function (event) {
            self.searchAgain ();
            self.$input.focus ();
        });

        self.autocomplete._renderItem = function (ul, item) {
            return item['pages'] ? self.formatPager (ul, item) :
                item['message'] ? self.formatMessage (ul, item) :
                self.formatItem (ul, item);
        };

        /* because we're overriding select above we also need to override
           blur on the menu.  select() was used to render the selected value
           to the associated input, which blur would then reset back to it's
           original value (We need to prevent blur from doing that). */
        self.autocomplete.menu.options.blur = function (event, ui) { };

        /* focus, idem. */
        self.autocomplete.menu.options.focus = function (event, ui) { };
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
    self.current_page = 1;
    self.number_of_pages = 1;
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

    var self = MB.Control.Autocomplete (options);

    self.select = function (event, data) {
        event.preventDefault ();

        self.currentSelection = data.item;
        if (data.item.action)
        {
            return data.item.action ();
        }

        $.each (data.item, function (key, value) {
            var $elem = $inputs.find ('input.' + key);
            if ($elem)
            {
                $elem.val (value);
            }
        });

        $name.removeClass('error');
        if (options.show_status)
        {
            $name.addClass ('lookup-performed');
        }
        $name.data ('lookup-result', data.item);
        $name.trigger ('lookup-performed', data.item);
    };

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

