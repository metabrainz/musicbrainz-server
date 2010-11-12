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

MB.Control.LabelEdit = function () {
    var self = MB.Object ();

    self.$name = $('#id-edit-label\\.name');
    self.$sort_name = $('#id-edit-label\\.sort_name');

    self.$guesscase = $('button.guesscase');
    self.$sortname = $('button.sortname');
    self.$copy = $('button.copy');

    var guesscase = function (event) {
        self.$name.val (self.guess_label.guess (self.$name.val ()));

        event.preventDefault ();
    };

    var sortname = function (event) {
        self.$sort_name.val (self.guess_label.sortname (self.$name.val ()));

        event.preventDefault ();
    };

    var copy = function (event) {
        self.$sort_name.val (self.$name.val ());

        event.preventDefault ();
    };

    self.guesscase = guesscase;
    self.sortname = sortname;
    self.copy = copy;

    self.guess_label = MB.GuessCase.Label ();

    self.$guesscase.bind ('click.mb', self.guesscase);
    self.$sortname.bind ('click.mb', self.sortname);
    self.$copy.bind ('click.mb', self.copy);

    return self;
};

