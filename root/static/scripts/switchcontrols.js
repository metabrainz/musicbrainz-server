/************************************************************
 *  Adds switch toggle controls box functionality
 *  Place the next line wherever the control box should 
 *      <div id="form-controls"></div>
 ************************************************************/

/* NOTE: form-controls-button-showhide button controls not yet written.  Need the edit_release and add_release pages 
to be done to know what exactly is hidden, and in need of revealing. */

$(document).ready(function(){
    $("#form-controls").append(' \
        <input type="button" id="form-controls-button-showhide" value="' + text.ShowTrackArtists + '"/> \
        <input type="button" id="form-controls-button-editall" value="' + text.EditAllTrackArtists + '"/> \
    ');
    $("#form-controls-button-editall").bind("click", function(){
        $(".switchable").each(function(){
            if ($(this).attr("src") == "/static/images/release_editor/edit-off.gif") {
                $(this).nextAll("span").toggle();
                $(this).nextAll("input").toggle();
                $(this).attr({ 
                    src: "/static/images/release_editor/edit-on.gif",
                    title: "' + text.Change + '",
                    alt: "' + text.Change + '"
                })
                $(this).nextAll("div").css("display", "inline");
            }
            $("#form-controls-button-editall").unbind("click");
            $("#form-controls-button-editall").attr("disabled", "true");
        })
    })
});
