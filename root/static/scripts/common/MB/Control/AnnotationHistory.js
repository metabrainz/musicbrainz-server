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

MB.Control.AnnotationHistory = function (table) {
    var self = MB.Object ();

    var $table = $(table);

    self.reset = function () {
        var seenOld = false, seenNew = false;
        $table.find('tr').each(function(tr) {
            var $tr = $(this),
                $old = $tr.find('input.old'),
                $new = $tr.find('input.new');

            seenOld = seenOld || !!$old.prop('checked');

            $old.toggle(seenNew);
            $new.toggle(!seenOld);

            seenNew = seenNew || !!$new.prop('checked');
        });
    };

    self.reset();
    $table.find('input.old, input.new').change(self.reset);

    return self;
};
