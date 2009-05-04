/*************************************************************************************
 * BEGIN GUESS CASE PANEL AND BUTTONS SECTION                                        *
 *************************************************************************************
 * Function: (default)                                                               *
 *                                                                                   *
 * Loads on page ready, activates the Guess Case panel, attaches appropriate GC      *
 * buttons to the form.  (Button creation code is in es_functions.js.)               *
 *************************************************************************************/
$(function() {
/****************************************************************************************************************************************
 * Default Variables                                                                                                                    *
 ****************************************************************************************************************************************/
    $modeSelection = $("#es-gc-selection"); // Mode select element
    reportErrors = true; // Permit the storeError, clearError, and alertUser methods.
    $mode = handleCookie("get", "es-gc-mode", "English"); // Persistent mode selection from cookie.
    $gckeepUppercased = handleCookie("get", "es-gc-checkbox1", true); // Keep uppercase words uppercased.
    $gcautoFixTitle = handleCookie("get", "es-gc-checkbox2", false);  // Automatically Guess Case track titles.
    $gcTurkishI = handleCookie("get", "es-gc-checkbox3", false);      // Use Turkish rules for capitalization.
    /* -------------------------------------------------------------------------*/
    /* Turn on show/hide functionality
    /* -------------------------------------------------------------------------*/
    $("#js-fieldset-gc-trigger-show").click(function() {
        $("#js-fieldset-gc").removeClass("hidden");
        $("#js-fieldset-gc-trigger-hide").removeClass("hidden");
        $("#js-fieldset-gc-trigger-show").addClass("hidden");
    });
    $("#js-fieldset-gc-trigger-hide").click(function() {
        $("#js-fieldset-gc").addClass("hidden");
        $("#js-fieldset-gc-trigger-show").removeClass("hidden");
        $("#js-fieldset-gc-trigger-hide").addClass("hidden");
    });
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
        bindGuessCase("2", "duration", true);
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
    $("#es-gc-opt1").change(function() {
        handleCookie("set", "es-gc-checkbox1", ($('#es-gc-opt1').is(':checked')));
        $gckeepUppercased = ($('#es-gc-opt1').is(':checked'));
    });
    $("#es-gc-opt2").change(function() {
        handleCookie("set", "es-gc-checkbox2", ($('#es-gc-opt2').is(':checked')));
        $gcautoFixTitle = ($('#es-gc-opt2').is(':checked'));
        renewGCTracks();
    });
    $("#es-gc-opt3").change(function() {
        handleCookie("set", "es-gc-checkbox3", ($('#es-gc-opt3').is(':checked')));
        $gcTurkishI = ($('#es-gc-opt3').is(':checked'));
    });
    /* --------------------------------------------------------------------- */
    /* Turn on the tooltips.                                                 */
    /* --------------------------------------------------------------------- */
    $("#js-fieldset-gc *").tooltip();
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
        $GACheck = $("#es-guessall");
    if ($GACheck.length === 1) {
        $form.each(function(i) {
            gcControlsDiv.append(new GuessAllButton().makeButton(i));
        });
    }
    /* Create and insert explanatory text. */
    gcText = jQuery(document.createElement('span'));
    gcText.appendTo(gcControlsDiv);
    if ($GACheck.length === 1) {
        gcText.text(" " + text.gcMode1 + " ");
    } else {
        gcText.text(text.gcMode2 + " ");
    }
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
    })
    .keyup(function() {
        var i = $("#es-gc-selection-copy").selectedValues()[0];
        $modeSelection.selectOptions(i);
        $mode = handleCookie("set", "es-gc-mode", i);
    });
    var $modeSelectionClone = $("#es-gc-selection-copy");
    $modeSelection.change(function() {
        var i = $modeSelection.selectedValues()[0];
        $modeSelectionClone.selectOptions(i);
        $mode = handleCookie("set", "es-gc-mode", i);
    })
    .keyup(function() {
        var i = $modeSelection.selectedValues()[0];
        $modeSelectionClone.selectOptions(i);
        $mode = handleCookie("set", "es-gc-mode", i);
    });
    /* --------------------------------------------------------------------- */
    /* Make persistent the state of mode selectors between forms.            */
    /* --------------------------------------------------------------------- */
    $modeSelection.selectOptions($mode);
    $modeSelectionClone.selectOptions($mode);
    /* --------------------------------------------------------------------- */
    /* Set undo history event triggers.                                      */
    /* --------------------------------------------------------------------- */
    renewGCDurations();
    renewGCTracks();
    bindGuessCase("1", "artist", false);
    bindGuessCase("3", "label", false);
    bindGuessCase("4", "text", false);
    bindGuessCase("5", "textartist", false);
});
/*************************************************************************************
 * END GUESS CASE PANEL AND BUTTONS SECTION                                          *
 ************************************************************************************/
