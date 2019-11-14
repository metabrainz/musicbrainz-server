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

import $ from 'jquery';

import MB from '../../MB';

MB.Control.HeaderMenu = function () {
    var self = {};

    function getLeft(li) {
        var $li = $(li);
        if ($li.hasClass('language-selector')) {
            return '-' +
                ($li.children('ul:eq(0)').outerWidth() - $li.outerWidth()) +
                'px';
        }
        return 'auto';
    }

    $('.header .menu-header').on('click', function (event) {
        event.preventDefault();
        event.stopPropagation();
        var ul = $(this).siblings('ul');
        $('.header ul.menu li ul').not(ul).css('left', '-10000px');
        var isClosing = ul.css('left') !== '-10000px';
        ul.css('left', isClosing ? '-10000px' : getLeft(this.parentNode));
        $('.header .menu-header').parent().removeClass('fake-active');
        if (!isClosing) {
            $(this).parent().toggleClass('fake-active');
        }
    });

    $('body').on('click', function (event) {
        // clicks outside of the menu (anything that reaches the body) should
        // close the menu
        $('.header ul.menu li ul').css('left', '-10000px');
        $('.header .menu-header').parent().removeClass('fake-active');
    });

    $('ul.menu > li > ul').on('click', function (event) {
        // prevent clicks on the menu itself from reaching the body, per above
        event.stopPropagation();
    });

    return self;
};

$(document).ready(function () {
    MB.Control.header_menu = MB.Control.HeaderMenu();
});
