/*
 * @flow
 * Copyright (C) 2018 Shamroy Pellew
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import tablesorter from 'tablesorter';

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
        $(this).removeClass('odd');
      } else {
        $(this).addClass('odd');
        $(this).removeClass('even');
      }
    });
  },
  id: 'loopParity',
});

tablesorter.addParser({
  format: function (s) {
    return tablesorter.formatFloat(s.replace(/,|\.|\s/g, ''));
  },
  id: 'fancyNumber',
  is: function (s) {
    return /^[0-9]?[0-9,.]*$/.test(s);
  },
  type: 'numeric',
});

$('#countries-table').tablesorter({
  headers: {
    [0]: {sorter: false},
    [2]: {sorter: 'fancyNumber'},
    [3]: {sorter: 'fancyNumber'},
    [4]: {sorter: 'fancyNumber'},
    [5]: {sorter: 'fancyNumber'},
  },
  // order by descending number of entities, then name
  sortList: [[5, 1], [1, 0]],
  widgets: ['indexFirstColumn', 'loopParity'],
});

$('#languages-table').tablesorter({
  headers: {
    [0]: {sorter: false},
    [2]: {sorter: 'fancyNumber'},
    [3]: {sorter: 'fancyNumber'},
    [4]: {sorter: 'fancyNumber'},
  },
  // order by descending number of entities, then name
  sortList: [[4, 1], [1, 0]],
  widgets: ['indexFirstColumn', 'loopParity'],
});

$('#scripts-table').tablesorter({
  headers: {[0]: {sorter: false}, [2]: {sorter: 'fancyNumber'}},
  // order by descending number of entities, then name
  sortList: [[2, 1], [1, 0]],
  widgets: ['indexFirstColumn', 'loopParity'],
});
