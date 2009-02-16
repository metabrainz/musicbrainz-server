$(document).ready(function() {
    /* Make the table sortable. */
    $("thead").toggle();
    $(".release_tracks").tablesorter({
        textExtraction: "complex"
    });
});
