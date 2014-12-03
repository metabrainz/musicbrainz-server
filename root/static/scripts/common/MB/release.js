// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

$(function () {
  var bottomCreditsEnabled = $.cookie('bottom-credits') === '1';

  function showBottomCredits($table) {
    $table.find('div.ars').hide();
    $table.find('tr.bottom-credits').show();
  }

  function showInlineCredits($table) {
    $table.find('tr.bottom-credits').hide();
    $table.find('div.ars').show();
  }

  function switchToInlineCredits() {
    showInlineCredits($('table.tbl'));
    $toggle.text(MB.text.DisplayCreditsAtBottom);
    $.cookie('bottom-credits', '0', { path: '/', expires: 365 });
  }

  function switchToBottomCredits() {
    showBottomCredits($('table.tbl'));
    $toggle.text(MB.text.DisplayCreditsInline);
    $.cookie('bottom-credits', '1', { path: '/', expires: 365 });
  }

  var $toggle = $('#toggle-credits').on('click', function () {
    bottomCreditsEnabled ? switchToInlineCredits() : switchToBottomCredits();
    bottomCreditsEnabled = !bottomCreditsEnabled;
  });

  bottomCreditsEnabled ? switchToBottomCredits() : switchToInlineCredits();

  $(document).on('click', '.expand-medium', function () {
    var $table = $(this).parents("table:first");
    var $tbody = $table.children("tbody");
    var $triangle = $table.find(".expand-triangle");

    if ($tbody.length) {
      $tbody.toggle();
      $triangle.html($tbody.is(':visible') ? '&#x25BC' : '&#x25B6');

    } else if (!$table.data('loading')) {
      $table.data('loading', true);
      $triangle.html('&#x25BC');

      var $loading = $('<div>').addClass('loading-message').text(MB.text.Loading).insertAfter($table)
      var mediumId = this.getAttribute('data-medium-id');

      $.get('/medium/' + mediumId + '/fragment')
        .always(function () {
          $table.data('loading', false);
          $loading.remove();
        })
        .done(function (fragment) {
          $table.append(fragment);

          bottomCreditsEnabled ? showBottomCredits($table) : showInlineCredits($table);
        })
        .fail(function () {
          $("<div>").text(MB.text.FailedToLoadMedium).insertAfter($table);
        });
    }

    // Prevent browser from following link
    return false;
  });
});
