$(document).ready(function() {
    $.tablesorter.addWidget({
        id: "indexFirstColumn",
        format: function(table) {                               
            $('tbody tr', table).each(function (index) {
                $(this).find('td:first').html((index + 1) + '.');
            });
        }
    });

    $.tablesorter.addWidget({
        id: "evenRowClasses",
        format: function(table) {
            $('tbody tr', table).each(function (index) {
                if ((index + 1) % 2 == 0) {
                    $(this).addClass("ev");
                } else {
                    $(this).removeClass("ev");
                }
            });
        }
    });

    MB.Control.Tablesorter = function () {
        $('table.tbl').tablesorter(MB.Control.Tablesorter.options);
    }
    MB.Control.Tablesorter.options = {};
});
