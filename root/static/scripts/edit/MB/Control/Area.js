/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2013 MetaBrainz Foundation

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

MB.Control.Area = function (span, bubbles) {
    var self = MB.Object();

    self.$span = $(span);
    self.$name = self.$span.find('input.name');
    self.bubble = bubbles.add (self.$span, $('div.area.bubble'));

    MB.Control.EntityAutocomplete ({
        inputs: self.$span
    });

    self.$name.bind('focus.mb', function(event) {
        var gid = self.$span.find('input.gid').val();
        if (gid)
        {
            self.bubble.show ();
            self.bubble.$content.find ('a.area')
                .attr ('href', '/area/' + gid)
                .text (self.$name.val ());
        }
        else
        {
            self.bubble.hide ();
        }
    });
};
