$(document).ready (function() {

    $('.only-if-no-javascript').hide ();

    // Ratings
    $('span.star-rating a').click(function() {
        var ratingLink = $(this);
        var url = this.href + '&json=1';
        $.getJSON(url, function(data) {
            var currentRatingSpan = ratingLink.siblings('span');
            if (!currentRatingSpan.length) {
                currentRatingSpan = $('<span/>');
                ratingLink.parent().prepend(currentRatingSpan);
            }
            var rating;
            if (data.rating) {
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

            ratingLink.parent().children('a').each (function (i) {
                var originalRating = 100 * (1 + i) / 5;
                var newRating = data.rating == originalRating ? 0 : originalRating;
                var oldRatingMatch = this.href.match(/rating=(\d+)/);
                if (oldRatingMatch[1] != newRating)
                {
                    this.href = this.href.replace(oldRatingMatch[0], 'rating=' + newRating);
                    $(this).attr ('title', MB.text.RatingTitles[5 * newRating / 100]);
                }
            });

        })
        return false;
    });

    $('.annotation-collapse').each(function(){
        if ($(this).height() > 100) {
            $(this).removeClass('annotation-collapse');
            $(this).addClass('annotation-collapsed');
            $(this).after('<p><a href="javascript:void(0)" class="annotation-toggle">Show more...</a></p>');
        }
    });

    $(".annotation-toggle").click(function(){
        if ($(this).parent().prev().hasClass('annotation-collapsed')) {
            $(this).parent().prev().removeClass('annotation-collapsed');
            $(this).parent().prev().addClass('annotation-collapse');
            $(this).text('Show less...');
        } else {
            $(this).parent().prev().removeClass('annotation-collapse');
            $(this).parent().prev().addClass('annotation-collapsed');
            $(this).text('Show more...');
        }
    });
});
