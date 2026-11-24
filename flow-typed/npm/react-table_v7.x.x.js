// @flow strict

declare module 'react-table' {
  declare export type CellRenderProps<out D, out V> = {
    readonly cell: Cell<V>,
    readonly column: ColumnInstance,
    readonly row: Row<D>,
  };

  declare export type HeaderProps<D> = Readonly<{
    ...UseTableInstance<D>,
    readonly column: ColumnInstance,
  }>;

  declare export type ColumnOptions<in D, V> = {
    /*
     * react-table also allows `accessor` to be a string, but we
     * intentionally require an accessor function. For one, it's more type-
     * safe: a type like `keyof D` has no relation to `V`, so there's no
     * way to ensure that the given key provides `V`. The other reason is
     * that `D` is invariant in `keyof D`, so we wouldn't be able to make
     * `D` contravariant above.
     */
    readonly accessor?: (D) => V,
    readonly Cell?: component(...CellRenderProps<D, V>),
    readonly Header?: component() | React.Node,
    readonly id?: string,
    ...
  };

  declare export type ColumnOptionsNoValue<in D> = {
    readonly accessor?: (D) => unknown,
    readonly Cell?: component(...CellRenderProps<D, empty>),
    readonly Header?: component() | React.Node,
    readonly id?: string,
    ...
  };

  type ThElementProps =
    Partial<Readonly<{...ReactDOM$thProps, key?: string}>>;

  type TrElementProps =
    Partial<Readonly<{...ReactDOM$trProps, key?: string}>>;

  type TdElementProps =
    Partial<Readonly<{...ReactDOM$tdProps, key?: string}>>;

  type TableElementProps =
    Partial<Readonly<{...ReactDOM$tableProps, key?: string}>>;

  type TbodyElementProps =
    Partial<Readonly<{...ReactDOM$tbodyProps, key?: string}>>;

  declare export type ColumnInstance = {
    readonly cellProps?: TdElementProps,
    readonly getCellProps: (props?: TdElementProps) => TdElementProps,
    readonly getHeaderProps: (props?: ThElementProps) => ThElementProps,
    // Not actually part of react-table but our own expansion of it
    readonly headerProps?: ThElementProps,
    readonly render: (type: 'Header' | string, props?: {...}) => React.Node,
  };

  declare export type HeaderGroup = Readonly<{
    ...Readonly<ColumnInstance>,
    readonly getHeaderGroupProps: (props?: TrElementProps) => TrElementProps,
    readonly headers: ReadonlyArray<ColumnInstance>,
  }>;

  declare export type Cell<out V> = {
    readonly column: ColumnInstance,
    readonly getCellProps: (props?: TdElementProps) => TdElementProps,
    readonly render: (type: 'Cell' | string, userProps?: {...}) => React.Node,
    readonly value: V,
  };

  declare export type Row<out D> = {
    readonly cells: ReadonlyArray<Cell<unknown>>,
    readonly getRowProps: (props?: TrElementProps) => TrElementProps,
    readonly index: number,
    readonly original: D,
  };

  declare export type UseTableInstance<D> = {
    readonly getTableBodyProps:
      (props?: TbodyElementProps) => TbodyElementProps,
    readonly getTableProps: (props?: TableElementProps) => TableElementProps,
    readonly headerGroups: ReadonlyArray<HeaderGroup>,
    readonly prepareRow: (row: Row<D>) => void,
    readonly rows: ReadonlyArray<Row<D>>,
  };

  declare export type UseTableOptions<D> = {
    readonly columns: ReadonlyArray<ColumnOptionsNoValue<D>>,
    readonly data: ReadonlyArray<D>,
  };

  /*
   * D = data, the type of row data used to populate the table.
   */
  declare export function useTable<D>(
    UseTableOptions<D>,
  ): UseTableInstance<D>;
}
