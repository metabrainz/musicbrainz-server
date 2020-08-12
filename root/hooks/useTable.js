/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import {
  useTable as useReactTable,
  type UseTableOptions,
  type Row,
} from 'react-table';

import loopParity from '../utility/loopParity';

const renderTableHeaderCell = (column) => (
  <th
    {...column.getHeaderProps(column.headerProps)}
  >
    {column.render('Header')}
  </th>
);

const renderTableHeaderRow = (headerGroup) => (
  <tr {...headerGroup.getHeaderGroupProps()}>
    {headerGroup.headers.map(renderTableHeaderCell)}
  </tr>
);

const renderTableCell = (cell) => (
  <td {...cell.getCellProps(cell.column.cellProps)}>
    {cell.render('Cell')}
  </td>
);

const renderTableRow = (row, i) => (
  <tr {...row.getRowProps({className: loopParity(i)})}>
    {row.cells.map(renderTableCell)}
  </tr>
);

type Props<D> = {
  className?: string,
  ...UseTableOptions<D>,
};

export default function useTable<D>({
  className,
  columns,
  data,
}: Props<D>): React.Element<'table'> {
  const {
    getTableProps,
    getTableBodyProps,
    headerGroups,
    rows,
    prepareRow,
  } = useReactTable<D>({
    columns,
    data,
  });

  className = 'tbl' + (className ? ' ' + className : '');

  return (
    <table {...getTableProps({className: className})}>
      <thead>
        {headerGroups.map(renderTableHeaderRow)}
      </thead>
      <tbody {...getTableBodyProps()}>
        {rows.map((row: Row<D>, i: number) => {
          prepareRow(row);
          return renderTableRow(row, i);
        })}
      </tbody>
    </table>
  );
}
