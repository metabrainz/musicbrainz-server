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

            var currentStar = ".stars-" + (5 * rating / 100);

            ratingLink.parent().find(".remove-rating").not(currentStar).hide ();
            ratingLink.parent().find(".remove-rating" + currentStar).show ();
            ratingLink.parent().find(".set-rating" + currentStar).hide ();
            ratingLink.parent().find(".set-rating").not(currentStar).show ();
        })
        return false;
    });

});
