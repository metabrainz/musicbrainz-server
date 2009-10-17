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
    $.extend(MB.url, {
        ToggleButton: {
            defaultOn: '/static/images/release_editor/edit-on.png',
            defaultOff: '/static/images/release_editor/edit-off.png'
        }
    });

    MB.Control.ToggleButton = function(options) {
        var self = this;

        options = $.extend({
            defaultOn: input ? input.is(':checked') : false,
            toggleOn: undefined,
            toggleOff: undefined,
            onImage: MB.url.ToggleButton.defaultOn,
            offImage: MB.url.ToggleButton.defaultOff
        }, options);

        var state = options.defaultOn;
        var input;

        self.image = $(MB.html.img({
            'class': 'image-button',
            src: state ? options.onImage : options.offImage
        }));

        $.extend(self, {
            toggle: function() {
                state = !state;
                updateImage();
                updateCheckbox();
                fireCallback();
            },
            checked: function() {
                return state;
            },
            draw: function(checkbox) {
                input = $(checkbox);
                updateCheckbox();
                self.image.click(function() { self.toggle(); });
                input.hide().after(self.image);
            }
        });

        function updateImage() {
            self.image.attr('src', state ? options.onImage : options.offImage);
        }

        function updateCheckbox() {
            input.attr('checked', state ? 'checked' : false);
        }

        function fireCallback() {
            var callback = options[ state ? 'toggleOn' : 'toggleOff' ];
            if (callback) {
                callback();
            }
        }
    };
})(MB);