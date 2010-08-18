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

MB.Control.ReleasePreviewDisc = function (fieldset) {
    var self = MB.Object ();

    self.table = $(fieldset).find('table.preview-changes');
    self.rows = self.table.children('tbody').children('tr');

    var sort = function () {
        self.rows.sort (function (rowa, rowb) {
            var a = parseInt ($(rowa).find ('td.position span.new').text ());
            var b = parseInt ($(rowb).find ('td.position span.new').text ());
            return a - b;
        });

        $.each (self.rows, function (idx, tr) {
            if (idx)
            {
                $(tr).insertAfter (self.rows[idx-1]);
            }
        });
    }

    self.sort = sort;

    self.sort ();

    return self;
};

MB.Control.ReleasePreview = function () {
    var self = MB.Object ();

    self.discs = [];

    $('fieldset.preview-changes-disc').each (function (idx, disc) {
        self.discs.push (MB.Control.ReleasePreviewDisc (disc));
    });

    return self;
};