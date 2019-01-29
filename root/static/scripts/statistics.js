const tablesorter = require('tablesorter');

tablesorter.addWidget({
  format: function (table) {
    $('tbody tr', table).each(function (index) {
      $(this).find('td:first').html((index + 1));
    });
  },
  id: 'indexFirstColumn',
});

tablesorter.addWidget({
  format: function (table) {
    $('tbody tr', table).each(function (index) {
      if ((index + 1) % 2 === 0) {
        $(this).addClass('even');
      } else {
        $(this).removeClass('even');
      }
    });
  },
  id: 'evenRowClasses',
});

tablesorter.addParser({
  format: function (s) {
    return tablesorter.formatFloat(s.replace(/,/g, ''));
  },
  id: 'fancyNumber',
  is: function (s) {
    return /^[0-9]?[0-9,.]*$/.test(s);
  },
  type: 'numeric',
});

$('#languages-table').tablesorter({
  headers: {0: {sorter: false}, 2: {sorter: 'fancyNumber'}, 3: {sorter: 'fancyNumber'}, 4: {sorter: 'fancyNumber'}},
  // order by descending number of entities, then name
  sortList: [[4, 1], [1, 0]],
  widgets: ['indexFirstColumn', 'evenRowClasses'],
});

$('#scripts-table').tablesorter({
  headers: {0: {sorter: false}, 2: {sorter: 'fancyNumber'}},
  // order by descending number of entities, then name
  sortList: [[2, 1], [1, 0]],
  widgets: ['indexFirstColumn', 'evenRowClasses'],
});
