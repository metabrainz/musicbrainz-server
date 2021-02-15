/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable flowtype/sort-keys */

declare module 'pg-cursor' {
  import type {Connection, PgResultSet, Submittable} from 'pg';

  declare type CursorQueryConfig = {
    +rowMode?: 'array',
  };

  declare class Cursor<+R> implements Submittable {
    constructor(
      text: string,
      values: $ReadOnlyArray<mixed>,
      config?: CursorQueryConfig,
    ): void,
    read(
      rowCount: number,
      callback: (Error, Array<R>, PgResultSet<R>) => void,
    ): void,
    submit: (Connection) => void,
    close((Error) => void): void,
    // shim for pg.Result class
    _result: {
      parseRow: ($ReadOnlyArray<string>) => R | null,
    },
  }

  declare module.exports: typeof Cursor;
}
