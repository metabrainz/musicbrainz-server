$.tablesorter.addWidget({
    id: "indexFirstColumn",
    format: function(table) {
        $('tbody tr', table).each(function (index) {
            $(this).find('td:first').html((index + 1));
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

$.tablesorter.addParser({
    id: "fancyNumber",
    is: function(s) {
        return /^[0-9]?[0-9,\.]*$/.test(s);
    },
    format: function(s) {
        return $.tablesorter.formatFloat( s.replace(/,/g,'') );
    },
    type: "numeric"
});

MB.Control.Tablesorter = function ($table, options) {
    $table.tablesorter(options);
}
