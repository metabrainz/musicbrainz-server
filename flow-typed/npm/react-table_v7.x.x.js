// @flow strict

declare module 'react-table' {
  declare export type CellRenderProps<D, +V> = {
    +cell: Cell<V>,
    +column: ColumnInstance,
    +row: Row<D>,
  };

  declare export type ColumnOptions<D, V> = {
    +accessor?: $Keys<D> | ((D) => V),
    +Cell?: React$AbstractComponent<CellRenderProps<D, V>, mixed>,
    +Header?: Renderer<HeaderProps<D>>,
    +id?: string,
    ...
  };

  declare export type ColumnInstance = {
    +cellProps?: {[attribute: string]: string},
    +getCellProps: (props?: {...}) => {...},
    +getHeaderProps: (props?: {...}) => {...},
    // Not actually part of react-table but our own expansion of it
    +headerProps?: {[attribute: string]: string},
    +render: (type: 'Header' | string, props?: {...}) => React$Node,
  };

  declare export type HeaderGroup = {
    ...$ReadOnly<ColumnInstance>,
    +getHeaderGroupProps: (props?: {...}) => {...},
    +headers: $ReadOnlyArray<ColumnInstance>,
  };

  declare export type Cell<+V> = {
    +column: ColumnInstance,
    +getCellProps: (props?: {...}) => {...},
    +render: (type: 'Cell' | string, userProps?: {...}) => React$Node,
    +value: V,
  };

  declare export type Row<+D> = {
    +cells: $ReadOnlyArray<Cell<mixed>>,
    +getRowProps: (props?: {...}) => {...},
    +index: number,
    +original: D,
  };

  declare export type UseTableInstance<D> = {
    +getTableBodyProps: (props?: {...}) => {...},
    +getTableProps: (props?: {...}) => {...},
    +headerGroups: $ReadOnlyArray<HeaderGroup>,
    +prepareRow: (row: Row<D>) => void,
    +rows: $ReadOnlyArray<Row<D>>,
  };

  declare type GetColumnOptions<D> = <V>(V) => ColumnOptions<D, V>;

  declare export type UseTableOptions<CV, D> = {
    +columns: $TupleMap<CV, GetColumnOptions<D>>,
    +data: $ReadOnlyArray<D>,
  };

  /*
   * CV = cell values, an array/tuple of the value types of each column cell.
   * D = data, the type of row data used to populate the table.
   */
  declare export function useTable<CV, D>(
    UseTableOptions<CV, D>,
  ): UseTableInstance<D>;
}
