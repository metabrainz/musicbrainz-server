/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2010 MetaBrainz Foundation

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

MB.Control.Autocomplete = function (options) {
    var self = MB.Object();

    var formatItem = function (ul, item) {
        var a = $("<a>").text (item.name);

        if (item.comment)
        {
            a.append (' <span class="autocomplete-comment">(' + item.comment + ')</span>');
        }

        return $("<li>").data ("item.autocomplete", item).append (a).appendTo (ul);
    };

    var formatPager = function (ul, item) {
        self.number_of_pages = item.pages;

        if (item.pages === 1)
        {
            return;
        }

        self.pager_menu_item = $("<a>").text ('(' + item.current + ' / ' + item.pages + ')');

        var li =$('<li>')
            .data ("item.autocomplete", item)
            .css ('text-align', 'center')
            .append (self.pager_menu_item)
            .appendTo (ul);

        return li;
    };

    var pagerButtons = function () {
        var prev = $('<button title="prev">prev</button>');
        var next = $('<button title="next">next</button>');
        var li = self.pager_menu_item;

        li.append (prev).append (next);

        prev.addClass ("autocomplete-pager ui-icon ui-icon-triangle-1-w")
        next.addClass ("autocomplete-pager ui-icon ui-icon-triangle-1-e");

        prev.position ({ my: "left",  at: "left",  of: li, offset: "8 0" });
        next.position ({ my: "right", at: "right", of: li, offset: "-8 0" });

        prev.click (function (event) { self.switchPage (event, -1); });
        next.click (function (event) { self.switchPage (event,  1); });
    };

    var switchPage = function (event, direction) {
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
            self.selectedItem = -1;
        }
        else
        {
            self.selectedItem = menu.active.prevAll (".ui-menu-item").length;
        }

        self.autocomplete.search (null, event);
    };

    var pagerKeyEvent = function (event) {
        var menu = self.autocomplete.menu;

	if (!menu.element.is (":visible")) {
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

    var close = function (event) { self.input.focus (); };
    var open = function (event) {
        var menu = self.autocomplete.menu;

        var newItem;
        if (self.selectedItem === -1)
        {
            newItem = menu.element.children (".ui-menu-item:last");
        }
        else
        {
            newItem = menu.element.children (".ui-menu-item").eq(self.selectedItem);
        }
        
        if (!newItem.length)
        {
            newItem = menu.element.children (".ui-menu-item:last");
        }

        menu.activate (event, newItem);

        self.pagerButtons ();

    };

    var lookup = function (request, response) {
        if (request.term != self.page_term)
        {
            /* always reset to first page if we're looking for something new. */
            self.current_page = 1;
            self.page_term = request.term;
        }

        $.ajax({
            url: self.url,
            data: { q: request.term, page: self.current_page },
            success: response,
        });
    };

    var initialize = function () {

        self.input.autocomplete ({
            'source': lookup,
            'minLength': options.minLength ? options.minLength : 2,
            'select': function (event, data) { return options.select (event, data.item); },
            'close': self.close,
            'open': self.open,
        });

        self.autocomplete = self.input.data ('autocomplete');
        self.input.bind ('keydown', self.pagerKeyEvent);

        self.autocomplete._renderItem = function (ul, item) {
            return item['pages'] ? formatPager (ul, item) : formatItem (ul, item);
        };
    };

    self.input = options.input;
    self.url = options.entity ? "/ws/js/" + options.entity : options.url;
    self.page_term = '';
    self.current_page = 1;
    self.number_of_pages = 1;
    self.selected = 1;

    self.switchPage = switchPage;
    self.pagerButtons = pagerButtons;
    self.pagerKeyEvent = pagerKeyEvent;
    self.close = close;
    self.open = open;
    self.lookup = lookup;

    initialize ();

    return self;
};
