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

const renderTableHeaderCell = (column: ColumnInstance) => {
  const {key, ...headerProps} = column.getHeaderProps(column.headerProps);
  return (
    <th {...headerProps} key={key}>
      {column.render('Header')}
    </th>
  );
};

const renderTableHeaderRow = (headerGroup: HeaderGroup) => {
  const {key, ...headerGroupProps} = headerGroup.getHeaderGroupProps();
  return (
    <tr {...headerGroupProps} key={key}>
      {headerGroup.headers.map(renderTableHeaderCell)}
    </tr>
  );
};

const renderTableCell = (cell: Cell<mixed>) => {
  const {key, ...cellProps} = cell.getCellProps(cell.column.cellProps);
  return (
    <td {...cellProps} key={key}>
      {cell.render('Cell')}
    </td>
  );
};

const renderTableRow = <D>(row: Row<D>, i: number): React.MixedElement => {
  const {key, ...rowProps} = row.getRowProps({className: loopParity(i)});
  return (
    <tr {...rowProps} key={key}>
      {row.cells.map(renderTableCell)}
    </tr>
  );
};

type Props<D> = {
  className?: string,
  columns: $ReadOnlyArray<ColumnOptionsNoValue<D>>,
  data: $ReadOnlyArray<D>,
};

const useRenderedTable = <D>({
  className: passedClassName,
  columns,
  data,
}: Props<D>): React.MixedElement => {
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
    <table {...getTableProps({className})}>
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
