/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

import request from '../common/utility/request';
import getBooleanCookie from '../common/utility/getBooleanCookie';
import setCookie from '../common/utility/setCookie';

$(function () {
  var $bottomCredits = $('#bottom-credits');
  var bottomCreditsEnabled = getBooleanCookie('bottom-credits');
  var hasReleaseCredits =
    !!$('#release-relationships, #release-group-relationships').length;

  function switchToInlineCredits() {
    $('.bottom-credits').hide();
    $('table.tbl div.ars').show();
    $bottomCredits.toggle(hasReleaseCredits);

    $toggle.text(l('Display Credits at Bottom'));
    setCookie('bottom-credits', 0);
  }

  function switchToBottomCredits() {
    $('table.tbl div.ars').hide();
    $('.bottom-credits').show();
    $bottomCredits.show();

    $toggle.text(l('Display Credits Inline'));
    setCookie('bottom-credits', 1);
  }

  var $toggle = $('#toggle-credits').on('click', function () {
    bottomCreditsEnabled ? switchToInlineCredits() : switchToBottomCredits();
    bottomCreditsEnabled = !bottomCreditsEnabled;
  });

  bottomCreditsEnabled ? switchToBottomCredits() : switchToInlineCredits();

  function expandOrCollapseMedium(element) {
    var $table = $(element).parents('table:first');
    var $tbody = $table.children('tbody');
    var $triangle = $table.find('.expand-triangle');

    if ($tbody.length) {
      $tbody.toggle();
      $triangle.html($tbody.is(':visible') ? '&#x25BC;' : '&#x25B6;');
      return false;
    }

    $triangle.html('&#x25BC;');
    $tbody = $('<tbody><tr><td></td></tr></tbody>').appendTo($table);

    var $message = $('<div>')
      .appendTo($tbody.find('td'))
      .addClass('loading-message')
      .text(l('Loading...'));

    var mediumId = element.data('medium-id');

    request({url: '/medium/' + mediumId + '/fragments', dataType: 'html'})
      .done(function (fragments) {
        var $fragments = $($.parseHTML(fragments));

        var $tracks = $fragments.filter('table').children('tbody');
        var $credits = $fragments.filter('div').toggle(bottomCreditsEnabled);

        $tracks.find('div.ars').toggle(!bottomCreditsEnabled);
        $tbody.replaceWith($tracks);

        if ($credits.find('table.details').children().length) {
          var position = $credits.data('position');
          var insertAfter;

          $bottomCredits.find('.bottom-credits')
            .each(function (index, other) {
              var $other = $(other);

              if (position > $other.data('position')) {
                insertAfter = $other;
                return true;
              }

              return false; // prematurely stop iterating
            });

          insertAfter
            ? $credits.insertAfter(insertAfter)
            : $bottomCredits.find('h2').after($credits);
        }
      })
      .fail(function () {
        $message.removeClass('loading-message')
          .text(l('Failed to load the medium.'));
      });

    return false;
  }

  $(document).on('click', '.expand-medium', function () {
    expandOrCollapseMedium($(this));
    // Prevent browser from following link
    return false;
  });

  $(document).on('click', '#expand-all-mediums', function () {
    $('.expand-medium').each(function () {
      const $table = $(this).parents('table:first');
      const $tbody = $table.children('tbody');
      if (!$tbody.length || $tbody.is(':hidden')) {
        expandOrCollapseMedium($(this));
      }
    });
    // Prevent browser from following link
    return false;
  });

  $(document).on('click', '#collapse-all-mediums', function () {
    $('.expand-medium').each(function () {
      const $table = $(this).parents('table:first');
      const $tbody = $table.children('tbody');
      if ($tbody.is(':visible')) {
        expandOrCollapseMedium($(this));
      }
    });
    // Prevent browser from following link
    return false;
  });
});
