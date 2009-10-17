/* Copyright (C) 2009 Oliver Charles

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

/*jslint */
/*global MB */
'use strict';

(function(MB) {
    var KEY_ESCAPE = 27,
        KEY_TAB = 9;

    $.extend(MB.url, {
        EntityLookup: {
            ajaxSearch: '/ajax/search'
        }
    });

    MB.Control.EntityLookup = function(type, options) {
        var self = this;

        options = $.extend({
            defaultValue: '',
            selection: undefined,
            limit: 8
        }, options);

        var lastSearch, currentPage = 1;

        // Query field
        self.query = $( MB.html.input({ value: options.defaultValue }) )
            .focus(function() { self.showResults(); })
            .keydown(function(event) {
                switch (event.keyCode) {
                case KEY_ESCAPE:
                case KEY_TAB:
                    self.hideResults();
                    break;
                }
            });

        // The whole pop-up box
        var resultContainer = new MB.Control.InlineDialog();
        resultContainer.dialog.addClass('lookup-results');

        // Information on search results
        var info = $(MB.html.div({ 'class': 'info' }, MB.text.ClickLookup)).appendTo(resultContainer.dialog);

        // Lookup button
        $(MB.html.button({}, MB.text.Lookup))
            .click(function(ev) {
                ev.preventDefault();
                self.search(self.query.val(), 1);
            })
            .appendTo(resultContainer.dialog);

        // Search results <ul>
        var results = $(MB.html.ul()).appendTo(resultContainer.dialog);

        // Next/previous page
        var buttons = $.map([
            { text: MB.text.Next,     style: 'float: right' },
            { text: MB.text.Previous, style: 'float: left' }
        ], function(button) {
            return $(MB.html.button({}, button.text))
                .appendTo(resultContainer.dialog)
                .wrap(MB.html.div({ style: button.style }))
                .attr('disabled', 'disabled');
        });
        self.nextPage = buttons[0].click(function() { self.goToPage(currentPage + 1); });
        self.prevPage = buttons[1].click(function() { self.goToPage(currentPage - 1); });

        function clearResults() {
            results.empty();
        }

        function beforeSearch() {
            clearResults();
            info.html(MB.text.Searching);
            self.nextPage.attr('disabled', 'disabled');
            self.prevPage.attr('disabled', 'disabled');
        }

        function makeSelection(event) {
            event.preventDefault();
            var selected = $(event.target).closest('li').data('result');
            $(options.idInput).val(selected.id);
            self.query.val(selected.name);
            self.hideResults();

            if (options.selection) {
                options.selection(selected);
            }
        }

        function resultRow(result) {
            var contents = MB.html.strong({}, result.name);
            if(result.comment) {
                contents += ' (' + result.comment + ')'; 
            }
            if (result.sort_name) {
                contents += MB.html.br();
                contents += MB.html.span({ 'class': 'info' }, result.sort_name);
            }
            var row = $(MB.html.li({}, contents));
            return row.data('result', result).click(function(event) { makeSelection(event); });
        }

        function bodyClick(ev) {
            var elm = ev.target;
            while (elm &&
                   elm != resultContainer.dialog[0] &&
                   elm != self.query[0]) {
                elm = elm.parentNode;
            }
            if (!elm) {
                self.hideResults();
            }
        }

        function bindAutoHide() {
            $('html').click(bodyClick);
        }

        function unBindAutoHide() {
            $('html').unbind('click', bodyClick);
        }

        $.extend(self, {
            hideResults: function() {
                resultContainer.hide();
                unBindAutoHide();
            },
            showResults: function() {
                var inp = self.query;
                resultContainer.width = inp.width();
                resultContainer.showAt(inp);
                bindAutoHide();
            },
            clear: function() {
                clearResults();
                self.query.val('');
            },
            goToPage: function(page) {
                self.search(lastSearch, page);
                currentPage = page;
            },
            search: function(query, page) {
                var limit = options.limit;
                var offset = limit * (page - 1);
                lastSearch = query;

                $.ajax({
                    beforeSend: beforeSearch,
                    url: MB.url.EntityLookup.ajaxSearch,
                    error: function() {
                        info.html(MB.text.SearchErrorOccured);
                    },
                    success: function (searchResults) {
                        if (searchResults.hits) {
                            info.html(MB.text.SearchInfoFormat
                                      .replace('#matches#', searchResults.hits)
                                      .replace('#start#', offset + 1)
                                      .replace('#end#', offset + searchResults.results.length));

                            self.nextPage.attr('disabled',
                                               searchResults.hits > offset + limit ? null : 'disabled');
                            self.prevPage.attr('disabled', page > 1 ? null : 'disabled');

                            $.each(searchResults.results, function(i) {
                                results.append(
                                    resultRow(this).addClass(i % 2 ? 'even' : 'odd'));
                            });
                        }
                        else {
                            info.html(MB.text.NoResults);
                        }
                    },
                    data: {
                        type: type,
                        query: query,
                        offset: offset,
                        limit: limit
                    },
                    dataType: 'json'
                });
            }
        });
    };
})(MB);