$(function() {
    var setSearchField = function(str) {
        $("#es-sr-input-search").attr("value",str);
    }
    var setReplaceField = function(str) {
        $("#es-sr-input-replace").attr("value",str);
    }
    var setUseRegExp = function() {
        $("#es-sr-opt1").attr("checked","checked");
    }
    /* Add fancy tooltips. */
    if ($noTipsCheck) {
        $("#es-sr-controls1 *").tooltip();
        $("#es-sr-controls2 *").tooltip();
        $("#es-sr-presets *").tooltip();
    }
    /* Add ES panel button functionality. */
    $('#es-button3').click(function() {
        $("#es-sg-explain").text("Search and replace text within form fields.");
        $(".esdisplay").hide();
        $("#es-sr").show();
    });
    /* Add presets functionality. */
    $('#es-sr-preset1').click(function() {
        setUseRegExp();
        setSearchField("\\(|\\)");
        setReplaceField("");
    });
    $('#es-sr-preset2').click(function() {
        setUseRegExp();
        setSearchField("\\[|\\]");
        setReplaceField("");
    });
    $('#es-sr-preset3').click(function() {
        setUseRegExp();
        setSearchField("\\{|\\}");
        setReplaceField("");
    });
    $('#es-sr-preset4').click(function() {
        setUseRegExp();
        setSearchField("\\(|\\)|\\[|\\]|\\{|\\}");
        setReplaceField("");
    });
    $('#es-sr-preset5').click(function() {
        setUseRegExp();
        setSearchField("\\[([^\\]]*)\\]");
        setReplaceField("($1)");
    });
    $('#es-sr-preset6').click(function() {
        setUseRegExp();
        setSearchField("\\(([^\\)]*)\\)");
        setReplaceField("[$1]");
    });
    $('#es-sr-preset7').click(function() {
        setUseRegExp();
        setSearchField("#(\\d*)");
        setReplaceField("No. $1");
    });
    $('#es-sr-preset8').click(function() {
        setUseRegExp();
        setSearchField("((\\d)(\\d).\\s?)");
        setReplaceField("");
    });
    /* Add swap fields functionality. */
    $('#es-sr-button-swap').click(function() {
        var tempFieldValue = $("#es-sr-input-search").attr("value");
        setSearchField($("#es-sr-input-replace").attr("value"));
        setReplaceField(tempFieldValue);
    });
    /* Add clear fields functionality. */
    $('#es-sr-button-clear').click(function() {
        setSearchField("");
        setReplaceField("");
    });
    /* Add Search and Replace undo functionality. */
    $('#es-sr-button-undo').click(function() {
        if ($("#es-sr-opt3").attr("checked")) {
            $("input[id$='-artist-undo']").click();
        }
        if ($("#es-sr-opt4").attr("checked")) {
            $("input[id$='-title-undo']").click();
        }
    });
    /* Add search / replace functionality. */
    $('#es-sr-button-sr').click(function() {
        var doReplacement = function(actionFields, type) {
            jQuery.each(actionFields, function(i) {
                storeHistory($(this).attr("value"), type, i);
                $(this).attr("value", $(this).attr("value").replace(searchRegExp, $("#es-sr-input-replace").attr("value")));
            });
        },
            artistFields = $("#es-sr-opt3").attr("checked"),
            trackFields = $("#es-sr-opt4").attr("checked");
        if (!artistFields && !trackFields) {
            alertUser("warning", text.NothingSelected);
        } else {
            var searchRegExp;
            if ($("#es-sr-opt1").attr("checked")) {
                searchRegExp = new RegExp($("#es-sr-input-search").attr("value"), "g"+($("#es-sr-opt2").attr("checked") ? "":"i"));
            } else {
                searchRegExp = new RegExp($("#es-sr-input-search").attr("value").replace(/[.*+?|()\[\]{}\\]/g, "\\$&"), "g"+($("#es-sr-opt2").attr("checked") ? "":"i"));
            }
            if (trackFields) {
                if (typeof($trackTitleGroup) != "undefined") {
                    if ($trackTitleGroup.length > 0) {
                        doReplacement($trackTitleGroup, "title");
                    }
                }
                if (typeof($textTextGroup) != "undefined") {
                    if ($textTextGroup.length > 0) {
                        doReplacement($textTextGroup, "text");
                    }
                }
            }
            if (artistFields) {
                if (typeof($artistGroup) != "undefined") {
                    if ($artistGroup.length > 0) {
                        doReplacement($artistGroup, "artist");
                    }
                }
                if (typeof($textArtistGroup) != "undefined") {
                    if ($textArtistGroup.length > 0) {
                        doReplacement($textArtistGroup, "textartist");
                    }
                }
            }
        }
    });
});
