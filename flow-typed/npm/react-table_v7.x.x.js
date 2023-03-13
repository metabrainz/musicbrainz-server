// @flow strict

declare module 'react-table' {
  declare export type CellRenderProps<+D, +V> = {
    +cell: Cell<V>,
    +column: ColumnInstance,
    +row: Row<D>,
  };

  declare export type HeaderProps<D> = $ReadOnly<{
    ...UseTableInstance<D>,
    +column: ColumnInstance,
  }>;

  declare export type ColumnOptions<-D, V> = {
    /*
     * react-table also allows `accessor` to be a string, but we
     * intentionally require an accessor function. For one, it's more type-
     * safe: a type like `$Keys<D>` has no relation to `V`, so there's no
     * way to ensure that the given key provides `V`. The other reason is
     * that `D` is invariant in `$Keys<D>`, so we wouldn't be able to make
     * `D` contravariant above.
     */
    +accessor?: (D) => V,
    +Cell?: React$AbstractComponent<CellRenderProps<D, V>, mixed>,
    +Header?: React$ComponentType<mixed> | React$Node,
    +id?: string,
    ...
  };

  declare export type ColumnOptionsNoValue<-D> = {
    +accessor?: (D) => mixed,
    +Cell?: React$AbstractComponent<CellRenderProps<D, empty>, mixed>,
    +Header?: React$ComponentType<mixed> | React$Node,
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

  declare export type UseTableOptions<D> = {
    +columns: $ReadOnlyArray<ColumnOptionsNoValue<D>>,
    +data: $ReadOnlyArray<D>,
  };

  /*
   * D = data, the type of row data used to populate the table.
   */
  declare export function useTable<D>(
    UseTableOptions<D>,
  ): UseTableInstance<D>;
}
