/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2012 Lukas Lalinsky

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

MB.Control.FilterButton = function () {
    var self = MB.Object ();

    self.show = function () {
        if (self.loaded) {
            self.$filter.show ();
            self.state = true;
            $.cookie ('filter', '1', { path: '/' });
        }
        else {
            $.ajax ({
                url: self.filter_ajax_form_url,
                success: function (data) {
                    self.$filter.find ('input[type=hidden]').before ($.parseHTML(data));
                    self.show ();
                }
            });
            self.loaded = true;
        }
    }

    self.hide = function () {
        self.$filter.hide ();
        self.state = false;
        $.cookie ('filter', '', { path: '/' });
    }

    self.filter_ajax_form_url = $('#filter_ajax_form_url').val ();
    self.$filter = $('#filter');
    self.loaded = self.$filter.find ('button').length > 0;
    self.state = $.cookie ('filter') == '1';

    $('.filter-button').bind ('click.mb', function () {
        if (self.state) {
            self.hide ();
        }
        else {
            self.show ();
        }
        return false;
    });

    if (self.state) {
        self.show ();
    }
    else {
        self.hide ();
    }

    return self;
}

$(document).ready (function() {
    MB.Control.filter_button = MB.Control.FilterButton ();
});

