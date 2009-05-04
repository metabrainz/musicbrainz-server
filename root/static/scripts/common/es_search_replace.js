$(function() {
    /* -------------------------------------------------------------------------*/
    /* Turn on show/hide functionality
    /* -------------------------------------------------------------------------*/
    $("#js-fieldset-sr-trigger-show").click(function() {
        $("#js-fieldset-sr").removeClass("hidden");
        $("#js-fieldset-sr-trigger-hide").removeClass("hidden");
        $("#js-fieldset-sr-trigger-show").addClass("hidden");
    });
    $("#js-fieldset-sr-trigger-hide").click(function() {
        $("#js-fieldset-sr").addClass("hidden");
        $("#js-fieldset-sr-trigger-show").removeClass("hidden");
        $("#js-fieldset-sr-trigger-hide").addClass("hidden");
    });
    var setSearchField = function(str) {
        $("#es-sr-input-search").attr("value",str);
    }
    var setReplaceField = function(str) {
        $("#es-sr-input-replace").attr("value",str);
    }
    var setUseRegExp = function() {
        $("#es-sr-opt1").attr("checked","checked");
    }
    /* Turn on the tooltips. */
    $("#js-fieldset-sr *").tooltip();
    /* Add presets functionality. */
    $("#es-sr-selection").click(function() {
        setUseRegExp();
        setReplaceField("");
        switch ($("#es-sr-selection").selectedValues()[0]) {
            case "1":
                setSearchField("\\(|\\)");
                break;
            case "2":
                setSearchField("\\[|\\]");
                break;
            case "3":
                setSearchField("\\{|\\}");
                break;
            case "4":
                setSearchField("\\(|\\)|\\[|\\]|\\{|\\}");
                break;
            case "5":
                setSearchField("\\[([^\\]]*)\\]");
                setReplaceField("($1)");
                break;
            case "6":
                setSearchField("\\(([^\\)]*)\\)");
                setReplaceField("[$1]");
                break;
            case "7":
                setSearchField("#(\\d*)");
                setReplaceField("No. $1");
                break;
            case "8":
                setSearchField("((\\d)(\\d).\\s?)");
                break;
            default:
        };
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
