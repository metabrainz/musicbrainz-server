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
    self.$checkboxes = self.$table.find('td input[type="checkbox"]');
    self.lastChecked = null;

    self.$selector = self.$table.find('th input[type="checkbox"]');

    self.$selector.toggle(self.$checkboxes.length > 0);

    self.$selector.change(function() {
        var $input = $(this);
        self.$checkboxes.prop('checked', $input.prop('checked'));
    });

    self.$checkboxes.click(function(event) {
        if (event.shiftKey && self.lastChecked && self.lastChecked != this) {
            var first = self.$checkboxes.index(self.lastChecked),
                last = self.$checkboxes.index(this);

            if (first > last) {
                self.$checkboxes.slice(last, first + 1)
                    .prop('checked', this.checked);
            } else if (last > first) {
                self.$checkboxes.slice(first, last + 1)
                    .prop('checked', this.checked);
            }
        }
        self.lastChecked = this;
    });

    return self;
};

$(function() {
    $('table.tbl').each(function() {
        MB.Control.SelectAll(this)
    });
});
