declare module 'react-table' {
  declare export type CellRenderProps<D, +V> = {
    +column: ColumnInstance,
    +row: Row<D>,
    +cell: Cell<V>,
  };

  declare export type ColumnOptions<D, V> = {
    +accessor?: $Keys<D>,
    +id?: string,
    +Header?: Renderer<HeaderProps<D>>,
    +Cell?: React$AbstractComponent<CellRenderProps<D, V>, mixed>,
    ...,
  };

  declare export type ColumnInstance = {
    +className?: string,
    +getHeaderProps: (props?: {...}) => {...},
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
