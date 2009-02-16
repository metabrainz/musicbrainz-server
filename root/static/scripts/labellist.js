/* Small helpers for viewing label release listings */

/* Note: Documentation on the headers toggle at 
         http://www.terminally-incoherent.com/blog/2008/09/29/jquery-tablesorter-list-of-builtin-parserssorters/
         Must be used on the Release Title column, as otherwise, it gets treated as a shortDate, and breaks.      */

$(document).ready(function() {
    /* Turn on table sorting */
    $("#label-release-list").tablesorter({
        textExtraction: "complex",
        headers: {
            0 : { sorter: "digit" },
            1 : { sorter: "text" },
            2 : { sorter: "text" },
            3 : { sorter: "isoDate" },
            4 : { sorter: "text" },
            5 : { sorter: "text" },
            6 : { sorter: "text" }
        }
    });
    /* Remove, then re-zebra stripe, the rows */
    $("#label-release-list").each(function() {
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
