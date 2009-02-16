/* Small helpers for search result listings */

/* Note: Documentation on the headers toggle at 
         http://www.terminally-incoherent.com/blog/2008/09/29/jquery-tablesorter-list-of-builtin-parserssorters/
         Must be used on the Release Title column, as otherwise, it gets treated as a shortDate, and breaks.      */

$(document).ready(function() {
    /* Move the search results headers into a thead  */
    /* No need to put the rest of the rows into a tbody - modern browsers add it, if one is not included in
       the HTML.  If one is then added dynamically, you actually get a tbody in a tbody, and things break! */
    $(".searchresults:first").prepend('<thead id="resultsheader"></thead>');
    $(".searchresultsheader:first").appendTo("#resultsheader");
    /* Strip out unneeded style that would make the next line miss some columns */
    $(".searchresultsheader:first").each(function() {
        $(this).css("white-space", "");
    });
    /* Turn the old table cells into table header cells */
    $(".searchresultsheader:first").html($(".searchresultsheader:first").html().replace(/td.*?>/g, "th>"));
    /* Turn off centering for the new table header cells */
    $(".searchresultsheader:first th").each(function() {
        $(this).css("text-align", "left");
    });
    /* Take off the default search server "even" zebra striping */
    $(".searchresultseven").each(function() {
        $(this).removeClass("searchresultseven");
    });
    /* Turn on table sorting */
    $(".searchresults:first").tablesorter({
        textExtraction: "complex",
        headers: {
            1 : { sorter: "text" },
            2 : { sorter: "text" }
        }
    });
    /* Remove, then re-zebra stripe, the rows */
    $(".searchresults:first").each(function() {
        $(this).bind("sortStart",function() {
            jQuery(this).find(".searchresultsodd").each(function() {
                $(this).removeClass("searchresultsodd");
            });
        }).bind("sortEnd",function() {
            jQuery(this).find("tr:odd").each(function() {
                $(this).addClass("searchresultsodd");
            });
        });
    });
});
