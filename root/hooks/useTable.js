/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  type Cell,
  type ColumnInstance,
  type ColumnOptionsNoValue,
  type HeaderGroup,
  type Row,
  useTable as useReactTable,
} from 'react-table';

import loopParity from '../utility/loopParity.js';

const renderTableHeaderCell = (column: ColumnInstance) => (
  <th
    {...column.getHeaderProps(column.headerProps)}
  >
    {column.render('Header')}
  </th>
);

const renderTableHeaderRow = (headerGroup: HeaderGroup) => (
  <tr {...headerGroup.getHeaderGroupProps()}>
    {headerGroup.headers.map(renderTableHeaderCell)}
  </tr>
);

const renderTableCell = (cell: Cell<mixed>) => (
  <td {...cell.getCellProps(cell.column.cellProps)}>
    {cell.render('Cell')}
  </td>
);

const renderTableRow = <D>(row: Row<D>, i: number): React$Element<'tr'> => (
  <tr {...row.getRowProps({className: loopParity(i)})}>
    {row.cells.map(renderTableCell)}
  </tr>
);

type Props<D> = {
  className?: string,
  columns: $ReadOnlyArray<ColumnOptionsNoValue<D>>,
  data: $ReadOnlyArray<D>,
};

const useRenderedTable = <D>({
  className: passedClassName,
  columns,
  data,
}: Props<D>): React$Element<'table'> => {
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

  const className =
    'tbl' + (nonEmpty(passedClassName) ? ' ' + passedClassName : '');

  return (
    <table {...getTableProps({className: className})}>
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
};

export default useRenderedTable;
