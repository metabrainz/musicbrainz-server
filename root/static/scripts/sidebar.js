/**************************************************
 *  Adds the show / hide sidebar functionality
 *************************************************/
// Store selection in cookie, turn on/off the sidebar
function flipSidebar() {
        $("#sidebartoggle, #sidebar-hide-toggle, #sidebar-show-toggle").toggle();
        switch($.cookie('sidebar'))
        {
            case 'off':
                $.cookie('sidebar', 'on', { expires: 15000 });
                $('#container').css("width","90%");
                $('#container').css("margin-top","0px");
                break;
            case 'on':
            default:
                $.cookie('sidebar', 'off', { expires: 15000 });
                $('#container').css("width","100%");
                $('#container').css("margin-top","15px");
        }
}

$(document).ready(function(){
    // Check that the sidebar is turned on in user
    // preferences).  Does nothing if it is off.
    if ($('#sidebar').length)
        $('#id_toggle_target').append(' \
            <span id="sidebar-hide-toggle"> \
                <a href="javascript:flipSidebar()"> \
                    &nbsp;Hide Sidebar \
                </a> \
            </span> \
            <span id="sidebar-show-toggle" style="display:none;"> \
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
            $('#container').css("width","100%");
            $('#container').css("margin-top","15px");
            break;
            // Turn off the sidebar, swap toggle text
        case 'on':
            $('#container').css("margin-top","0px");
    }
});
