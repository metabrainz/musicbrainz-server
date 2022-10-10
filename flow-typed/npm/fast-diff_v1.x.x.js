/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

declare module 'fast-diff' {
  /*
   * fast-diff constants:
   * INSERT = 1
   * EQUAL = 0
   * DELETE = -1
   */
  declare type FastEditDiff = [-1 | 0 | 1, string];

  declare function diff<T>(
      a: string,
      b: string,
  ): Array<FastEditDiff>;

  declare module.exports: typeof diff & {+DELETE: -1, +EQUAL: 0, +INSERT: 1};
}
