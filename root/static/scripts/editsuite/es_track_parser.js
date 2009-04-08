$(function() {
    var inputField,
        tempArtistStore = "",
        trackCount,
        inputLines,
        inputTitles = [],
        inputArtists = [],
        inputDurations = [];
    if ($noTipsCheck) {
        $("#es-tp-presets *").tooltip();
        $("#es-tp-loadfromfile *").tooltip();
    }
    $('#es-button4').click(function() {
        $("#es-sg-explain").text("Paste and parse release information to fill the form fields.");
        $(".esdisplay").hide();
        $("#es-tp").show();
    });
    /* Handle options which don't make sense unless other options are also selected. */
    $("#es-tp-opt2").change(function() {
        if ($("#es-tp-opt2").attr("checked")) {
            $("#es-tp-opt3-span").show();
        } else {
            $("#es-tp-opt3").attr("checked",false);
            $("#es-tp-opt3-span").hide();
        }
    });
    $("#es-tp-opt4").change(function() {
        if ($("#es-tp-opt4").attr("checked")) {
            $("#es-tp-opt5-span").show();
        } else {
            $("#es-tp-opt5").attr("checked",false);
            $("#es-tp-opt5-span").hide();
        }
    });
    $("#es-tp-opt9").change(function() {
        if ($("#es-tp-opt9").attr("checked")) {
            $("#es-tp-button-artists").show();
            $("#es-tp-opt9b-span").css("visibility","visible");
        } else {
            $("#es-tp-button-artists").hide();
            $("#es-tp-opt9b-span").css("visibility","hidden");
        }
    });
    if(jQuery.browser.opera) {  // Opera renders with additional vertical space - make that space useful to the user.
        $("#es-tp-textarea").attr("rows","13.5");
    } else if (new RegExp("epiphany","i").test(navigator.userAgent)) { // Ephiphany and Galeon on the other hand render with too little vertical space.
        $("#es-tp-textarea").attr("rows","10");
    } else if (new RegExp("galeon","i").test(navigator.userAgent)) { 
        $("#es-tp-textarea").attr("rows","10");
    } else if (new RegExp("konqueror","i").test(navigator.userAgent)) { // Same for Konquerer...
        $("#es-tp-textarea").attr("rows","10");
    }
    $("#es-tp-opt9b").attr("value","-/");
    $("#es-tp-opt2").change();
    $("#es-tp-opt4").change();
    $("#es-tp-opt9").change();
    /* Get user input. */
    inputField = $("#es-tp-textarea").attr("value");
    /* Hide the file loader function in all browsers that cannot use it. */
    if (jQuery.browser != "mozilla" && jQuery.browser.version.substr(0,3) != "1.9") {
        $("#es-tp-loadfromfile").hide();
    }
    /* File loader functionality. */
    $("#es-tp-loadfile").change(function () {
        $("#es-tp-textarea").attr("value",$("#es-tp-loadfile")[0].files[0].getAsText("UTF-8"));
    });
    /* Swap title / artist functionality. */
    /* We can count on title fields always being present.  Artist fields might be "locked", */
    /* however, so only swap those fields where the artist field is visible. */ 
// TODO: Add release title / artist support
    $("#es-tp-button-swap").click(function() {
        trackCount = parseInt($trackTitleGroup.length, 10);
        for (var currTrack = 1; currTrack <= trackCount; currTrack++) {
            if (!$("#form-add-release-tracks-artist-" + currTrack).is(':hidden')) {
                tempArtistStore = $("#form-add-release-tracks-artist-" + currTrack).attr("value");
                $("#form-add-release-tracks-artist-" + currTrack).attr("value",$("#form-add-release-tracks-track_" + currTrack + "-name").attr("value"));
                $("#form-add-release-tracks-track_" + currTrack + "-name").attr("value",tempArtistStore);
            }
        }
    });
    var storeUndoData = function () {
            jQuery.each($trackTitleGroup, function(i) {
                storeHistory($(this).attr("value"),"title",i);
            });
            jQuery.each($durationGroup, function(i) {
                storeHistory($(this).attr("value"),"duration",i);
            });
            jQuery.each($artistGroup, function(i) {
                storeHistory($(this).attr("value"),"artist",i);
            });
        },
        getTrackInput = function () {
            inputLines = jQuery.trim($("#es-tp-textarea").attr("value")).split("\n");
        },
        removeTrackNumbers = function() {
            if ($("#es-tp-opt3").attr("checked")) { // Vinyl track numbers
                jQuery.each(inputLines, function(i) {
                    inputLines[i] = this.replace(/^[\s\(]*[-\.０-９0-9a-z]+[\.\)\s]+/i, "");
                });
            } else if ($("#es-tp-opt2").attr("checked")) { // Non-vinyl track numbers
                jQuery.each(inputLines, function(i) {
                    inputLines[i] = this.replace(/^[\s\(]*([-\.０-９0-9\.]+(-[０-９0-9]+)?)[\.\)\s]+/, "");
                });
            }
        },
        parseTimes = function() {
            jQuery.each(inputLines, function(i) {
                if ($("#es-tp-opt1").attr("checked")) { // Set release title from first line option.
                    if (i != 0) {
                        inputLines[i] = this.replace(/\(?\s?([0-9０-９]*[：，．':,.][0-9０-９]+)\s?\)?$/, function(str, p1) {
                        inputDurations[i-1] = fullWidthConverter(p1);
                        return "";
                        });
                    }
                } else {
                    inputLines[i] = this.replace(/\(?\s?([0-9０-９]*[：，．':,.][0-9０-９]+)\s?\)?$/, function(str, p1) {
                        inputDurations[i] = fullWidthConverter(p1);
                        return "";
                    });
                }
            });
        },
        cleanSpaces = function() {
            jQuery.each(inputLines, function(i) {
                inputLines[i] = jQuery.trim(inputLines[i]);
            });           
        },
        cleanBork = function() {
            var AllMusicGuideBork = /(Listen Now!|AMG Pick)/g,
                AmazonBork = /[£$€]\d.\d{2}$/,
                TrailingListen = /\s\s*(listen(music)?|\s)+$/gi;
            jQuery.each(inputLines, function(i) {
                inputLines[i] = jQuery.trim(inputLines[i]).replace(AllMusicGuideBork, "")
                                                          .replace(AmazonBork, "")
                                                          .replace(TrailingListen, "");
            });           
        },
        cleanTitles = function() {
            jQuery.each(inputLines, function(i) {
                inputLines[i] = inputLines[i].replace(/(.*),\sThe$/i, "The $1")
                                            .replace(/\s*,/g, ",");
                if ($("#es-tp-opt6").attr("checked")) { 
                    inputLines[i] = inputLines[i].replace(/\[.*\]/g, "");
                }
            });
        },
        parseArtists = function() {
            var artistSeparator = new RegExp("\\s[" + $("#es-tp-opt9b").attr("value") + "\\t]");
            jQuery.each(inputLines, function(i) {
                if ($("#es-tp-opt1").attr("checked")) { // Set release title from first line option.
                    if (i != 0) {
                        if (inputLines[i].match(artistSeparator)) {
                            inputArtists[i-1] = inputLines[i].split(artistSeparator,2)[1]
                                                             .replace(/(.*),\sThe$/i, "The $1")
                                                             .replace(/\s*,/g, ",");
                            inputLines[i] = inputLines[i].split(artistSeparator,1)[0];
                        }
                    }
                } else {
                    if (inputLines[i].match(artistSeparator)) {
                        inputArtists[i] = inputLines[i].split(artistSeparator,2)[1]
                                                       .replace(/(.*),\sThe$/i, "The $1")
                                                       .replace(/\s*,/g, ",");
                        inputLines[i] = inputLines[i].split(artistSeparator,1)[0];
                    }
                }
            });
        },
        fillInData = function() {
            addTracks = function(counter) {
                while (counter > $trackTitleGroup.length) {  // We parsed out more tracks than are present in the current form.
                    insertTrack();  // Add tracks to the form until we have enough to fit the parsed track data.
                }
            }
            if (inputTitles.length > 0) {  // We have track title data to fill into the form.
                if ($("#es-tp-opt1").attr("checked")) { // Set release title from first line option.
                    $("#form-add-release-tracks-title").attr("value",inputTitles.shift());
                }
                addTracks(inputTitles.length);
                jQuery.each($trackTitleGroup, function(i) {
                    $(this).attr("value",inputTitles[i]);  // Fill in the track titles.
                    $(this).change();
                });
            }
            if ($("#es-tp-opt5").attr("checked")) { // Fill in track times option.
                if (inputDurations.length > 0) {  // We have track duration data to fill into the form.
                    addTracks(inputDurations.length);
                    jQuery.each($durationGroup, function(i) {
                        $(this).attr("value",inputDurations[i]);  // Fill in the track durations.
                        $(this).change();
                        $("label.overlabel").overlabel();  // Refresh ?:?? hints, to remove them if we just put data into those fields.
                    });
                }
            }
            if (inputArtists.length > 0) {  // We have track duration data to fill into the form.
                addTracks(inputArtists.length);
                jQuery.each($artistGroup, function(i) {
                    $(this).attr("value",inputArtists[i]);  // Fill in the track artists.
                    $(this).change();
                });
            }
        };
    $("#es-tp-button-titles").click(function() {  // Parse Titles
        storeUndoData();
        getTrackInput();
        cleanBork();
        removeTrackNumbers();
        if ($("#es-tp-opt4").attr("checked")) { // Detect track times option
            jQuery.each(inputLines, function(i) {
                inputLines[i] = this.replace(/\(?\s?([0-9０-９]+[：，．:,.][0-9０-９]+)\s?\)?$/, "");
            });
        }
        cleanSpaces();
        if ($("#es-tp-opt9").attr("checked")) { // Data contains artist info option.
            parseArtists();  // Get the artist data out of the track titles.
            inputArtists = [];  // Throw away the artist data.
        }
        cleanTitles();
        inputTitles = inputLines;
        fillInData();
    });
    $("#es-tp-button-times").click(function() {  // Parse Track Times
        storeUndoData();
        getTrackInput();
        cleanBork();
        parseTimes();
        fillInData();
    });
    $("#es-tp-button-all").click(function() {  // Parse All
        storeUndoData();
        getTrackInput();
        cleanBork();
        removeTrackNumbers();
        parseTimes();
        cleanSpaces();
        if ($("#es-tp-opt9").attr("checked")) { // Data contains artist info option.
            parseArtists();
        }
        cleanTitles();
        inputTitles = inputLines;
        fillInData();
    });
    $("#es-tp-button-artists").click(function() {  // Parse Artists
        storeUndoData();
        getTrackInput();
        cleanBork();
        removeTrackNumbers();
        parseTimes(); // Get any times out of the input data.
        inputDurations = [];  // Throw away the parsed times.
        cleanSpaces();
        parseArtists();  // Get the artist data out of the track titles.
        inputTitles = [];  // Throw away the parsed titles.
        fillInData();
    });
});
