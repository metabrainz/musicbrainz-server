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

MB.Control.EditSummary = function(container) {
    var self = MB.Object();

    var $container = $(container),
        $toggleEditNote = $container.find('.edit-note-toggle'),
        $editNote = $container.find('.add-edit-note'),
        $editNoteField = $editNote.find('textarea');

    self.addNote = function() {
        $toggleEditNote
            .html(MB.text.DeleteNote)
            .unbind('click').click(self.deleteNote);
        $editNote.show();
        $editNoteField.focus();
    };

    self.deleteNote = function() {
        $toggleEditNote
            .html(MB.text.AddNote)
            .unbind('click').click(self.addNote);
        $editNote.hide();
        $editNoteField.val('');
    };

    self.initialize = function() {
        $toggleEditNote.click(self.addNote);
    };

    self.initialize();
    return self;
};
