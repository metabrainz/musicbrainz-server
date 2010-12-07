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

MB.Control.EditNote = function(textarea) {
    var self = MB.Object();

    var $editNoteField = $(textarea);
    
    self.takeFocus = function () {
        $editNoteField.attr('rows', 5);
    };

    self.loseFocus = function() {
        if(!$editNoteField.val() ||
            $editNoteField.attr('placeholder') === $editNoteField.val())
            $editNoteField.attr('rows', 1);
    };

    self.initialize = function() {
        $editNoteField
            .focus(self.takeFocus)
            .blur(self.loseFocus);
    };

    self.initialize();
    return self;
};

