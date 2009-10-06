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

(function(MB) {
    MB.Control.InlineDialog = function(options) {
        var self = this;

        options = $.extend({
            parent: $('div.br'),
            minWidth: 300
        }, options);

        $.extend(self, {
            width: options.minWidth,

            dialog: $(MB.html.div({
                style: 'position: absolute',
                'class': 'dialog'
            })).hide(),

            showAt: function(control) {
                var offset = control.offset();
                var width = Math.max(options.minWidth, self.width);
                var right = offset.left + width;
                var maxRight = options.parent.offset().left + options.parent.outerWidth();

                if (right > maxRight) {
                    offset.left -= (right - maxRight);
                }

                self.dialog.css({
                    minWidth: width,
                    left: offset.left,
                    top: offset.top + control.get(0).offsetHeight,
                }).show();
            },

            hide: function() {
                self.dialog.hide();
            },
        });

        $('body').append(self.dialog);
    };
})(MB);