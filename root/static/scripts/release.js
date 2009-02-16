/* Small helpers for viewing releases */

$(document).ready(function() {
    /* Toggle Disc IDs via the show/hide Disc IDs link. */
    $('#toggle_discids').click(function() {
        $('#release_discids').slideToggle("normal", function() {
            $('#toggle_discids').text(this.style.display == 'none' ?
                                      'Show Disc IDs' :
                                      'Hide Disc IDs');
        });
        return false;
    });
    /* Toggle artists via the show/hide artists link. */
    $('#toggle_artists').click(function() {
        var showHideLink = $('#toggle_artists');
        showHideLink.unbind("click");
        showHideLink.text("Hide Artists");
        showHideLink.removeAttr("href");
        showHideLink.css("cursor","pointer"); 
        showHideLink.bind("click", function() {
            if(showHideLink.text() == "Show Artists") {
                showHideLink.text("Hide Artists");
            }
            else {
               showHideLink.text("Show Artists");
            }
            $('#col-artist, .release_tracks .artist' ).toggle();
        });
        showHideLink.trigger("click");
    });
    /* Make the table sortable. */
    $("thead").toggle();
    $(".release_tracks").tablesorter({
        textExtraction: "complex",
        headers: { 4: { sorter: false}}
    });
});
