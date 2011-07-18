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

MB.Control.ArtistEdit = function () {
    var self = MB.Object ();

    self.$begin  = $('#label-edit-artist\\.begin_date');
    self.$end    = $('#label-edit-artist\\.end_date');
    self.$type   = $('#id-edit-artist\\.type_id');
    self.$gender = $('#id-edit-artist\\.gender_id');
    self.old_gender = self.$gender.val();

    self.changeDateText = function (text) {
        self.$begin.text(text[0]);
        self.$end.text(text[1]);
    };

    /* Sets the label descriptions depending upon the artist type:

           Unknown: 0 
           Person: 1
           Group: 2
    */
    self.typeChanged = function() {
        switch (self.$type.val()) {
            default:
            case '0':
                self.changeDateText(MB.text.ArtistDate.Unknown);
                self.enableGender();
                break;

            case '1':
                self.changeDateText(MB.text.ArtistDate.Person);
                self.enableGender();
                break;

            case '2':
                self.changeDateText(MB.text.ArtistDate.Founded);
                self.disableGender();
                break;
        }
    };

    self.enableGender = function() {
        if (self.$gender.attr('disabled')) {
            self.$gender
               .attr("disabled", null)
               .val(self.old_gender);
        }
    };

    self.disableGender = function() {
        self.$gender.attr("disabled", "disabled");
        self.old_gender = self.$gender.val();
        self.$gender.val('');
    };

    self.typeChanged();
    self.$type.bind ('change.mb', self.typeChanged);

    return self;
};

