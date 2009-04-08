/********************************************************************************************
 * File: es_undo_revert.js
 * 
 * Function: 1) Hooks into the Undo / Revert panel in the Edit Suite, to make that panel
 *              functional.
 *           2) Enables the functionality for the Undo All and Revert All buttons.
 * 
 * Note: The Undo buttons are not created in this file.  They are created automatically when 
 *       any Guess Case button is created, using the button factory in es_main.
 *
 * Note: If Undo All and Revert are not needed in a form, this module can be safely excluded
 *       within the Edit Suite options in the form's template.
 * 
 ********************************************************************************************/

/********************************************************************************************
 * function: (default)
 * 
 * Create, bind, and insert Undo All and Revert All buttons into a form.
 * 
 ********************************************************************************************/
$(function() {
    var $esControlsDiv = $("#esControlsDiv");
    var $spaceBetween = $("#es-ur-spacer");
    /* Turn on the tooltips, unless user has them off in preferences. */
    if ($noTipsCheck) {
        $("#es-ur-controls *").tooltip();
    }
    $('#es-button2').click(function() {
        $("#es-sg-explain").text("Undo or redo Edit Suite and Guess Case changes.");
        $(".esdisplay").hide();
        $("#es-ur").show();
    });
    /* Separate the Undo All and Revert All buttons from Guess Case controls   */
    $esControlsDiv.append(document.createElement('br'))
                  .append(document.createElement('br'));
    /* Create the Undo All button                                              */
    $form.each(function(i) {
        $esControlsDiv.append(new UndoAllButton().makeButton(i));
    });
    /* Separate the two buttons a little                                       */
    esText = jQuery(document.createElement('span')).attr("id", "es-ur-spacer")
                                                   .html("&nbsp;&nbsp;&nbsp;")
                                                   .appendTo($esControlsDiv);
    /* Create the Undo All button                                              */
    $form.each(function(i) {
        $esControlsDiv.append(new RevertAllButton().makeButton(i));
    });
    /* Insert the the Undo All and Revert div into the form.                   */
    $esControlsDiv.appendTo($form.get(0));
    $(".es-form").css("margin-bottom", "20pt");
    /* Restore state of checkboxes between forms                               */
    function maintainPersistanceShow(cookie, defaultval, button, checkbox) { 
        /* Make show / hide selection persistent                               */
        switch ($.cookie(cookie)) {
        /* Show the button, per persistant value                               */
        case 'off':
            $(button).show();
            checkbox.attr("checked", false);
            if (cookie == "es-button-ra") {
                $spaceBetween.show();
            }
            break; 
        /* Hide the button, per persistant value                               */
        case 'on':
            $(button).hide();
            checkbox.attr("checked", true);
            if (cookie == "es-button-ra") {
                $spaceBetween.hide();
            }
            break;
        /* Set the cookie the first time                                       */
        default:
            $.cookie(cookie, defaultval, {
                expires: 15000
            });
            break;
        }
    }
    maintainPersistanceShow("es-button-ua", "off", $("#ESButton-ua"), $("#es-ur-ur3"));
    maintainPersistanceShow("es-button-ra", "off", $("#ESButton-ra"), $("#es-ur-ur4"));
    /* Make show / hide selection persistent                                   */
    function maintainPersistanceWarn(cookie, defaultval, checkbox) {
        switch ($.cookie(cookie)) {
        case 'off':
            checkbox.attr("checked", false);
            break;
        case 'on':
            checkbox.attr("checked", true);
            break;
        /* Set the cookie the first time                                       */
        default:
            $.cookie(cookie, defaultval, {
                expires: 15000
            });
            break;
        }
    }
    maintainPersistanceWarn("es-option-ua", "on", $("#es-ur-ur1"));
    maintainPersistanceWarn("es-option-ra", "on", $("#es-ur-ur2"));
    $("#es-ur-ur1").click(function() {
        if ($(this).attr("checked") === true) {
            $.cookie('es-option-ua', 'on', {
                expires: 15000
            });
        } else {
            $.cookie('es-option-ua', 'off', {
                expires: 15000
            });
        }
    });
    $("#es-ur-ur2").click(function() {
        if ($(this).attr("checked") === true) {
            $.cookie('es-option-ra', 'on', {
                expires: 15000
            });
        } else {
            $.cookie('es-option-ra', 'off', {
                expires: 15000
            });
        }
    });
    /* Show / Hide the Undo All and Revert All buttons when user changes options in the ES panel */
    $("#es-ur-ur3").click(function() {
        if ($(this).attr("checked") === true) {
            $("#ESButton-ua").hide();
            $.cookie('es-button-ua', 'on', {
                expires: 15000
            });
        } else {
            $("#ESButton-ua").show();
            $.cookie('es-button-ua', 'off', {
                expires: 15000
            });
        }
    });
    $("#es-ur-ur4").click(function() {
        if ($(this).attr("checked") === true) {
            $("#ESButton-ra").hide();
            $spaceBetween.hide();
            $.cookie('es-button-ra', 'on', {
                expires: 15000
            });
        } else {
            $("#ESButton-ra").show();
            $spaceBetween.show();
            $.cookie('es-button-ra', 'off', {
                expires: 15000
            });
        }
    });
});
/* Callback function for Undo All                                              */
function undoAllConfirm(i) {
    if (i) {
        /* Run Undo for each element in each group                             */
        $gcFieldsGroup.each(function(group) {
            $gcFieldsGroup[group].each(function(i) {
                $(this).attr("value", takeHistory($gcFieldsTitles[group], i));
            });
        });
    }
    return true;
}
/* Callback function for Revert All                                            */
function revertAllConfirm(i) {
    if (i) {
        emptyHistory();
        $gcFieldsGroup.each(function(group) {
            $gcFieldsGroup[group].each(function(i) {
                $(this).attr("value", readHistory($gcFieldsTitles[group], i));
            });
        });
    }
    return true;
}
