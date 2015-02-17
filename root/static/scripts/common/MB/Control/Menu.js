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

MB.Control.HeaderMenu = function () {
    var self = {};

    self.timeout = null;
    self.timeout_msecs = 200;

    $('#header-menu > div > ul > li').bind('mouseenter.mb', function (event) {
        if (self.timeout) {
            clearTimeout(self.timeout);
            $('#header-menu ul li ul').css('left', '-10000px');
        }

        $(this).children('ul').css('left', 'auto');
    });

    $('#header-menu ul li').bind('mouseleave.mb', function (event) {
        var ul = $(this).children('ul');

        self.timeout = setTimeout(function () {
            ul.css('left', '-10000px');
        }, self.timeout_msecs);
    });

    return self;
}

$(document).ready(function () {
    MB.Control.header_menu = MB.Control.HeaderMenu();
});
