MusicBrainz.IEFixer = function()
{

    // Fix IE bug which only apply :hover CSS to link
    this.highlightTrackRows = function() {

        var trClassName = "track";
        var trackRows = getElementsByTagAndClassName("tr", trClassName);
        if (trackRows == null)
            return;
        for (var i = 0; i < trackRows.length; i++) {
            connect(trackRows[i], "onmouseover", function(ev) { ev.src().className = trClassName + '-hover'; });
            connect(trackRows[i], "onmouseout", function(ev) { ev.src().className = trClassName; });
        }

    }

}

var iefixer = new MusicBrainz.IEFixer();
mb.registerDOMReadyAction(
    new MbEventAction("iefixer", "highlightTrackRows", "IE Specific: highlight track rows"));
