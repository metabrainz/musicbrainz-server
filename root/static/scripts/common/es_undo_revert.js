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
    /* Separate the Undo All and Revert All buttons from Guess Case controls.  */
    $esControlsDiv.append(document.createElement('br'))
                  .append(document.createElement('br'))
                  .css({"marginRight" : "-10pt"});  // Unpad the buttons from the parent fieldset.
    /* Create the Undo All button                                              */
    $form.each(function(i) {
        $esControlsDiv.append(new UndoAllButton().makeButton(i));
    });
    /* Separate the two buttons a little.                                      */
    esText = jQuery(document.createElement('span')).attr("id", "es-ur-spacer")
                                                   .html("&nbsp;&nbsp;&nbsp;")
                                                   .appendTo($esControlsDiv);
    /* Create the Undo All button.                                             */
    $form.each(function(i) {
        $esControlsDiv.append(new RevertAllButton().makeButton(i));
    });
    /* Insert the the Undo All and Revert div into the form.                   */
    $esControlsDiv.appendTo($form.get(0));
    $(".es-form").css("margin-bottom", "20pt");
});
/* Run Undo for each element in each group.                                    */
function undoAll() {
    $gcFieldsGroup.each(function(group) {
        $gcFieldsGroup[group].each(function(i) {
            $(this).attr("value", takeHistory($gcFieldsTitles[group], i));
        });
    });
}
/* Run Revert for each element in each group.                                  */
function revertAll() {
    emptyHistory();
    $gcFieldsGroup.each(function(group) {
        $gcFieldsGroup[group].each(function(i) {
            $(this).attr("value", readHistory($gcFieldsTitles[group], i));
        });
    });
}
