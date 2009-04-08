/*************************************************************************************
 * BEGIN GUESS CASE PANEL AND BUTTONS SECTION                                        *
 *************************************************************************************
 * Function: (default)                                                               *
 *                                                                                   *
 * Loads on page ready, activates the Guess Case panel, attaches appropriate GC      *
 * buttons to the form.  (Button creation code is in es_main.js.)                    *
 *************************************************************************************/
$(function() {
/****************************************************************************************************************************************
 * Default Variables                                                                                                                    *
 ****************************************************************************************************************************************/
    $modeSelection = $("#es-gc-selection"); // Mode select element
    reportErrors = true; // Permit the storeError, clearError, and alertUser methods.
    $mode = handleCookie("get", "es-gc-mode", "English"); // Persistent mode selection from cookie.
    $gcpageload = handleCookie("get", "es-gc-checkbox1", false); // Apply guess case after page loads.
    $gcuppercaseRoman = handleCookie("get", "es-gc-checkbox2", true); // Uppercase Roman numerals.
    $gckeepUppercased = handleCookie("get", "es-gc-checkbox3", true); // Keep uppercase words uppercased.
    $gcautoFixDuration = handleCookie("get", "es-gc-checkbox4", true); // Automatically fix track duration problems.
    $gcfixDuration = handleCookie("get", "es-gc-checkbox5", true); // Fix track duration problems when using Guess All.
    $gcautoFixTitle = handleCookie("get", "es-gc-checkbox6", false); // Automatically Guess Case track titles.
    /* --------------------------------------------------------------------- */
    /* Hook the blur event for all GC fields to enable storing after         */
    /* manual changes and to enable automatic Guess Casing specifically      */
    /* for durations and tracks ONLY if enabled in the menu.                 */
    /* --------------------------------------------------------------------- */
    var bindGuessCase = function(group, type, auto) {
        $gcFieldsGroup[group].each(function(i) {
            $(this).blur(function() {
                storeHistory($(this).attr("value"), type, i);
                if (auto === true) {
                    $(this).attr("value", guessMyCase(type, i, $(this).attr("value")));
                }
            });
        });
    },
    /* --------------------------------------------------------------------- */
    /* Unhook the blur event for specified GC field type.                    */
    /* --------------------------------------------------------------------- */
    unbindGuessCase = function(group, type) {
        $gcFieldsGroup[group].each(function(i) {
            $(this).unbind('blur');
        });
    },
    /* --------------------------------------------------------------------- */
    /* Test and handle track durations auto-correction & history triggers.   */
    /* --------------------------------------------------------------------- */
    renewGCDurations = function() {
        unbindGuessCase("2", "duration");
        if ($gcautoFixDuration === true) {
            bindGuessCase("2", "duration", true);
        } else {
            bindGuessCase("2", "duration", false);
        }
    },
    /* --------------------------------------------------------------------- */
    /* Test and handle track titles auto-correction & history triggers.      */
    /* --------------------------------------------------------------------- */
    renewGCTracks = function() {
        unbindGuessCase("0", "title");
        if ($gcautoFixTitle === true) {
            bindGuessCase("0", "title", true);
        } else {
            bindGuessCase("0", "title", false);
        }
    };
    /* --------------------------------------------------------------------- */
    /* Handle changes to user Guess Case preferences in the ES panel.        */
    /* --------------------------------------------------------------------- */
    $("#es-gc-checkbox1").change(function() {
        handleCookie("set", "es-gc-checkbox1", ($('#es-gc-opt1').is(':checked')));
        $gcpageload = ($('#es-gc-opt1').is(':checked'));
    });
    $("#es-gc-opt2").change(function() {
        handleCookie("set", "es-gc-checkbox2", ($('#es-gc-opt2').is(':checked')));
        $gcuppercaseRoman = ($('#es-gc-opt2').is(':checked'));
    });
    $("#es-gc-opt3").change(function() {
        handleCookie("set", "es-gc-checkbox3", ($('#es-gc-opt3').is(':checked')));
        $gckeepUppercased = ($('#es-gc-opt3').is(':checked'));
    });
    $("#es-gc-opt4").change(function() {
        handleCookie("set", "es-gc-checkbox4", ($('#es-gc-opt4').is(':checked')));
        $gcautoFixDuration = ($('#es-gc-opt4').is(':checked'));
        renewGCDurations();
    });
    $("#es-gc-opt5").change(function() {
        handleCookie("set", "es-gc-checkbox5", ($('#es-gc-opt5').is(':checked')));
        $gcfixDuration = ($('#es-gc-opt5').is(':checked'));
    });
    $("#es-gc-opt6").change(function() {
        handleCookie("set", "es-gc-checkbox6", ($('#es-gc-opt6').is(':checked')));
        $gcautoFixTitle = ($('#es-gc-opt6').is(':checked'));
        renewGCTracks();
    });
    /* --------------------------------------------------------------------- */
    /* Turn on the tooltips, unless user has them off in preferences.        */
    /* --------------------------------------------------------------------- */
    if ($noTipsCheck) {
        $("#es-gc-optionset1 *").tooltip();
        $("#es-gc-optionset2 *").tooltip();
    }
    /* --------------------------------------------------------------------- */
    /* Attach ES panel display function to the ES GC button.                 */
    /* --------------------------------------------------------------------- */
    $('#es-button1').click(function() {
        $("#es-sg-explain").text(text.GuessCasePrefs);
        $(".esdisplay").hide();
        $("#es-gc").show();
    });
    /* --------------------------------------------------------------------- */
    /* Create and insert "Guess Case" buttons for each title & artist field. */
    /* --------------------------------------------------------------------- */
    $trackTitleGroup.each(function(i) {
        makeTitleButton(i, $(this));
    });
    $textTextGroup.each(function(i) {
        makeTitleButton(i, $(this));
    });
    $artistGroup.each(function(i) {
        makeArtistButton(i, $(this));
    });
    $textArtistGroup.each(function(i) {
        makeArtistButton(i, $(this));
    });
    $("#form-create-label-name, #form-edit-label-name").each(function(i) {
        makeLabelButton(i, $(this));
    });
    if ($("#form-create-label-name, #form-edit-label-name").length > 0) {
        $("#es-gc-div-label-0").css({"right":"-85%"});
    }
    /* --------------------------------------------------------------------- */
    /* Create and insert "Guess All" button for the form.                    */
    /* --------------------------------------------------------------------- */
    var $esControlsDiv = $("#esControlsDiv"),
        $GACheck = $("#es-guessall"),
        $ModeTwo = $("#es-no-secondinline").length;
    if ($GACheck.length === 1) {
        $form.each(function(i) {
            gcControlsDiv.append(new GuessAllButton().makeButton(i));
        });
    }
    /* --------------------------------------------------------------------- */
    /* Check that the user doesn't have the JS_es_InlineMode preference off. */
    /* --------------------------------------------------------------------- */
    if ($ModeTwo === 0) {
        /* Create and insert explanatory text. */
        gcText = jQuery(document.createElement('span'));
        if ($GACheck.length === 1) {
            gcText.text(" using Guess Case set to: ");
        } else {
            gcText.text("Guess Case is set to: ");
        }
        gcText.appendTo(gcControlsDiv);
        /* --------------------------------------------------------------------- */
        /* Copy and insert the mode selector dropdown.                           */
        /* --------------------------------------------------------------------- */
        $modeSelection.clone().attr("id", "es-gc-selection-copy").removeClass("es-ro").removeClass("es-rm").appendTo(gcControlsDiv)
        /* --------------------------------------------------------------------- */
        /* Keep the two Guess Case mode selectors synchronized.                  */
        /* --------------------------------------------------------------------- */
        .change(function() {
            var i = $("#es-gc-selection-copy").selectedValues()[0];
            $modeSelection.selectOptions(i);
            $mode = handleCookie("set", "es-gc-mode", i);
        });
        var $modeSelectionClone = $("#es-gc-selection-copy");
        $modeSelection.change(function() {
            var i = $modeSelection.selectedValues()[0];
            $modeSelectionClone.selectOptions(i);
            $mode = handleCookie("set", "es-gc-mode", i);
        });
        /* --------------------------------------------------------------------- */
        /* or at least keep track of the selected item, in the cookie, if we     */
        /*  only have the one selector.                                          */
        /* --------------------------------------------------------------------- */
    } else {
        $modeSelection.change(function() {
            handleCookie("set", "es-gc-mode", $modeSelection.selectedValues()[0]);
        });
    }
    /* --------------------------------------------------------------------- */
    /* Make persistent the state of mode selectors between forms.            */
    /* --------------------------------------------------------------------- */
    $modeSelection.selectOptions($mode);
    /* --------------------------------------------------------------------- */
    /* Check that the user doesn't have the JS_es_InlineMode preference off. */
    /* --------------------------------------------------------------------- */
    if ($ModeTwo === 0) {
        $modeSelectionClone.selectOptions($mode);
    }
    /* --------------------------------------------------------------------- */
    /* Set undo history event triggers.                                      */
    /* --------------------------------------------------------------------- */
    renewGCDurations();
    renewGCTracks();
    bindGuessCase("1", "artist", false);
    bindGuessCase("3", "label", false);
    bindGuessCase("4", "text", false);
    bindGuessCase("5", "textartist", false);
    /* --------------------------------------------------------------------- */
    /* Run Guess Case on page load if the user has that option turned on.    */
    /* --------------------------------------------------------------------- */
    if ($gcpageload === true) {
        guessAllAll();
    }
});
/*************************************************************************************
 * END GUESS CASE PANEL AND BUTTONS SECTION                                          *
 ************************************************************************************/
