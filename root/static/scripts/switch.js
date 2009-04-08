/************************************************************
 *  Adds switch toggle functionality for text fields
 *  that can be "locked".  Invoke with TT code such as:
 *      [%- INCLUDE 'forms/switchable.tt' object="artist_$i" 
 *       field=form.field("artist_$i") label=l('Artist') -%]
 ************************************************************/
$(document).ready(function(){
    $(".switchable").toggle();
    $("img, .switchable").bind("click", function(){
        if ($(this).attr("src") == "/static/images/release_editor/edit-off.gif") {
            $(this).attr({ 
                src: "/static/images/release_editor/edit-on.gif",
                title: "Change",
                alt: "Change"
            });
            $(this).nextAll("div").css("display", "inline");
        }
        else {
            $(this).attr({ 
                src: "/static/images/release_editor/edit-off.gif",
                title: "Set",
                alt: "Set"
            });
            $(this).nextAll("div").css("display", "none");
        }
        $(this).nextAll("span").toggle();
        $(this).nextAll("input").toggle();
    });
});
