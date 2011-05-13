/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2011 MetaBrainz Foundation

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

MB.Control.AttachTOC = function () {
    var self = MB.Object();

    self.$input = $('span.autocomplete input.entity');
    self.$form = $('#attach-to-release');
    self.$submit = self.$form.find ('button[type=submit]');

    self.select = function (event, data) {
        self.$input.val (data.name);
        self.$form.attr ('action', '/release/' + data.gid + '/edit');
        self.$submit.removeClass ('disabled');
    };

    self.autocomplete = MB.Control.Autocomplete ({
        'entity': 'release',
        'input': self.$input,
        'select': self.select,
    });

    return self;
};
