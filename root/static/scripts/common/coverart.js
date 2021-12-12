/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

$(function () {
  $('.cover-art-image').each(function () {
    const $e = $(this);
    const thumbnailUrl = window.devicePixelRatio > 1
      ? $e.data('large-thumbnail')
      : $e.data('small-thumbnail');

    $('<img />')
      .bind('error', function () {
        if ($e.data('fallback') && $e.attr('src') === thumbnailUrl) {
          $e.attr('src', $e.data('fallback'));
        } else {
          $e.closest('a')
            .replaceWith('<em>' + $e.data('message') + '</em>');
        }
      })
      .attr({
        src: thumbnailUrl,
        title: $e.data('title'),
      })
      .appendTo(this);
  });
});
