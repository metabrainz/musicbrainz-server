$(document).ready(function(){
/**************************************************
 *  Change JavaScript test text
 *************************************************/
    $('#browsertest').html('<span style="color: green;">Your browser is recent enough that it should be able to handle any JavaScript used on the site.</span>');
/**************************************************
 *  Attach tabs to User Preferences page
 *************************************************/
    $("#form-preferences-toc").tabs();
    $("#button-update-prefs").val("Update Preferences for all tabs");
    $("#javascript-preferences-toc").show();
    $("#javascript-preferences-toc").tabs();

});


























