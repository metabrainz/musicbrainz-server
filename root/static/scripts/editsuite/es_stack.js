/* This file contains stack creation and handling functions
   used by the Edit Suite to record and undo changes to data */

var dataHistory = [];
var errorLog = [];

/* Return the number of items in the history of a particular field */
function howMuchHistory(type, number) {
    return dataHistory[type][number].length;
}
/* Store text in history, if it has been changed */
function storeHistory(text, type, number) {
console.log(text + type + number);
    if (dataHistory[type][number][howMuchHistory(type, number)] != text || howMuchHistory(type, number) === 0) {
        dataHistory[type][number].push(text);
    }
}
/* Read the most recent item in history */
function readHistory(type, number) {
    return dataHistory[type][number][howMuchHistory(type, number) - 1];
}
/* Read and remove the most recent item in history */
function takeHistory(type, number) {
    if (howMuchHistory(type, number) > 0) {
        return dataHistory[type][number].pop();
    } else {
        return "";
    }
}
/* Empty all change histories, but keep the stored initial state */
function emptyHistory() {
    $gcFieldsTitles.each(function(k) {
        for (var i = 0; i < dataHistory[$gcFieldsTitles[k]].length; i++) {
            $gcFieldsTitles[k].length = 1;
        }
    });
}
/* Return the number of items in the history of a particular field */
function howManyErrors(type, number) {
    return errorLog[type][number].length;
}
/* Store text in history, if it has been changed */
function storeError(text, type, number) {
    if (errorLog[type][number][howManyErrors(type, number)] != text || howManyErrors(type, number) === 0) {
        errorLog[type][number].push("\u2043 "+text);
    }
}
/* Return all errors for a given type+number pair */
function clearErrors(type, number) {
    errorLog[type][number].length = 0;
    return true;
}
/* Return and remove all errors for a given type+number pair as a string, <br /> separated */
function takeErrors(type, number) {
    var itemErrors = errorLog[type][number].join("<br />");
    errorLog[type][number].length = 0;
    return itemErrors;
}
/* Add a new item to the end of each array.  (Used for adding a track on the fly.) */
function addNewRecord(recordCount) {
    recordCount = recordCount - 1;
    jQuery.each(["title", "artist", "duration"], function() {
        dataHistory[this][recordCount] = [""];
        errorLog[this][recordCount] = [];
    });
}
/* Add a new item within the array. */
function insertNewRecord(insertionPoint, recordCount) {
    addNewRecord(recordCount);
    jQuery.each(["title", "artist", "duration"], function() {
        var currentRecord = recordCount - 1;
        do {
            dataHistory[this][currentRecord] = dataHistory[this][currentRecord-1];  // Shift all relevant histories forward by one.
            currentRecord--;
        } while (currentRecord > insertionPoint && currentRecord != 0);
        dataHistory[this][currentRecord] = [""];  // Empty the history for the inserted record.
    });
}
/* Remove an item from the array. */
function removeRecord(recordCount, recordToRemove) {
    jQuery.each(["title", "artist", "duration"], function() {
        var currentRecord = recordToRemove - 1;
        if (recordCount != recordToRemove) {  // Check that we're not removing the last track.
            do {
                dataHistory[this][currentRecord] = dataHistory[this][currentRecord+1];  // Shift all relevant histories backwards by one.
                currentRecord++;
            } while (currentRecord < recordCount);
        }
        dataHistory[this].pop();
    });
}
$(function() {
    /* Create two array of arrays to store data changes and error reports, then initialize them */
    $gcFieldsGroup.each(function(group) {
        dataHistory[$gcFieldsTitles[group]] = [];
        errorLog[$gcFieldsTitles[group]] = [];
        var j = $gcFieldsTitles[group];
        $gcFieldsGroup[group].each(function(i) {
            dataHistory[$gcFieldsTitles[group]][i] = [];
            errorLog[$gcFieldsTitles[group]][i] = [];
        });
    });
    /* Store onload form field values */
    $gcFieldsGroup.each(function(group) {
        $gcFieldsGroup[group].each(function(i) {
            storeHistory($(this).attr("value"), $gcFieldsTitles[group], i);
        });
    });
});
