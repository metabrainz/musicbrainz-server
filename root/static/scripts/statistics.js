const tablesorter = require('tablesorter');

tablesorter.addWidget({
    id: "indexFirstColumn",
    format: function (table) {
        $('tbody tr', table).each(function (index) {
            $(this).find('td:first').html((index + 1));
        });
    }
});

tablesorter.addWidget({
    id: "evenRowClasses",
    format: function (table) {
        $('tbody tr', table).each(function (index) {
            if ((index + 1) % 2 == 0) {
                $(this).addClass("even");
            } else {
                $(this).removeClass("even");
            }
        });
    }
});

tablesorter.addParser({
    id: "fancyNumber",
    is: function (s) {
        return /^[0-9]?[0-9,\.]*$/.test(s);
    },
    format: function (s) {
        return tablesorter.formatFloat( s.replace(/,/g,'') );
    },
    type: "numeric"
});
