/*
 * Copyright (C) 2011 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

import MB from '../../MB';

MB.Control.HeaderMenu = function () {
  const self = {};

  function getLeft(li) {
    const $li = $(li);
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
    const ul = $(this).siblings('ul');
    $('.header ul.menu li ul').not(ul).css('left', '-10000px');
    const isClosing = ul.css('left') !== '-10000px';
    ul.css('left', isClosing ? '-10000px' : getLeft(this.parentNode));
    $('.header .menu-header').parent().removeClass('fake-active');
    if (!isClosing) {
      $(this).parent().toggleClass('fake-active');
    }
  });

  $('body').on('click', function () {
    /*
     * Clicks outside of the menu (anything that reaches the body) should
     * close the menu.
     */
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
