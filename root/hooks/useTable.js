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

type GetRowPropsFn<D> = (Row<D>) => {
  [attribute: string]: StrOrNum | null,
  ...
};

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

const renderTableRow = <D>(
  row: Row<D>,
  i: number,
  getRowProps: ?GetRowPropsFn<D>,
) => {
  const props = {
    ...(getRowProps ? getRowProps(row) : null),
    className: loopParity(i),
  };
  return (
    <tr {...row.getRowProps(props)}>
      {row.cells.map(renderTableCell)}
    </tr>
  );
};

type Props<D> = {
  className?: string,
  getRowProps?: GetRowPropsFn<D>,
  ...UseTableOptions<D>,
};

export default function useTable<D>({
  className,
  columns,
  data,
  getRowProps,
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
          return renderTableRow<D>(row, i, getRowProps);
        })}
      </tbody>
    </table>
  );
}
