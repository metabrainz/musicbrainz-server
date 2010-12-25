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

    self.$name = $('#id-edit-artist\\.name');
    self.$sort_name = $('#id-edit-artist\\.sort_name');

    self.$guesscase = $('input.guesscase');
    self.$sortname = $('input.sortname');
    self.$copy = $('input.copy');

    var changeDateText = function (text) {
        self.$begin.text(text[0]);
        self.$end.text(text[1]);
    };

    /* Sets the label descriptions depending upon the artist type:

           Unknown: 0 
           Person: 1
           Group: 2
    */
    var typeChanged = function() {
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

    var enableGender = function() {
        self.$gender
           .attr("disabled", null)
           .val(self.old_gender);
    };

    var disableGender = function() {
        self.$gender.attr("disabled", "disabled");
        self.old_gender = self.$gender.val();
        self.$gender.val('');
    };

    var guesscase = function (event) {
        self.$name.val (MB.GuessCase.artist.guess (self.$name.val ()));

        event.preventDefault ();
    };

    var sortname = function (event) {
        var person = self.$type.val () !== '2';

        self.$sort_name.val (MB.GuessCase.artist.sortname (self.$name.val (), person));

        event.preventDefault ();
    };

    var copy = function (event) {
        self.$sort_name.val (self.$name.val ());

        event.preventDefault ();
    };

    self.changeDateText = changeDateText;
    self.typeChanged = typeChanged;

    self.guesscase = guesscase;
    self.sortname = sortname;
    self.copy = copy;
    self.enableGender = enableGender;
    self.disableGender = disableGender;

    self.typeChanged();
    self.$type.bind ('change.mb', self.typeChanged);
    self.$guesscase.bind ('click.mb', self.guesscase);
    self.$sortname.bind ('click.mb', self.sortname);
    self.$copy.bind ('click.mb', self.copy);

    return self;
};

