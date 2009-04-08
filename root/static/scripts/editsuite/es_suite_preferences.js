$(function() {
    $('#es-button6').click(function() {
        $("#es-sg-explain").text("Edit Suite server-stored preferences and debug information:");
        $(".esdisplay").hide();
        $("#es-pr").show();
        $("#javascript_preferences_toc").tabs();
    });
});
