/********************************************************************************************
 * Global Variables                                                                         *
 ********************************************************************************************
 *   Track and Release Fields                                                               *
 ===========================================================================================*/
// var releaseTitleGroup = ;
var $trackTitleGroup = $("input[class='track_name'], input[name='track.name']"),
    $artistGroup = $("input[class='artist_name'], .artist-name"),
    $durationGroup = $("input[class='track_duration']"),
/*===========================================================================================
 *   Variable Content                                                                       *
 ===========================================================================================*/
    $textTextGroup = $("input[class='es-text'], .release-title:eq(1)"),
    $textArtistGroup = $("input[class='es-artist'], .release-artist:eq(1)"),
/*===========================================================================================
 *   Release Event fields                                                                   *
 ===========================================================================================*/
    $dateYearGroup = $("input[id$='date-year']"),                  // Release event fields for: Year
    $dateMonthGroup = $("input[id$='date-month']"),                // Release event fields for: Month
    $dateDayGroup = $("input[id$='date-day']"),                    // Release event fields for: Day
    $labelGroup = $("input[class='release_event_label'], .label-name"),          // Release event fields for: Label name
    $catalogGroup = $("input[class='release_event_catalog']"),      // Release event fields for: Catalog #
    $barcodeGroup = $("input[class='release_event_barcode']"),      // Release event fields for: Barcode
/*===========================================================================================
 *   Collections of above groups used for guessing case                                     *
 ===========================================================================================*/
    $gcFieldsGroup = $([$trackTitleGroup, $artistGroup, $durationGroup, $labelGroup, $textTextGroup, $textArtistGroup]),
    $gcFieldsTitles = $(["title", "artist", "duration", "label", "text", "textartist"]),
/*===========================================================================================
 *   Specific form elements                                                                 *
 ===========================================================================================*/
    $modules = $('.js-fieldset-trigger-show'),        // Fieldset modules
    $form = $('#es-form'),                            // The form to which Guess Case, Undo / Revert, and Track Parser attach.
    $events = $('#es-events');                        // The release events fieldset, to which various things attach.
if ($("#es-tips").length === 0) {
    $noTipsCheck = false;
} else {
    $noTipsCheck = true;
}
var $loadindicator = $("#es-loading-text"),           // div containing Edit Suite load status text
/*===========================================================================================
 *   Locations of files                                                                     *
 ===========================================================================================*/
   filelocs = [];
filelocs.serverBase = location.href.split("/")[2];         // Base server url
filelocs.serverJavaScript = "/static/scripts/";            // Relative location of base scripts directory on the server
filelocs.serverImage = "/static/images/scripts/";               // Relative location of base image directory on the server
filelocs.serverStyles = "/static/styles/extra/";           // Relative location of base image directory on the server
filelocs.serverJQuery = "jquery/";                         // Relative location of jQuery scripts / styles directories on the server
filelocs.serverCommon = "common/";                         // Relative location of "common" scripts directory on the server
/*===========================================================================================
 *   CSS Classes                                                                            *
 ===========================================================================================*/
var windowTitle     = "es-headlinetitle",             // Class for popup window title bar
    windowImage     = "es-headlineimg",               // Class for popup window image
    windowMessage   = "es-message",                   // Class for popup window text
    windowConfirm   = "es-confirm",                   // Class for popup confirmation question text
    floatLeft       = "es-l",                         // Basic float:left; class
    controlButton   = "",                             // Class for Guess Case / Undo All / etc buttons
    buttonContainer = "es-gc-button",                 // Class for divs which contain Guess Case / Undo All / etc buttons
/*===========================================================================================
 *   File types                                                                             *
 ===========================================================================================*/
   imageExt      = "png",                            // Type of images to use
/*===========================================================================================
 *   Loader data                                                                            *
 ===========================================================================================*/
    loadedFiles = [],                                 // Stores an array of files already loaded
    toBeLoaded = [],                                  // Stores an array of files to be loaded
    loadingState = false,                             // Lock state of the lazy-loader
    progressBar = 0,                                  // Has progress bar code been loaded yet?
    totalFileSize = 0,                                // How many bytes total to load?
    currentLoadedSize = 0,                            // How many bytes so far loaded?
    textStrings = false,
/*===========================================================================================
 *   Unmodified element clones                                                              *
 ===========================================================================================*/
    rawTrack,
    rawEvent;
/********************************************************************************************
 * END Global Variables                                                                     *
 *******************************************************************************************/
/********************************************************************************************
 * Functions                                                                                *
 ********************************************************************************************/
/********************************************************************************************
 * Function: loadFiles ( none )                                                             *
 *                                                                                          *
 * Lazy-loader.  Downloads and loads JavaScript and CSS files.                              *
 * Do *not* use with CSS files that use @includes.                                          *
 ********************************************************************************************/
function loadFiles() { 
    loadingState = true; // Lock the file loader
    function alreadyLoaded(file) {
        if (jQuery.inArray(file, loadedFiles) > 0) { // Check for the file name in the array of files to be loaded
            return true;
        } else {
            return false;
        }
    }
    function loadError(XMLHttpRequest, textStatus, errorThrown) {  // Text in this function is for debug.  No need for i18n support in this text.
        if (textStrings) {
            $loadindicator.append("<span>" + fileToLoad + " " + " load error.  status: " + textStatus + " error: " + errorThrown+"<br />");
        }
        toBeLoaded.unshift(fileToLoad); // Put the errored file back into the front of the to be loaded queue
        loadFiles(); // Loop back to retry loading the file
    }
    function loadSuccess(data) {  // Text in this function is for debug.  No need for i18n support in this text.
        var timeEnd = new Date();
        if (textStrings) {
            $loadindicator.append("<span>" + fileToLoad + " loaded. Time elapsed: " +
                (timeEnd.getTime() - timeStart.getTime()) + " ms</span><br />");
        }
        currentLoadedSize += data.length;
        if (progressBar === 1) {
            $('#es-load-status').progressbar({ value: Math.round(((currentLoadedSize/totalFileSize)*100)) });  // Turn on the progress bar, now that the code has been loaded
            progressBar++;
        } else if (progressBar === 2) {
            /* Update the progress bar */
            $('#es-load-status').progressbar('option', 'value', Math.round(((currentLoadedSize/totalFileSize)*100)));
        }
        loadedFiles.push(fileToLoad); // Add the now-loaded file into the array of loaded files
        loadFiles(); // Loop back to check for other files which need to be loaded
    }
    function loadSuccessCss(data, status) {
        $('head').append('<style type="text/css" rel="stylesheet" href="'+fileToLoad+'">'+data+'</style>');
        loadSuccess(data);
    }
    if (toBeLoaded.length > 0) { // Make sure there's actually anything to be loaded in the toBeLoaded array
        var timeStart = new Date();
        var fileToLoad = toBeLoaded.shift();
        if (!alreadyLoaded(fileToLoad)) { // Make sure we've not already loaded the file
            if (loadedFiles.length === 1) {
                textStrings = true;
            }
            if (fileToLoad === "jquery.jquery-ui.js") {  // Prevent attempting to update the progressbar until we've actually loaded that code
                progressBar = 1;
            }
            if (textStrings) {
                $('#es-statusbar-text').text(text.Loading+" "+fileToLoad);
            }
            if (fileToLoad.substr(0, 4) !== "http") { // Allow full urls to be passed, but still allow passing "shorthand" urls for local files
                if (fileToLoad.match(/^jquery\./)) { // If this is a jQuery plugin file
                    fileToLoad = filelocs.serverJQuery + fileToLoad; // Prepend that subdirectory name onto the file name
                } else if (fileToLoad.match(/^es_/)) { // If this is an Edit Suite file
                    fileToLoad = filelocs.serverCommon + fileToLoad; // Prepend that subdirectory name onto the file name
                }
                switch (new RegExp(/\.css|\.js/).exec(fileToLoad).toString()) { // Handle the url depending upon which type of file it is
                    case ".js":
                        fileToLoad = "http://" + filelocs.serverBase + filelocs.serverJavaScript + fileToLoad;
                        $.ajax({
                            type: "GET",
                            url: fileToLoad,
                            error: loadError,
                            success: loadSuccess,
                            dataType: "script",
                            cache: false
                        });
                        break;
                    case ".css":
                        fileToLoad = "http://" + filelocs.serverBase + filelocs.serverStyles + fileToLoad;
                        $.ajax({
                            type: "GET",
                            url: fileToLoad,
                            success: loadSuccessCss,
                            error: loadError,
                            dataType: "html",
                            cache: false
                        });
                        break;
                    default:
                }
            }
        }
    } else {  // Done loading files
        loadingState = true; // Unlock the file loader
        $('#es-loader').html(text.ESBeginA+"<br />"+text.ESBeginB);
    } 
}
function startLoad() {
    if (!loadingState) { 
        loadFiles();
    }
}
/********************************************************************************************
 * Function: ( default )                                                                    *
 *                                                                                          *
 * Launches and displays the Edit Suite.                                                    *
 ********************************************************************************************/
$(function() {
    /* ------------------------------------------------------------------------ */
    /* Create container for the Guess All, Undo All, Revert All,                */
    /* and mode selector dropdown.                                              */
    /* ------------------------------------------------------------------------ */
    gcControlsDiv = jQuery(document.createElement('div')).addClass("js-button-row")
                                                         .css({"paddingBottom" : "0",})
                                                         .attr("id", "esControlsDiv");
    /* ------------------------------------------------------------------------ */
    /* Insert the Guess All and mode selector div into the form.                */
    /* ------------------------------------------------------------------------ */
    gcControlsDiv.appendTo($form.get(0));
    /* ------------------------------------------------------------------------ */
    /* Hide the "Add another track" checkbox's div.                             */
    /* ------------------------------------------------------------------------ */
    $("input[name='more_tracks']").parent().hide();
    /* ------------------------------------------------------------------------ */
    /* Calculate the total size of the Edit Suite files.                        */
    /* ------------------------------------------------------------------------ */
    /* From pre-load:   */
    totalFileSize += 3133;        // scripts.css
    totalFileSize += 47;          // jquery.ui.all.css
    totalFileSize += 16498;       // ui.theme.css
    totalFileSize += 298;         // ui.base.css
    totalFileSize += 152;         // ui.progressbar.css
    totalFileSize += 22948;       // all JQuery UI css images combined
    if ($("#es-button6").length !== 0) { // Suite Settings
        totalFileSize += 599;     // ui.tabs.js
    }
    totalFileSize += 4371;        // jquery.cookie.js
    totalFileSize += 1146;        // switch.js
    totalFileSize += 1516;        // switchcontrols.js
    totalFileSize += 18384;       // es_main.js
    currentLoadedSize = totalFileSize;
    /* From lazy-load:  */
    totalFileSize += 21119;       // jquery.jquery-ui.js
    totalFileSize += 3454;        // es_stack.js
    totalFileSize += 207;         // jquery.tooltip.css
    totalFileSize += 8086;        // jquery.tooltip.js
    totalFileSize += 23902;       // es_functions.js
    totalFileSize += 13114;       // jquery.selectboxes.js
    if ($("#es-button1").length !== 0) { // Guess Case
        totalFileSize += 132970;  // es_names.js
        totalFileSize += 229101;  // es_guess_case.js
        totalFileSize += 11397;   // es_guess_case_panel.js
    }
    totalFileSize += 2514;        // jquery.dimensions.min.js
    totalFileSize += 6782;        // jquery.impromptu.js
    totalFileSize += 1478;        // jquery.impromptu.css
    totalFileSize += 6643;        // jquery.inputHintBox.js
    if ($("#es-button2").length !== 0) { // Undo / Revert
        totalFileSize += 6913;    // es_undo_revert.js
    }
    if ($("#es-button3").length !== 0) { // Search / Replace
        totalFileSize += 378;     // es_search_replace.js
    }
    if ($("#es-button4").length !== 0) { // Track Parser
        totalFileSize += 500;     // es_track_parser.js
    }
    if ($("#es-button5").length !== 0) { // Style Guidelines
        totalFileSize += 1877;    // es_style_guidelines.js
    }
    if ($("#es-button6").length !== 0) { // Suite Settings
        totalFileSize += 273;     // es_suite_preferences.js
    }
    if ($("#es-urlfixer").length !== 0) { // URL AutoFixer
        totalFileSize += 7514;     // es_suite_preferences.js
    }
    /* ------------------------------------------------------------------------ */
    /* Lazy-load the Edit Suite files.                                          */
    /* ------------------------------------------------------------------------ */
    toBeLoaded.push("jquery.jquery-ui.js");
    startLoad();
    toBeLoaded.push("es_stack.js");
    toBeLoaded.push("es_functions.js");
    toBeLoaded.push("jquery.tooltip.css");
    toBeLoaded.push("jquery.tooltip.js");
    startLoad();
    toBeLoaded.push("jquery.selectboxes.js");
    toBeLoaded.push("jquery.inputHintBox.js");
    if ($("#js-fieldset-gc-trigger-show").length !== 0) { // Guess Case
        toBeLoaded.push("es_names.js");
        toBeLoaded.push("es_guess_case.js");
        toBeLoaded.push("es_guess_case_panel.js");
        startLoad();
    }
    toBeLoaded.push("jquery.dimensions.min.js");
    toBeLoaded.push("jquery.impromptu.js");
    toBeLoaded.push("jquery.impromptu.css");
    startLoad();
    if ($("#es-ur").length !== 0) { // Undo / Revert
        toBeLoaded.push("es_undo_revert.js");
    }
    if ($("#js-fieldset-sr-trigger-show").length !== 0) { // Search / Replace
        toBeLoaded.push("es_search_replace.js");
    }
    if ($("#js-fieldset-tp-trigger-show").length !== 0) { // Track Parser
        toBeLoaded.push("es_track_parser.js");
    }
    if ($("#js-fieldset-sg-trigger-show").length !== 0) { // Style Guidelines
        toBeLoaded.push("es_style_guidelines.js");
    }
    if ($("#es-urlfixer").length !== 0) { // URL AutoFixer
        toBeLoaded.push("es_URLfixer.js");
    }
    startLoad();
    $('head').append('<script type="text/javascript" href="http://www.google.com/jsapi?key=ABQIAAAAutQrCy8v9EMhfZsC7lEANBSTu9g1Vv0xmF87JHH0oUgrycAWThRHDU_DQ9OlY04hXHLL-FL4RKHaKA"></style>');
    /* -------------------------------------------------------------------------*/
    /* Hide the load status indicator, now that all files have been loaded.
    /* -------------------------------------------------------------------------*/
    $(".js-progress-text").addClass("hidden");
    /* -------------------------------------------------------------------------*/
    /* Unhide the modules                                                       */
    /*     (ensures that non-JQuery browsers never see the JS modules)          */
    /* -------------------------------------------------------------------------*/
    $modules.removeClass("hidden");
});
