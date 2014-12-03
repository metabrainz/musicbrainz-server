// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

$(function () {
  var $bottomCredits = $('#bottom-credits');
  var bottomCreditsEnabled = $.cookie('bottom-credits') === '1';
  var hasReleaseCredits = !!$('#release-relationships, #release-group-relationships').length;

  function switchToInlineCredits() {
    $('.bottom-credits').hide();
    $('table.tbl div.ars').show();
    $bottomCredits.toggle(hasReleaseCredits);

    $toggle.text(MB.text.DisplayCreditsAtBottom);
    $.cookie('bottom-credits', '0', { path: '/', expires: 365 });
  }

  function switchToBottomCredits() {
    $('table.tbl div.ars').hide();
    $('.bottom-credits').show();
    $bottomCredits.show();

    $toggle.text(MB.text.DisplayCreditsInline);
    $.cookie('bottom-credits', '1', { path: '/', expires: 365 });
  }

  var $toggle = $('#toggle-credits').on('click', function () {
    bottomCreditsEnabled ? switchToInlineCredits() : switchToBottomCredits();
    bottomCreditsEnabled = !bottomCreditsEnabled;
  });

  bottomCreditsEnabled ? switchToBottomCredits() : switchToInlineCredits();

  $(document).on('click', '.expand-medium', function () {
    var $table = $(this).parents('table:first');
    var $tbody = $table.children('tbody');
    var $triangle = $table.find('.expand-triangle');

    if ($tbody.length) {
      $tbody.toggle();
      $triangle.html($tbody.is(':visible') ? '&#x25BC' : '&#x25B6');
      return false;
    }

    $triangle.html('&#x25BC');
    $tbody = $('<tbody><tr><td></td></tr></tbody>').appendTo($table);

    var $message = $('<div>')
      .appendTo($tbody.find('td'))
      .addClass('loading-message')
      .text(MB.text.Loading);

    var mediumId = this.getAttribute('data-medium-id');

    $.get('/medium/' + mediumId + '/fragments')
      .done(function (fragments) {
        var $fragments = $($.parseHTML(fragments));

        var $tracks = $fragments.filter('table').children('tbody');
        var $credits = $fragments.filter('div').toggle(bottomCreditsEnabled);

        $tracks.find('div.ars').toggle(!bottomCreditsEnabled);
        $tbody.replaceWith($tracks);

        var position = $credits.data('position');
        var insertAfter;

        $bottomCredits.find('.bottom-credits').each(function (index, other) {
          var $other = $(other);

          if (position > $other.data('position')) {
            insertAfter = $other;
          } else {
            return false;
          }
        });

        insertAfter ? $credits.insertAfter(insertAfter) : $bottomCredits.find('h2').after($credits);
      })
      .fail(function () {
        $message.removeClass('loading-message').text(MB.text.FailedToLoadMedium);
      });

    // Prevent browser from following link
    return false;
  });
});
