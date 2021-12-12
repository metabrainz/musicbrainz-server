/*
 * Copyright (C) 2013 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

import ratingTooltip from '../../../utility/ratingTooltip';

$(document).on('click', 'span.star-rating a', function () {
  const $ratingLink = $(this);
  const url = this.href + '&json=1';

  $.getJSON(url, function (data) {
    let currentRatingSpan = $ratingLink.siblings('span');
    const container = $ratingLink.parent();
    if (!currentRatingSpan.length) {
      currentRatingSpan = $('<span/>');
      container.prepend(currentRatingSpan);
    }
    let rating;
    if (data.rating > 0) {
      // Use the user rating
      currentRatingSpan.removeClass('current-rating');
      currentRatingSpan.addClass('current-user-rating');
      rating = data.rating;
    } else {
      // Removed user rating, use the average rating instead
      currentRatingSpan.removeClass('current-user-rating');
      currentRatingSpan.addClass('current-rating');
      rating = data.rating_average;
    }
    if (rating) {
      // Update the width if we have some ratings
      currentRatingSpan.css('width', rating + '%');
      currentRatingSpan.text(5 * rating / 100);
    } else {
      // No ratings, remove it
      currentRatingSpan.remove();
    }

    // Take focus away from the clicked link as a visual indication
    container.focus();

    container.children('a').each(function (i) {
      const originalRating = 100 * (1 + i) / 5;
      const newRating = data.rating == originalRating
        ? 0
        : originalRating;
      const oldRatingMatch = this.href.match(/rating=(\d+)/);
      if (oldRatingMatch[1] != newRating) {
        this.href = this.href.replace(
          oldRatingMatch[0],
          'rating=' + newRating,
        );
        $(this).attr('title', ratingTooltip(5 * newRating / 100));
      }
    });
  });
  return false;
});
