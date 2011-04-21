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

MB.Control.SelectAll = function (table) {
    var self = MB.Object ();

    self.$table = $(table);

    self.$table.find('th input[type="checkbox"]').change(function() {
        var $input = $(this);
        self.$table.find('td input[type="checkbox"]').attr('checked', $input.attr('checked'));
    });

    return self;
};

$(function() {
    $('table.tbl').each(function() {
        MB.Control.SelectAll(this)
    });
});
