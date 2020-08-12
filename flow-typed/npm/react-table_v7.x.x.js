// @flow strict

declare module 'react-table' {
  declare export type CellRenderProps<+D, +V> = {
    +cell: Cell<V>,
    +column: ColumnInstance,
    +row: Row<D>,
  };

  declare type ReactProps = {+[prop: string]: StrOrNum | ReactProps};

  declare type $ColumnOptions<-D, +A, -V> = {
    +accessor?: A,
    +Cell?: (CellRenderProps<D, V>) => React$Node,
    +cellProps?: ReactProps,
    +Header?: React$Node | React$AbstractComponent<mixed, mixed>,
    +headerProps?: ReactProps,
    +id?: string,
  };

  declare export type ColumnOptions<-D, +A: $Keys<D> = empty> =
    $ColumnOptions<D, A, $ElementType<D, A>>;

  declare export type ColumnOptionsFnAccessor<-D, V> =
    $ColumnOptions<D, (D) => V, V>;

  declare export type ColumnInstance = {
    +cellProps?: ReactProps,
    +getCellProps: (props?: {...}) => {...},
    +getHeaderProps: (props?: {...}) => {...},
    // Not actually part of react-table but our own expansion of it
    +headerProps?: ReactProps,
    +render: (type: 'Header' | string, props?: {...}) => React$Node,
  };

  declare export type HeaderGroup = $ReadOnly<{
    ...ColumnInstance,
    +getHeaderGroupProps: (props?: {...}) => {...},
    +headers: $ReadOnlyArray<ColumnInstance>,
  }>;

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
    +columns: $ReadOnlyArray<$ColumnOptions<D, mixed, empty>>,
    +data: $ReadOnlyArray<D>,
  };

  /*
   * D = data, the type of row data used to populate the table.
   */
  declare export function useTable<D>(
    UseTableOptions<D>,
  ): UseTableInstance<D>;
}
