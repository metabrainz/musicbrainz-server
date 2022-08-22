/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  useTable,
  type Cell,
  type ColumnInstance,
  type HeaderGroup,
  type Row,
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

const renderTableRow = <D>(row: Row<D>, i: number) => (
  <tr {...row.getRowProps({className: loopParity(i)})}>
    {row.cells.map(renderTableCell)}
  </tr>
);

type Props<CV, D> = {
  className?: string,
  columns: CV,
  data: $ReadOnlyArray<D>,
};

const Table = <CV, D>({
  className,
  columns,
  data,
}: Props<CV, D>): React$MixedElement => {
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

  className = 'tbl' + (className ? ' ' + className : '');

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

export default Table;
