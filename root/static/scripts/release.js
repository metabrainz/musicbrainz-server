/* Small helpers for viewing releases */

$(document).ready(function() {
    $('#toggle_discids').click(function() {
        $('#release_discids').slideToggle("normal", function() {
            $('#toggle_discids').text(this.style.display == 'none' ?
                                      'Show Disc IDs' :
                                      'Hide Disc IDs');
        });
        return false;
    });

    $('#toggle_artists').click(function() {
        $('.release_tracks .artist').toggle();
        return false;
    });
});