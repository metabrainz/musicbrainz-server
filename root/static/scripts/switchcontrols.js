/************************************************************
 *  Adds switch toggle controls box functionality
 *  Place the next line wherever the control box should 
 *      <div id="form-controls"></div>
 ************************************************************/

/* NOTE: form-controls-button-showhide button controls not yet written.  Need the edit_release and add_release pages 
to be done to know what exactly is hidden, and in need of revealing. */

$(document).ready(function(){
    $("#form-controls").append(' \
        <div class="row no_label"> \
            <button type="button" id="form-controls-button-showhide">Show Track Artists</button> \
            <button type="button" id="form-controls-button-editall">Edit all Track Artists</button> \
        </div> \
    ');
    $("#form-controls-button-editall").bind("click", function(){
        $(".switchable").each(function(){
            if ($(this).attr("src") == "/static/images/release_editor/edit-off.gif") {
                $(this).nextAll("span").toggle();
                $(this).nextAll("input").toggle();
                $(this).attr({ 
                    src: "/static/images/release_editor/edit-on.gif",
                    title: "Change",
                    alt: "Change"
                })
                $(this).nextAll("div").css("display", "inline");
            }
            $("#form-controls-button-editall").unbind("click");
            $("#form-controls-button-editall").attr("disabled", "true");
        })
    })
});
