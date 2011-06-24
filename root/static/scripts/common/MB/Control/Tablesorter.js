$(document).ready(function() {
    $.tablesorter.addWidget({
        id: "indexFirstColumn",
        format: function(table) {                               
            for(var i=0; i < table.tBodies[0].rows.length; i++) {
                $("tbody tr:eq(" + (i - 1) + ") td:first",table).html(i + '.');
            }                                                               
        }
    });

    $.tablesorter.addWidget({
        id: "evenRowClasses",
        format: function(table) {
            for(var i=0; i < table.tBodies[0].rows.length; i++) {
                if (i % 2 == 0) {
                    $("tbody tr:eq(" + (i-1) + ")", table).addClass("ev");
                } else {
                    $("tbody tr:eq(" + (i-1) + ")", table).removeClass("ev");
                }
            }
        }
    });

    MB.Control.Tablesorter = function () {
        $('table.tbl').tablesorter(MB.Control.Tablesorter.options);
    }
    MB.Control.Tablesorter.options = {};
});
