/********************************************************************************************
 * Edit Suite Helper Functions                                                              *
 ********************************************************************************************
 ********************************************************************************************
 * Function: handleCookie ( mode, cookie, default value / value to set )                    *
 *                                                                                          *
 * Basic interface to the cookie plugin.                                                    *
 * Returns the default value if the cookie was unset, returns the user's setting if it was. *
 ********************************************************************************************/
function handleCookie(mode, muffin, value) {
   if (!$.cookie(muffin) || mode === "set") {
        $.cookie(muffin, value, {
            expires: 15000
        });
       return value;
   } else if (mode === "get") {
       return $.cookie(muffin);
   }
}
/**************************************************************************************
* Function: .supersleight() ( none )                                                 *
*                                                                                    *
* Fix transparent png and other issues in IE6.                                       *
* from http://allinthehead.com/retro/338/supersleight-jquery-plugin                  *
**************************************************************************************/
jQuery.fn.supersleight = function(settings) {
    settings = jQuery.extend({
        imgs: true,
        backgrounds: true,
        shim: 'x.gif',
        apply_positioning: true
    }, settings);
    return this.each(function(){
        if (jQuery.browser.msie && parseInt(jQuery.browser.version) < 7 && parseInt(jQuery.browser.version) > 4) {
            jQuery(this).find('*').each(function(i,obj) {
                var self = jQuery(obj);
                // background pngs
                if (settings.backgrounds && self.css('background-image').match(/\.png/i) !== null) {
                    var bg = self.css('background-image');
                    var src = bg.substring(5,bg.length-2);
                    var mode = (self.css('background-repeat') == 'no-repeat' ? 'crop' : 'scale');
                    var styles = {
                        'filter': "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='" + src + "', sizingMethod='" + mode + "')",
                        'background-image': 'url('+settings.shim+')'
                    };
                    self.css(styles);
                };
                // image elements
                if (settings.imgs && self.is('img[src$=png]')){
                    var styles = {
                        'width': self.width() + 'px',
                        'height': self.height() + 'px',
                        'filter': "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='" + self.attr('src') + "', sizingMethod='scale')"
                    };
                    self.css(styles).attr('src', settings.shim);
                };
                // apply position to 'active' elements
                if (settings.applyPositioning && self.is('a, input') && self.css('position') === ''){
                    self.css('position', 'relative');
                };
            });
        };
    });
};
/**************************************************************************************
* Function: fullWidthConverter ( string )                                            *
*                                                                                    *
* Convert fullwidth characters to standard halfwidth Latin.                          *
**************************************************************************************/
function fullWidthConverter(inputString) {
    if (inputString === "") {
        return "";
    }
    var convertMe = function(str, p1) {
        return String.fromCharCode(p1.charCodeAt(0) - 65248);
    },
        i = inputString.length,
        newString = [];
    do {
        newString.push(inputString[i-1].replace(/([\uFF01-\uFF5E])/g,convertMe));
    } while (--i);
    return newString.reverse().join("");
}
/**************************************************************************************
* Function: countTracks ( none )                                                     *
*                                                                                    *
* Returns the number of tracks present in a release.                                 *
**************************************************************************************/
function countTracks() {
    return $(".releasetracks").length;
}
/********************************************************************************************
 * Class creation function from Simple JavaScript Inheritance, by John Resig                *
 * http://ejohn.org/blog/simple-javascript-inheritance/                                     *
 ********************************************************************************************/
(function() {
    var initializing = false,
    fnTest = /xyz/.test(function() { xyz; }) ? /\b_super\b/: /.*/; // The base Class implementation (does nothing)
    this.Class = function() {}; // Create a new Class that inherits from this class
    Class.extend = function(prop) {
        var _super = this.prototype; // Instantiate a base class (but only create the instance,
        // don't run the init constructor)
        initializing = true;
        var prototype = new this();
        initializing = false; // Copy the properties over onto the new prototype
        for (var name in prop) { // Check if we're overwriting an existing function
            if (prop.hasOwnProperty(name)) {  // filter unwanted properties from the prototype
                prototype[name] = typeof prop[name] == "function" && typeof _super[name] == "function" && fnTest.test(prop[name]) ? (function(name, fn) {
                    return function() {
                        var tmp = this._super; // Add a new ._super() method that is the same method
                        // but on the super-class});
                        this._super = _super[name]; // The method only need to be bound temporarily, so we
                        // remove it when we're done executing
                        var ret = fn.apply(this, arguments);
                        this._super = tmp;
                        return ret;
                    };
                })(name, prop[name]) : prop[name];
            }
        } // The dummy class constructor
        function Class() { // All construction is actually done in the init method
            if (!initializing && this.init) {
                this.init.apply(this, arguments);
            }
        } // Populate our constructed prototype object
        Class.prototype = prototype; // Enforce the constructor to be what we expect
        Class.constructor = Class; // And make this class extendable
        Class.extend = arguments.callee;
        return Class;
    };
})();
/********************************************************************************************
 * Function: alertUser                                                                      *
 *                                                                                          *
 * Handles popup messages                                                                   *
 * Types: "prompt" and "confirm" appear as popups                                           *
 ********************************************************************************************/
function alertUser(type, message, callback) {
    var typesettings, settings, popup, buttons;
    switch(type) {
        case "warning":
            typesettings = {
                buttons: {},
                image: "120px-Gnome-dialog-warning",
                imageAlt: text.ErrorTitle,
                title: text.WarningTitle
            };
            typesettings.buttons[text.Ok] = 1;
            break;
        case "error":
            typesettings = {
                buttons: {},
                image: "120px-Gnome-dialog-warning",
                imageAlt: text.ErrorTitle,
                title: text.ErrorTitle
            };
            typesettings.buttons[text.Ok] = 1;
            break;
        case "prompt":
            typesettings = {
                buttons: {},
                image: "120px-Gnome-dialog-warning",
                imageAlt: text.PromptTitle,
                title: text.PromptTitle
            };
            typesettings.buttons[text.Ok] = 1;
            break;
        case "confirm":
            typesettings = {
                buttons: {},
                image: "120px-Gnome-dialog-warning",
                imageAlt: text.ConfirmTitle,
                question: text.ConfirmQuestion,
                title: text.ConfirmTitle,
                msgcallback: callback
            };
            typesettings.buttons[text.Yes] = 1;
            typesettings.buttons[text.No] = 2;
            break;
        default:
    }
    settings = $.extend({
        imageLoc: filelocs.serverImage,
        question: " "
    }, typesettings);
    popup  = '<div class="'+windowTitle+'">' + settings.title + '</div>';
    popup += '<div class="'+floatLeft+'">';
    popup +=     '<img src="'+settings.imageLoc+settings.image+'.'+imageExt;
    popup +=        '" alt="'+settings.imageAlt+'" class="'+windowImage+'" />';
    popup += '</div>';
    popup += '<div class="'+windowMessage+'">'+message+'</div>';
    popup += '<div class="'+windowConfirm+'">'+settings.question+'</div>';
    $.prompt(popup,{
        buttons: settings.buttons,
        prefix: 'cleanblue',
        show: 'fadeIn',
        callback: settings.msgcallback
    });
}
/********************************************************************************************
 * Constructor Prototypes: esButton, GcButton                                               * 
 * Constructors: UndoButton, ArtistButton, TitleButton, GuessAll, UndoAll, RevertAll        *
 * Constructor Functions: makeArtistButton, makeTitleButton ( field number, field object )  *
 *                                                                                          *
 * Field number is the track number.  Field object is the field upon which Guess Case       *
 * will be operating.  Each of the constructor functions creates a Guess Case button        *
 * and an Undo button, inserts them into a div, then inserts that div into the DOM just     *
 * after the field which Guess Case is operating upon.  That div's css then positions       *
 * it on the same line as the field, aligned with the right side of the screen.             *
 *                                                                                          *
 * The UndoButton, ArtistButton, and TitleButton constructors could be used independantly,  *
 * though they are designed, as with the form creation templates, to normally be instanced  *
 * using the constructor functions.  This is not the case for the Guess All, Undo All, and  *
 * Revert All buttons.  These are designed merely to create the button and return it.  The  *
 * form initialization code in es_main (for Guess All) and in es_undo_revert (for Undo All  *
 * and Revert All) then positions those 3 buttons within a form.  The Undo All and Revert   *
 * All buttons will be created on any form which includes the undo_revert Edit Suite        *
 * module.  The Guess All button will only be created if both the guess_case module is      *
 * included in the template *and* if the es=1 flag is set within the fieldset line within   *
 * that same template.                                                                      *
 *                                                                                          *
// TODO: Make it possible to turn on Undo All / Revert All without also enabling Guess All.
// TODO: Make sure that the scripts don't error out if es=1 is not set in the template.
 *                                                                                          *
 * Creates Edit Suite and Guess Case button objects                                         *
 ********************************************************************************************/
var EsButton = Class.extend({
    init: function(type) {
        this.type = type;
        this.target = "";
        this.button = "generic";
    },
    makeButton: function(number) {
        var gcButton = $(document.createElement('input')).attr({
            id: "es-button-" + number + "-" + this.type + "-" + this.button,
            name: this.type,
            title: this.description,
            type: "button",
            value: this.text
        }).addClass(controlButton)
          .data("number", number)
          .data("target", this.target)
          .data("type", this.type);
        return gcButton;
    }
});
var GcButton = EsButton.extend({
    init: function(target, type) {
        this.type = type;
        this._super(this.type);
        this.description = text.ButtonTitleGuessCase;
        this.text = text.ButtonGuessCase;
        this.target = target;
        this.button = "guesscase";
    },
    makeButton: function(number) {
        return this._super(number).click(
            function() {
                storeHistory($(this).data("target").attr("value"), $(this).data("type"), $(this).data("number"));
                // Check for the presence of a "language" dropdown in the current form.
                if ($("select.release_language").length > 0) {
                    $(this).data("target").attr("value", guessMyCase($(this).data("type"), $(this).data("number"), $(this).data("target").attr("value"), $("select.release_language").selectedValues()[0]));
                } else {
                    $(this).data("target").attr("value", guessMyCase($(this).data("type"), $(this).data("number"), $(this).data("target").attr("value")));
                }
            }
        );
    }
});
var TitleButton = GcButton.extend({
    init: function(target) {
        this._super(target, "title");
        this.button = "gctitle";
    },
    makeButton: function(number) {
        return this._super(number);
    }
});
var ArtistButton = GcButton.extend({
    init: function(target) {
        this._super(target, "artist");
        this.button = "gcartist";
    },
    makeButton: function(number) {
        return this._super(number);
    }
});
var LabelButton = GcButton.extend({  // Used on the add / edit label forms.
    init: function(target) {
        this._super(target, "label");
        this.button = "gclabel";
    },
    makeButton: function(number) {
        return this._super(number);
    }
});
var UndoButton = EsButton.extend({
    init: function(target, type) {
        this._super(type);
        this.description = text.ButtonTitleUndo;
        this.target = target;
        this.text = text.ButtonUndo;
        this.button = "undo";
    },
    makeButton: function(number) {
        return this._super(number).click(
            function() {
                $(this).data("target").attr("value", takeHistory($(this).data("type"), $(this).data("number")));
            }
        );
    }
});
var GuessAllButton = EsButton.extend({
    init: function() {
        this._super("guessall");
        this.description = text.ButtonTitleGuessAll;
        this.text = text.ButtonGuessAll;
        this.button = "guessall";
    },
    makeButton: function(number) {
        return this._super(number).click(
            function() {
                $gcFieldsGroup.each(  // For each type of Guess Case field...
                    function(group) {
                        $gcFieldsGroup[group].each(   // ...and for each text field in that particular type of fields...
                            function(i) {
                                if ($(this).attr("value") !== "") {  // ...if that field isn't empty,
                                    var type = $gcFieldsTitles[group];
                                    var value = $(this).attr("value");
                                    storeHistory(value, type, i);  // save the undo history,
                                    if (type !== "duration") {  // then guess its case, unless it's a duration field...
                                        $(this).attr("value", guessMyCase(type, i, value));
                                    } else {
                                        if ($gcfixDuration) {  /// ...where we first want make sure that the user has that option turned on.
                                            $(this).attr("value", guessMyCase("duration", i, value));
                                        }
                                    }
                                }
                            }
                        );
                    }
                );
            }
        );
    }
});
var UndoAllButton = EsButton.extend({
    init: function() {
        this._super("undo");
        this.description = text.ButtonTitleUndoAll;
        this.text = text.ButtonUndoAll;
        this.button = "undoall";
    },
    makeButton: function(number) {
        return this._super(number).click(
            function() {
                undoAll();
            }
        );
    }
});
var RevertAllButton = EsButton.extend({
    init: function() {
        this._super("revertall");
        this.description = text.ButtonTitleRevertAll;
        this.text = text.ButtonRevertAll;
        this.button = "revertall";
    },
    makeButton: function(number) {
        return this._super(number).click(
            function() {
                revertAll();
            }
        );
    }
});
function makeTitleButton(i, element) {
    $(element).after($(document.createElement('div')).attr("id", "es-gc-div-title-"+i)
                                                     .addClass(buttonContainer)
                                                     .append(new TitleButton($(element)).makeButton(i)
                                                                                        .addClass("es-gc-button-gc-track")
                                                     )
                                                     .append($(document.createElement('span')).html("&nbsp;&nbsp;"))
                                                     .append(new UndoButton($(element),"title").makeButton(i)
                                                                                               .addClass("es-gc-button-gc-undo")
                                                     )
                    );
}
function makeArtistButton(i, element) {
    $(element).after($(document.createElement('div')).attr("id", "es-gc-div-artist-"+i)
                                                     .css("display", $(element).css("display"))
                                                     .addClass(buttonContainer)
                                                     .append(new ArtistButton($(element)).makeButton(i)
                                                                                         .addClass("es-gc-button-gc-artist")
                                                     )
                                                     .append($(document.createElement('span')).html("&nbsp;&nbsp;"))
                                                     .append(new UndoButton($(element),"artist").makeButton(i)
                                                                                                .addClass("es-gc-button-gc-undo")
                                                     )
                    );
}
function makeLabelButton(i, element) {
    $(element).after($(document.createElement('div')).attr("id", "es-gc-div-label-"+i)
                                                     .css("display", $(element).css("display"))
                                                     .addClass(buttonContainer)
                                                     .append(new LabelButton($(element)).makeButton(i)
                                                                                         .addClass("es-gc-button-gc-label")
                                                     )
                                                     .append($(document.createElement('span')).html("&nbsp;&nbsp;"))
                                                     .append(new UndoButton($(element),"label").makeButton(i)
                                                                                                .addClass("es-gc-button-gc-undo")
                                                     )
                    );
}
/********************************************************************************************
 * Function: addHints ( element collection, what text hint to use, left or center align )   *
 *                                                                                          *
 * Wrap needed elements for text hinting, then text-hinting.                                *
 ********************************************************************************************/
function addHints(group, mask, align) {
    group.each(function() {
        var id = $(this).attr("id");
        $(this).wrap('<div class="overlabel-wrapper" id="'+id+'-div"></div>');
        $(this).before('<label id="'+id+'-label" for="'+id+'"class="overlabel" style="width:' + 
            $(this).css("width") + ';">'+mask+'</label>');
        switch(align) {
            case "center":
                $('#'+id+'-label').css({'text-align': 'center'});
                break;
            case "left":
                $('#'+id+'-label').css({
                    'padding-left': '5px',
                    'text-align': 'left'
                });
                break;
            default:
        }
    });
}
/********************************************************************************************
 * Function: overlabel ( none )                                                             *
 *                                                                                          *
 * Original concept by Mike Brittain                                                        *
 * Written by Scott Sauyet                                                                  *
 * Modified by Dave Methvin                                                                 *
 * Modified by Aristotle Pagaltzis                                                          *
 * Modified by Guy Fraser                                                                   *
 * Modified by Brian Schweitzer (BrianFreud)                                                *
 *                                                                                          *
 * Creates a label overlay for text input fields which hides when the user clicks into      *
 * the field, stays hidden if the user enters text, or is re-displayed if the field is      *
 * left blank when the user moves out of the field.                                         *
 *                                                                                          *
 * http://scott.sauyet.com/thoughts/archives/2007/03/31/overlabel-with-jquery/              *
 * Licensed as Creative Commons Public Domain Dedication.                                   *
 ********************************************************************************************/
(function($) {
    $.fn.overlabel = function(options) {
        var opts = $.extend({},
        $.fn.overlabel.defaults, options);
        var selection = this.filter('label[for]').map(function() {
            var label = $(this);
            var id = label.attr('for');
            var field = document.getElementById(id);
            if (!field) {
                return;
            }
            var o = $.meta ? $.extend({},
            opts, label.data()) : opts;
            label.addClass(o.label_class);
            var hide_label = function() {
                label.css(o.hide_css);
            };
            var show_label = function() {
                this.value || label.css(o.show_css);
            };
            $(field).parent()
                    .addClass(o.wrapper_class)
                    .end()
                    .focus(hide_label)
                    .blur(show_label)
                    .each(hide_label)
                    .each(show_label);
            return this;
        });
        return opts.filter ? selection: selection.end();
    };
    $.fn.overlabel.defaults = {
        label_class: 'overlabel-apply',
        wrapper_class: 'overlabel-wrapper',
        hide_css: {
            'display': 'none'
        },
        show_css: {
            'display': 'inline',
            'cursor': 'text'
        },
        filter: false
    };
})(jQuery);
/********************************************************************************************
 * Function: addErrorReport
 * 
 * Displays error report for a given input field
 ********************************************************************************************/
function addErrorReport(type, number) {
    var element;
    switch (type) {
    case "title":
        element = $($trackTitleGroup).get(number);
        leftDistance = -270;
        break;
    case "artist":
        element = $artistGroup.get(number);
        leftDistance = -429;
        break;
    case "duration":
        element = $durationGroup.get(number);
        leftDistance = -200;
        break;
    case "label":
        element = $labelGroup.get(number);
        leftDistance = -200;
        break;
    case "text":
        element = $textTextGroup.get(number);
        leftDistance = -270;
        break;
    case "textartist":
        element = $textArtistGroup.get(number);
        leftDistance = -429;
        break;
    }
    $("#" + $(element).attr("id") + "-hint").remove();
    if (howManyErrors(type, number) > 0) {
        $(element).inputHintBox({
            className: 'es_error_hint',
            source: 'html',
            html: takeErrors(type, number),
            incrementLeft: leftDistance,
            incrementTop: 20,
            id: $(element).attr("id") + "-hint",
            attachTo: $(element).parent()
        });
        $(element).addClass("es_field_error");
    } else {
        $(element).attr("title", "");
        $(element).removeClass("es_field_error");
    }
}
/**************************************************************************************
* Function: removeTrack ( number )                                                    *
*                                                                                     *
* Removes the specified track.                                                        *
**************************************************************************************/
function removeTrack(trackToRemove) {
    removeRecord(countTracks(), trackToRemove);  // Update the undo stack.
    if (countTracks() != trackToRemove) {  // check that we're not removing the last track.
        var currentTrack = trackToRemove;
        do {
            $("#form-add-release-tracks-track_" + currentTrack + "-name").attr("value",$("#form-add-release-tracks-track_" + (parseInt(currentTrack,10) + 1) + "-name").attr("value"));
            $("#form-add-release-tracks-track_" + currentTrack + "-duration").attr("value",$("#form-add-release-tracks-track_" + (parseInt(currentTrack,10) + 1) + "-duration").attr("value"));
            $("#form-add-release-tracks-artist-" + currentTrack).attr("value",$("#form-add-release-tracks-artist-" + (parseInt(currentTrack,10) + 1)).attr("value"));    
            currentTrack++;
        } while (currentTrack < countTracks());
    }
    $(".releasetracks:last").remove();
    $(".es-button-inserttrack:last").attr("value",text.AddTrack+ ' ➡');
}
/**************************************************************************************
* Function: insertTrack ( number )                                                    *
*                                                                                     *
* Inserts a track after the track specified.  If no track number is specified, or if  *
* the track number specified is higher than the highest track number present, the new *
* track is added to the end of the release.                                           *
**************************************************************************************/
function insertTrack(insertWhere) {
    if (typeof(insertWhere) == "undefined") {
        insertWhere = countTracks() + 1;
    } else if (insertWhere > countTracks()) {
        insertWhere = countTracks() + 1;
    }
    var thisTrack = parseInt(countTracks(),10) + 1;
    /* Take the innerHTML of the stored copy of track 1, change the ids, and add it to the end of the release. */
    $("#form-add-release-tracks-track_"+countTracks()).after('<br /><div class="releasetracks" id="form-add-release-tracks-track_' + thisTrack + '">' + rawTrack.replace(/1/g, thisTrack) + '</div>');
    /* Remove the ?:?? from the duration field. */
    $("#form-add-release-tracks-track_" + thisTrack + "-duration").attr("value","");
    /* Add hinting to the duration field on the new track. */
    addHints($("#form-add-release-tracks-track_" + thisTrack + "-duration"), "?:??", "center");
    $("label.overlabel").overlabel();
    /* Add the Guess Case buttons. */
    makeTitleButton(parseInt(thisTrack,10) - 1, $("#form-add-release-tracks-track_" + thisTrack + "-name"));
    makeArtistButton(parseInt(thisTrack,10) - 1, $("#form-add-release-tracks-artist-" + thisTrack));
    /* Add the insert and remove buttons. */
    $("#form-add-release-tracks-track_" + thisTrack).prepend('<div style="position: absolute; display: inline; margin-left: -1.4em;"> ' +
            '<input class="es-button-removetrack" type="button" value="' + text.Remove + ' ➡" style="font-size: .9em; margin-top: 1em;">' +
            '<br />' +
            '<input class="es-button-inserttrack" type="button" value="' + text.InsertTrack + ' ➡" style="font-size: .9em; margin-top: 2.7em;">')
        .css({'margin-top': '.3em'});
    $(".es-button-inserttrack").attr("value",text.InsertTrack+ ' ➡');
    $(".es-button-inserttrack:last").attr("value",text.AddTrack+ ' ➡');
    $("#form-add-release-tracks-track_" + thisTrack + " .es-button-inserttrack").click(function() {
        insertTrack(thisTrack);
    });
    $("#form-add-release-tracks-track_" + thisTrack + " .es-button-removetrack").click(function() {
        removeTrack(i+1);
    });
    /* Update the global collection variables. */
    $trackTitleGroup = $("input[class='track_name']");
    $artistGroup = $("input[class='artist_name']");
    $durationGroup = $("input[class='track_duration']");
    $gcFieldsGroup = $([$trackTitleGroup, $artistGroup, $durationGroup, $labelGroup, $textTextGroup, $textArtistGroup]);
    if (insertWhere != countTracks()) { // We're inserting into the release.
        /* Extend the undo and error count arrays to handle the new track. */
        insertNewRecord(insertWhere, thisTrack);
        /* Shift the form data. */
// TODO: Once switch.tt is back in, we also need to shift the locked artists here.
        var currentTrack = countTracks();
        do {
            $("#form-add-release-tracks-track_" + currentTrack + "-name").attr("value",$("#form-add-release-tracks-track_" + (parseInt(currentTrack,10) - 1) + "-name").attr("value"));
            $("#form-add-release-tracks-track_" + currentTrack + "-duration").attr("value",$("#form-add-release-tracks-track_" + (parseInt(currentTrack,10) - 1) + "-duration").attr("value"));
            $("#form-add-release-tracks-artist-" + currentTrack).attr("value",$("#form-add-release-tracks-artist-" + (parseInt(currentTrack,10) - 1)).attr("value"));
            currentTrack--;
        } while (currentTrack > (parseInt(insertWhere,10) + 1) && currentTrack !== 0);
        $("#form-add-release-tracks-track_" + currentTrack + "-name").attr("value","");
        $("#form-add-release-tracks-track_" + currentTrack + "-duration").attr("value","");
        $("#form-add-release-tracks-artist-" + currentTrack).attr("value","");
    } else { // We're appending to the end of the release.
        /* Extend the undo and error count arrays to handle the new track. */
        addNewRecord(thisTrack);
    }
}
/**************************************************************************************
* Function: catalogNumberCheck ( none )                                               *
*                                                                                     *
* Binds post-edit events to check for problematic catalog numbers.                    *
**************************************************************************************/
function catalogNumberCheck() {
    $catalogGroup.each(function() {
        $(this).blur(function() {
            $("#" + $(this).attr("id") + "-hint").remove();
            $(this).attr("value",jQuery.trim($(this).attr("value")));
            if(new RegExp(/^[0B][A-Z0-9]{9}$/).test($(this).attr("value"))) {
                $(this).inputHintBox({
                    className: 'es_error_hint',
                    source: 'html',
                    html: text.AmazonCatalog,
                    incrementLeft: -300,
                    incrementTop: 20,
                    id: $(this).attr("id") + "-hint",
                    attachTo: $(this).parent()
                });
                $(this).addClass("es_field_error");
            } else {
                $(this).removeClass("es_field_error");
            }
        });
    });
}
/**************************************************************************************
* Function: updateEvents ( none )                                                     *
*                                                                                     *
* Updates the identifiers for release events.                                         *
**************************************************************************************/
function updateEvents() {
    $("label.overlabel").overlabel();
    $("label.overlabel").toggle().toggle().show();
    $("input").each(function() { // Refresh the input masks.
        $(this).triggerHandler("focus");
        $(this).triggerHandler("blur");
    });
    $(".es-events-remove").each(function(i) {  // Rebind the remove events.
        $(this).click(function() {
            $("#es-events > table > tbody > tr:eq("+i+")").remove();
            updateEvents();
        });
    });
    catalogNumberCheck();
    /* Update the global collection variables for release events. */
    $dateYearGroup = $("input[id$='date-year']");
    $dateMonthGroup = $("input[id$='date-month']");
    $dateDayGroup = $("input[id$='date-day']");
    $labelGroup = $("input[class='release_event_label']");
    $catalogGroup = $("input[class='release_event_catalog']");
    $barcodeGroup = $("input[class='release_event_barcode']");
    $gcFieldsGroup = $([$trackTitleGroup, $artistGroup, $durationGroup, $labelGroup, $textTextGroup, $textArtistGroup]);
}
/**************************************************************************************
* Function: .swap ( none )                                                            *
*                                                                                     *
* Swap the position of two elements.                                                  *
* from http://brandonaaron.net/blog/2007/06/10/jquery-snippets-swap                   *
**************************************************************************************/
jQuery.fn.swap = function(b) {
    b = jQuery(b)[0];
    var a = this[0],
        a2 = a.cloneNode(true),
        b2 = b.cloneNode(true),
        stack = this;
    a.parentNode.replaceChild(b2, a);
    b.parentNode.replaceChild(a2, b);
    stack[0] = a2;
    return this.pushStack( stack );
};
/**************************************************************************************
* Function: setTrackMovers ( none )                                                   *
*                                                                                     *
* Handles the move up / down track manipulators.                                      *
**************************************************************************************/
function setTrackMovers() {
    $(".es-track-up").show();
    $(".es-track-up:first").hide();
    $(".es-track-down").show();
    $(".es-track-down:last").hide();
    $(".es-track-up").unbind("click");
    $(".es-track-down").unbind("click");
    $(".es-button-inserttrack").attr("value",text.InsertTrack+ ' ➡');
    $(".es-button-inserttrack:last").attr("value",text.AddTrack+ ' ➡');
    $("label.overlabel").overlabel();
    $(".es-track-up").each(function(i) {
        $(this).click(function() {
            $(".track_number:eq(" + i + ")").attr("value", i);
            $(".track_number:eq(" + (i - 1) + ")").attr("value", (i + 1));
            $(".releasetracks:eq(" + i + ")").swap(".releasetracks:eq(" + (i - 1) + ")");
            setTrackMovers();
        });
    });
    $(".es-track-down").each(function(i) {
        $(this).click(function() {
            $(".track_number:eq(" + i + ")").attr("value", (i + 2));
            $(".track_number:eq(" + (i + 1) + ")").attr("value", (i + 1));
            $(".releasetracks:eq(" + i + ")").swap(".releasetracks:eq(" + (i + 1) + ")");
            setTrackMovers();
        });
    });
}
/**************************************************************************************
* Function: addEvent ( none )                                                         *
*                                                                                     *
* Adds a release event.                                                               *
**************************************************************************************/
function addEvent() {
    var eventCount = $("#es-events > table > tbody > tr").length;
    $("#es-events > table > tbody").append("<tr>" + rawEvent.replace(/event\-1/g,"event-"+(parseInt(eventCount,10)+1)) + "</tr>");
    $("#es-events > table > tbody > tr:last > input").attr("value","");  // Clear out any data that may have been carried over.
    $("#es-events > table > tbody > tr:last > select").attr("value","");  // Clear out any data that may have been carried over.
    $("label.overlabel").overlabel();
    $("label.overlabel").toggle().toggle().show();
    $("input").each(function() { // Refresh the input masks.
        $(this).triggerHandler("focus");
        $(this).triggerHandler("blur");
    });
    $(".es-events-remove").each(function(i) {
        $(this).click(function() {
            $("#es-events > table > tbody > tr:eq("+i+")").hide();
            $("#es-events > table > tbody > tr:eq("+i+") > input[id$='remove'])").attr("checked",true);
        });
    });
    catalogNumberCheck();
    /* Update the global collection variables for release events. */
    $dateYearGroup = $("input[id$='date-year']");
    $dateMonthGroup = $("input[id$='date-month']");
    $dateDayGroup = $("input[id$='date-day']");
    $labelGroup = $("input[class='release_event_label']");
    $catalogGroup = $("input[class='release_event_catalog']");
    $barcodeGroup = $("input[class='release_event_barcode']");
    $gcFieldsGroup = $([$trackTitleGroup, $artistGroup, $durationGroup, $labelGroup, $textTextGroup, $textArtistGroup]);
}
function validateType() {
    var CompNames = new RegExp("(Best of|Greatest Hits|Compilation|Collection|Anthology|Collection)","i");
    if (CompNames.test($(".release-title:eq(1)").attr("value"))) {
        if ($(".release_type:eq(0)").selectedValues() != 4) { // If not a compilation
            alertUser("warning",text.LikelyACompilation);
        }
    }
}
$(function() {
    /* Work around IE6 and its serious layout issues with all the css.  */
    /* Without this, the sidebar would be placed below the entire edit form and various other problems would arise.  */
    /* IE6 isn't pretty, but this at least makes it a little more functional. */
    if (jQuery.browser.msie && parseInt(jQuery.browser.version) < 7) {
        $('body').supersleight({shim: '/static/images/es/x.gif'});
        $("#header").after('<table><tr><td id="es-ie6-sidebar"></td><td id="es-ie6-right"></td></tr></table>');
        document.getElementById("es-ie6-sidebar").appendChild(document.getElementById("sidebar"));
        document.getElementById("es-ie6-right").appendChild(document.getElementById("container"));
        $("#es-ie6-sidebar").attr("valign","top");
        $("#es-ie6-right").attr("valign","top");
        $("#content").css("margin-left","0");
    }
    /* -------------------------------------------------------------------------*/
    /* Swap JavaScript / no-JavaScript text                                     */
    /* -------------------------------------------------------------------------*/
    $(".only-if-no-javascript").hide();
    $(".only-if-javascript").show();
    /* -------------------------------------------------------------------------*/
    /* Remove the ?:?? that is in the duration fields - text hinting can't      */
    /* accidentally be submitted, they can.                                     */
    /* -------------------------------------------------------------------------*/
    $durationGroup.each(function(i) {
        if ($(this).attr("value") == "?:??") {
            $(this).attr("value", "");
        }
    });
    /* -------------------------------------------------------------------------*/
    /* Store the "clean copy" of the first track, to use as a template later.   */
    /* -------------------------------------------------------------------------*/
    rawTrack = $("#form-add-release-tracks-track_1").html();
    /* -------------------------------------------------------------------------*/
    /* Add input hints to duration and release event fields and do general      */
    /* cleaning up of release events for nicer UI.                              */
    /* -------------------------------------------------------------------------*/
    $("#es-events th:first").html("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
    $("td:has(.release_event_remove)").hide();
    $(".no_label:has(#form-add-release-tracks-more-events)").remove();
    $(".release_event_format option:first").text("[ " + text.SelectFormat + " ]");
    $(".release_event_country option:first").text("[ " + text.SelectCountry + " ]");
    $(".release_type option:first").text("[ " + text.SelectOne + " ]");
    $(".release_status option:first").text("[ " + text.SelectOne + " ]");
    $("#es-events > table > tbody > tr").each(function() {
        $(this).prepend('<td><img class="es-events-remove" alt="' + text.RERemove + '" src="/static/images/release_editor/remove-off.gif" /></td>');
    });
    $dateYearGroup.css("width","4em");
    $dateMonthGroup.css("width","2.5em");
    $dateDayGroup.css("width","2.5em");
    addHints($dateYearGroup, text.YearMask, "left");
    $("label.overlabel").overlabel();
    addHints($dateMonthGroup, text.MonthMask, "left");
    $("label.overlabel").overlabel();
    addHints($dateDayGroup, text.DayMask, "left");
    $("label.overlabel").overlabel();
    addHints($labelGroup, text.LabelMask, "left");
    $("label.overlabel").overlabel();
    addHints($catalogGroup, text.CatalogMask, "left");
    $("label.overlabel").overlabel();
    addHints($barcodeGroup, "00000000000000", "left");
    $("label.overlabel").overlabel();
    $(".overlabel").css({'padding-left': '5px','text-align': 'left'}); // Force all the "left" items to actually go to the left (avoids issues with the date masks).
    $dateYearGroup.css({'text-align': 'center'});
    $dateMonthGroup.css({'text-align': 'center'});
    $dateDayGroup.css({'text-align': 'center'});
    addHints($durationGroup, "?:??", "center");
    $("label.overlabel").overlabel();
    rawEvent = $("#es-events > table > tbody > tr:first").html();
    $("#es-events").append('<br /><input style="margin-left: 2.5em;" type="button" id="es-button-add-event" value="' + text.AddRE + '" />');
    $("#es-button-add-event").click(function() {
        addEvent();
    });
    $(".es-events-remove").each(function(i) {
        $(this).click(function() {
            $("#es-events > table > tbody > tr:eq("+i+")").hide();
            $("#es-events > table > tbody > tr:eq("+i+") > input[id$='remove'])").attr("checked",true);
        });
    });
    $("label.overlabel").toggle().toggle().show();
    $("input").each(function() { // Refresh the input masks.
        $(this).triggerHandler("focus");
        $(this).triggerHandler("blur");
    });
    $("#label-form-create-label-name-label, #label-form-edit-label-name-label").remove();  // Don't overlabel label field on add / edit label forms.
    /* Give a heads up if it appears as though an ASIN has been entered as a catalog number. */
    catalogNumberCheck();
    /* -------------------------------------------------------------------------*/
    /* Add track insertion, manipulation, and removal controls.                 */
    /* -------------------------------------------------------------------------*/
    $(".releasetracks").prepend('<div class="es-track-controls" style="position: absolute; display: inline; margin-left: -1.4em;">' +
            '<input class="es-button-removetrack" type="button" value="' + text.Remove + ' ➡" style="font-size: .9em; margin-top: 1em;">' +
            '<br />' +
            '<input class="es-button-inserttrack" type="button" value="' + text.InsertTrack + ' ➡" style="font-size: .9em; margin-top: 2.4em;">')
        .css({'margin-top': '.3em'});
    $(".es-button-inserttrack:last").attr("value",text.AddTrack+ ' ➡');
    $(".es-button-inserttrack").each(function(i) {
        $(this).click(function() {
           insertTrack(i+1); 
        });
    });
    $(".es-button-removetrack").each(function(i) {
        $(this).click(function() {
            removeTrack(i+1);
        });
    });
    $(".track_remove").hide();
    $(".track_number").before('<input value="↑" title="' + text.MoveUp + '" class="es-track-controls es-track-up" type="button" style="padding:0 3px 0 3px;font-weight:bolder;"/>');
    $(".track_number").after('<input value="↓" title="' + text.MoveDown + '" class="es-track-controls es-track-down" type="button" style="padding:0 3px 0 3px;font-weight:bolder;"/>');
    setTrackMovers();
    $("#form-controls").prepend('<input id="es-button-manipulators" type="button" value="' + text.Manipulators + '" style="float: left;" />')
                       .css({"marginRight" : "-10pt"});
    $("#es-button-manipulators").click(function() {
        $(".es-track-controls").toggle();
        $(".es-track-up:first").hide();
        $(".es-track-down:last").hide();
    });
    $(".es-track-controls").hide();
    /* Shrink breadcrumbs for browsers who render them too large, so that they wrap. */
    if (new RegExp("epiphany","i").test(navigator.userAgent)) {
        $("#wizard_breadcrumbs > li").css("font-size","11.1");
    }
    /* Add warning for compilations not set to compilation. */
    $(".release_type:eq(0)").change(validateType);
});
