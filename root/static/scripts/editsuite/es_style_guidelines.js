/*********************************************************
   Capture all anchor links within loaded WikiDoc pages
   so they 1) load the /bare version, and 2) load within
   the DIV, and don't browse the user away from the edit
   page.
*********************************************************/
function fixLinks() {
    $("#es-sg a").each(function() {
        if ($(this).attr("href") !== undefined) {
            var oldtarget = $(this).attr("href");
            $(this).click(function(e) {
                e.preventDefault();
                $("#es-sg").empty();
                jQuery(function($) {
                    $("#es-sg").load(oldtarget.replace('/doc/', '/doc/bare/'));
                    fixLinks();
                });
            });
        }
    });
}
$(function() {
    $('#es-button5').click(function() {
        $("#es-sg-explain").text(text.PickGuideline);
        $(".esdisplay").hide();
        $("#es-sg-select").show();
        $("#es-sg-select").friendlyselect();
        $("#es-sg").show();
    });
    $("#es-sg-select").change(function() {
        if ($('#es-sg-selection').val() != "none") {
            $("#es-sg").empty();
            $("#es-sg-throbber").hide();
            $("#es-sg-error").hide();
            $("#es-sg").show();
            jQuery(function($) {
                $("#es-sg").load("/doc/bare/" + $('#es-sg-selection').val());
            });
        }
    });
    $().ajaxStart(function() {
        $("#es-sg-explain").html('<img src="/static/images/throbber.gif" /> ' + text.Loading + '&hellip;').fadeIn("1000");
    });
});
