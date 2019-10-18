/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import {useTable} from 'react-table';

import loopParity from '../utility/loopParity';

const TableHeaderCell = (column) => (
  <th {...column.getHeaderProps({className: column.className})}>
    {column.render('Header')}
  </th>
);

const TableHeaderRow = (headerGroup) => (
  <tr {...headerGroup.getHeaderGroupProps()}>
    {headerGroup.headers.map(TableHeaderCell)}
  </tr>
);

const TableCell = (cell) => (
  <td {...cell.getCellProps({className: cell.column.className})}>
    {cell.render('Cell')}
  </td>
);

const TableRow = (row, i) => (
  <tr {...row.getRowProps({className: loopParity(i)})}>
    {row.cells.map(TableCell)}
  </tr>
);

const Table = (({columns, data}: any) => {
  const {
    getTableProps,
    getTableBodyProps,
    headerGroups,
    rows,
    prepareRow,
  } = useTable({
    columns,
    data,
  });

  return (
    <table {...getTableProps({className: 'tbl'})}>
      <thead>
        {headerGroups.map(TableHeaderRow)}
      </thead>
      <tbody {...getTableBodyProps()}>
        {rows.map((row, i) => {
          prepareRow(row);
          return TableRow(row, i);
        })}
      </tbody>
    </table>
  );
});

export default Table;
