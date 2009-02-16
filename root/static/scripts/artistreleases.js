/* Small helpers for viewing artist release listings */

/* Note: Documentation on the headers toggle at 
         http://www.terminally-incoherent.com/blog/2008/09/29/jquery-tablesorter-list-of-builtin-parserssorters/
         Must be used on the Release Title column, as otherwise, it gets treated as a shortDate, and breaks.      */

$(document).ready(function() {
    /* Turn on table sorting */
    $(".releases").tablesorter({
        textExtraction: "complex",
        headers: { 0 : { sorter: "text"  } }
    });
    /* Remove, then re-zebra stripe, the rows */
    $(".releases").each(function() {
        $(this).bind("sortStart",function() {
            jQuery(this).find(".odd").each(function() {
                $(this).removeClass("odd");
            });
        }).bind("sortEnd",function() {
            jQuery(this).find("tr:odd").each(function() {
                $(this).addClass("odd");
            });
        });
    });
});
