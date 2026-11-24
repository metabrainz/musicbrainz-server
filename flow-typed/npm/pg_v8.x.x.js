/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable ft-flow/sort-keys */

declare module 'pg' {
  declare export type ClientConfig = {
    readonly user?: string,
    readonly database?: string,
    readonly password?: string,
    readonly port?: number,
    readonly host?: string,
  };

  declare export type QueryConfig<out V = unknown> = {
    readonly name?: string,
    readonly text: string,
    readonly values?: ReadonlyArray<unknown>,
  };

  declare export type PgResultSet<Row> = {
    readonly rowCount: number,
    readonly rows: Array<Row>,
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
    query<R, V = unknown>(
      config: string | QueryConfig<V>,
      values?: ReadonlyArray<V>,
    ): Promise<PgResultSet<R>>,
    query<R, V = unknown>(
      config: string | QueryConfig<V>,
      values: ?ReadonlyArray<V>,
      callback: (?Error, ?PgResultSet<R>) => void,
    ): void,
    query<R, V = unknown>(
      config: string | QueryConfig<V>,
      callback: (?Error, ?PgResultSet<R>) => void,
    ): void,
    query<Q extends Submittable, V = unknown>(
      config: Q,
      values?: ReadonlyArray<V>,
    ): Q,
  }

  declare class Connection {}

  declare class Query<R, out V = unknown> implements Submittable {
    constructor(
      config: string | QueryConfig<V>,
      values?: ReadonlyArray<V>,
      callback?: (?Error, ?PgResultSet<R>) => void,
    ): void,
    submit: (Connection) => void,
    // shim for pg.Result class
    _result: {
      parseRow: (ReadonlyArray<string>) => R | null,
    },
  }

  declare module.exports: {
    Client: typeof Client,
    Connection: typeof Connection,
    Query: typeof Query,
  };
}
