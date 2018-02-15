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

$('table.tbl').tablesorter({
    widgets: [ 'indexFirstColumn', 'evenRowClasses' ],
    headers: { 0: {sorter: false}, 2: { sorter: 'fancyNumber' }, 3: { sorter: 'fancyNumber' }, 4: { sorter: 'fancyNumber' }, 5: { sorter: 'fancyNumber' } },
    sortList: [ [5,1], [1,0] ] // order by descending number of entities, then name
});

$('#languages-table').tablesorter({
    widgets: [ 'indexFirstColumn', 'evenRowClasses' ],
    headers: { 0: {sorter: false}, 2: { sorter: 'fancyNumber' }, 3: { sorter: 'fancyNumber' }, 4: { sorter: 'fancyNumber' } },
    sortList: [ [4,1], [1,0] ] // order by descending number of entities, then name
});
$('#scripts-table').tablesorter({
    widgets: [ 'indexFirstColumn', 'evenRowClasses' ],
    headers: { 0: {sorter: false}, 2: { sorter: 'fancyNumber' } },
    sortList: [ [2,1], [1,0] ] // order by descending number of entities, then name
});