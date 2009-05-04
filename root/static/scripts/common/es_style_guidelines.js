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
                    $("#es-sg").load(oldtarget.replace(/\/doc\/(.*)"\s/g, '/doc/$1/bare" '));
                    fixLinks();
                });
            });
        }
    });
}
$(function() {
    /* -------------------------------------------------------------------------*/
    /* Turn on show/hide functionality
    /* -------------------------------------------------------------------------*/
    $("#js-fieldset-sg-trigger-show").click(function() {
        $("#js-fieldset-sg").removeClass("hidden");
        $("#js-fieldset-sg-row").removeClass("floatRight");
        $("#js-fieldset-sg-trigger-hide").removeClass("hidden");
        $("#js-fieldset-sg-trigger-show").addClass("hidden");
    });
    $("#js-fieldset-sg-trigger-hide").click(function() {
        $("#es-sg").css({"height" : "0px"});
        $("#es-sg").empty();
        $("#js-fieldset-sg").addClass("hidden");
        $("#js-fieldset-sg-row").addClass("floatRight");
        $("#js-fieldset-sg-trigger-show").removeClass("hidden");
        $("#js-fieldset-sg-trigger-hide").addClass("hidden");
    });
    $("#js-fieldset-sg-row").addClass("floatRight");
    var loadGuideline = function(selection) {
        jQuery(function($) {
            $("#es-sg").load("/doc/" + selection + "/bare/");
        });
        $("#es-sg").css({"height" : "450px"});
    };
    $("#es-sg-guidelines").blur(function() {
        loadGuideline($("#es-sg-guidelines").val())
    });
    $("#es-sg-guidelines").keyup(function() {
        loadGuideline($("#es-sg-guidelines").val())
    });
    $("#es-sg-capitalization").blur(function() {
        loadGuideline($("#es-sg-capitalization").val())
    });
    $("#es-sg-capitalization").keyup(function() {
        loadGuideline($("#es-sg-capitalization").val())
    });
    $("#es-sg").bind("ajaxSend", function(){
        $("#es-sg-explain").html('<img src="/static/images/throbber.gif" /> ' + text.Loading + '&hellip;').fadeIn("1000");
    }).bind("ajaxStop", function(){
        fixLinks();
        $("#es-sg-explain").html(text.Loaded);
    });
});
