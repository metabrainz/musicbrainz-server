/**************************************************
 *  Adds the show / hide sidebar functionality
 *************************************************/
// Store selection in cookie, turn on/off the sidebar
function flipSidebar() {
        $("span.toggle").toggle();
        switch($.cookie('sidebar'))
        {
            default:
            case 'on':
                $.cookie('sidebar', 'off');
                $('#content').css("margin-left","0px");
                $('#content').css("margin-top","15px");
                break;
            case 'off':
                $.cookie('sidebar', 'on');
                $('#content').css("margin-left","140px");
                $('#content').css("margin-top","0px");
        }
}

$(document).ready(function(){
    // Check that the sidebar is turned on in user
    // preferences).  Does nothing if it is off.
    if ($('#sidebar').length)
        $('#id_toggle_target').append(' \
            <span id="id_hide_toggle" class="toggle"> \
                <a href="javascript:flipSidebar()"> \
                    &nbsp;Hide Sidebar \
                </a> \
            </span> \
            <span id="id_show_toggle" style="display:none;" class="toggle"> \
                <a href="javascript:flipSidebar()"> \
                    &nbsp;Show Sidebar \
                </a> \
            </span> \
        ');
    // Make show / hide selection persistent
    switch($.cookie('sidebar'))
    {
        default:
            // Set the cookie the first time
                $.cookie('sidebar', 'on');
            break;
        case 'off':
            // Turn on the sidebar, swap toggle text
            $("span.toggle").toggle();
            $('#content').css("margin-left","0px");
            $('#content').css("margin-top","15px");
            break;
            // Turn off the sidebar, swap toggle text
        case 'on':
            $('#content').css("margin-top","0px");
    }
});