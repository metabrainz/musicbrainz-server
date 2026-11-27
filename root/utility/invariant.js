/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import nonEmpty from '../static/scripts/common/utility/nonEmpty.js';

/*
 * If Flow sees the `invariant` function being called, it will behave
 * as if an exception was thrown inline where the passed condition isn't
 * true. The is useful for determining unreachable code and maintaining
 * refinements.
 * See https://flow.org/en/docs/types/assertion-functions/
 */
export default function invariant(
  cond: unknown,
  msg?: string = 'Invariant Violation',
): asserts cond {
  // flowlint sketchy-null-mixed:off
  if (!cond) {
    throw new Error(msg);
  }
}

export function expect<T>(value: ?T, description?: string): T {
  invariant(
    value != null,
    'Expected a non-null value' +
      (nonEmpty(description) ? ' ({description})' : ''),
  );
  return value;
}
