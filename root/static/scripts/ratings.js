    $(document).ready(function() {
        //There is a star-rating class that contains 5 anchor tags for the stars
        $(".star-rating a").bind('click',function() {
            //Extract variables from the URL
            var t = this.href.split('/');
            var rating = t[t.length - 1];
            var entityid = t[t.length - 2];
            var entitytype = t[t.length - 3];

            var url = "/rating/rate/" + entitytype + "/" + entityid 
                        + "/" + rating  + "?JSON=1";
            $.getJSON(url, function (newRatingInfo) {
                //search returns an array so get the first element (of a one element array)
                var rating = $("#RATING-"+entitytype+"-"+entityid)[0];

                // If user has canceled his rating, display community ratings
                if (newRatingInfo.user_rating == 0) {
                        rating.className = "current-rating";
                    rating.innerHTML = newRatingInfo.average_rating;
                        rating.style.width = newRatingInfo.average_rating/5*100+'%'; 
                }
                // Otherwise, display only his rating
                else {
                        rating.className = "current-user-rating";
                    rating.innerHTML = newRatingInfo.user_rating;
                        rating.style.width = newRatingInfo.user_rating/5*100+'%'; 
                    
                }

                for (var i=1 ; i<=5 ; i++) {
                    //Get the 1st (and only) "a" tag inside the tag with id RATE-...etc
                        var rateLink = $("#RATE-" + entitytype + "-" + entityid + "-" + i + " a")[0];

                    //take the old vote off the url
                    var href1 = rateLink.href.slice(0, -1);

                    var newRating = (i == newRatingInfo.user_rating) ? "0" : i;
                    var href = href1 + newRating;
                        var text = (i == newRatingInfo.user_rating) ? "Unrate this "+entitytype : "Rate this "+entitytype+": "+i;
                        rateLink.alt = text;
                        rateLink.title = text;
                    rateLink.href = href;
                }

                // number of Votes - another one element array
                var totalVotes = $("#VOTES-RATING-" + entitytype + "-" + entityid)[0];
                if (totalVotes) {
                    if ( newRatingInfo.rating_count == null) {
                        totalVotes.innerHTML = 0;
                    } else {
                        totalVotes.innerHTML = newRatingInfo.rating_count+" time"+(newRatingInfo.rating_count == 1 ? "": "s");
                    }
                }

                // Average rating
                var communityRating = $("#COMMUNITY-RATING-"+entitytype+"-"+entityid)[0];
                if (communityRating) {
                    if ( newRatingInfo.rating_count == null ) {
                            communityRating.innerHTML = 'none';
                    } else {
                        communityRating.innerHTML = Math.round(newRatingInfo.average_rating*100)/100;
                    }
                }

                return false;

            });
            return false;
        });

        return false;
    });
