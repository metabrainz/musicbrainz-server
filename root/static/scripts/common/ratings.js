// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2013 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import $ from 'jquery';

import ratingTooltip from '../../../utility/ratingTooltip';

$(document).on("click", "span.star-rating a", function () {
    var $ratingLink = $(this);
    var url = this.href + '&json=1';

    $.getJSON(url, function (data) {
        var currentRatingSpan = $ratingLink.siblings('span');
        var container = $ratingLink.parent();
        if (!currentRatingSpan.length) {
            currentRatingSpan = $('<span/>');
            container.prepend(currentRatingSpan);
        }
        var rating;
        if (data.rating > 0) {
            // Use the user rating
            currentRatingSpan.removeClass('current-rating');
            currentRatingSpan.addClass('current-user-rating');
            rating = data.rating;
        }
        else {
            // Removed user rating, use the average rating instead
            currentRatingSpan.removeClass('current-user-rating');
            currentRatingSpan.addClass('current-rating');
            rating = data.rating_average;
        }
        if (rating) {
            // Update the width if we have some ratings
            currentRatingSpan.css('width', rating + '%');
            currentRatingSpan.text(5 * rating / 100);
        }
        else {
            // No ratings, remove it
            currentRatingSpan.remove();
        }

        // Take focus away from the clicked link as a visual indication
        container.focus();

        container.children('a').each(function (i) {
            var originalRating = 100 * (1 + i) / 5;
            var newRating = data.rating == originalRating
                ? 0
                : originalRating;
            var oldRatingMatch = this.href.match(/rating=(\d+)/);
            if (oldRatingMatch[1] != newRating)
            {
                this.href = this.href.replace(
                    oldRatingMatch[0],
                    'rating=' + newRating,
                );
                $(this).attr('title', ratingTooltip(5 * newRating / 100));
            }
        });
    })
    return false;
});
