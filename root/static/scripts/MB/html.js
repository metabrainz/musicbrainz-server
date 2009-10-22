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

(function (MB) {
    MB.html = function () {
        var self = {};

        var supportedTags = (
            'a br button dd div img input label li span strong ' +
            'table tbody td th thead tr ul'
        ).split(' ');

        function formatAttributes(attributes) {
            if (!attributes || attributes.length == 0) { return ''; }
            var formatted = [];
            var key, value;
            for(key in attributes) {
                if(attributes.hasOwnProperty(key)) {
                    value = attributes[key];
                    if (value) {
                        formatted.push(key + '="' + self.escape(value) + '"');
                    }
                }
            }
            return formatted.join(' ');
        }

        function createTag(element) {
            return function (attributes, content) {
                var attrs = formatAttributes(attributes);
                var ret = '<' + element + (attrs ? ' ' + attrs : '');
                ret += content && content.length ? '>' + content + '</' + element + '>' : ' />';
                return ret;
            };
        }

        $.each(supportedTags, function() { self[this] = createTag(this); });

        self.escape = function(html) {
            return html.toString()
                .replace(/&/g, '&amp;')
                .replace(/>/g, '&gt;')
                .replace(/</g, '&lt;')
                .replace(/"/g, '&quot;');
        };

        return self;
    }();
})(MB);