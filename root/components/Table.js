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

const renderTableHeaderCell = (column) => (
  <th {...column.getHeaderProps({className: column.className})}>
    {column.render('Header')}
  </th>
);

const renderTableHeaderRow = (headerGroup) => (
  <tr {...headerGroup.getHeaderGroupProps()}>
    {headerGroup.headers.map(renderTableHeaderCell)}
  </tr>
);

const renderTableCell = (cell) => (
  <td {...cell.getCellProps({className: cell.column.className})}>
    {cell.render('Cell')}
  </td>
);

const renderTableRow = (row, i) => (
  <tr {...row.getRowProps({className: loopParity(i)})}>
    {row.cells.map(renderTableCell)}
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
        {headerGroups.map(renderTableHeaderRow)}
      </thead>
      <tbody {...getTableBodyProps()}>
        {rows.map((row, i) => {
          prepareRow(row);
          return renderTableRow(row, i);
        })}
      </tbody>
    </table>
  );
});

export default Table;
