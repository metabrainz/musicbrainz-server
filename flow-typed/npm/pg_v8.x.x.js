/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable flowtype/sort-keys */

declare module 'pg' {
  declare export type ClientConfig = {
    +user?: string,
    +database?: string,
    +password?: string,
    +port?: number,
    +host?: string,
  };

  declare export type QueryConfig<+V = mixed> = {
    +name?: string,
    +text: string,
    +values?: $ReadOnlyArray<mixed>,
  };

  declare export type PgResultSet<Row> = {
    +rowCount: number,
    +rows: Array<Row>,
  };

  declare interface Submittable {
    submit: (Connection) => void,
  }

  declare class Client {
    constructor(config?: string | ClientConfig): void,
    connect(): Promise<empty>,
    end(): Promise<empty>,
    escapeIdentifier(string): string,
    escapeLiteral(string): string,
    query<R, +V = mixed>(
      config: string | QueryConfig<V>,
      values?: $ReadOnlyArray<V>,
    ): Promise<PgResultSet<R>>,
    query<R, +V = mixed>(
      config: string | QueryConfig<V>,
      values: ?$ReadOnlyArray<V>,
      callback: (?Error, ?PgResultSet<R>) => void,
    ): void,
    query<R, +V = mixed>(
      config: string | QueryConfig<V>,
      callback: (?Error, ?PgResultSet<R>) => void,
    ): void,
    query<Q: Submittable, +V = mixed>(
      config: Q,
      values?: $ReadOnlyArray<V>,
    ): Q,
  }

  declare class Connection {}

  declare class Query<R, +V = mixed> implements Submittable {
    constructor(
      config: string | QueryConfig<V>,
      values?: $ReadOnlyArray<V>,
      callback?: (?Error, ?PgResultSet<R>) => void,
    ): void,
    submit: (Connection) => void,
    // shim for pg.Result class
    _result: {
      parseRow: ($ReadOnlyArray<string>) => R | null,
    },
  }

  declare module.exports: {
    Client: typeof Client,
    Connection: typeof Connection,
    Query: typeof Query,
  };
}
