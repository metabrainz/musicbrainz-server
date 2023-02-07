/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export default function* natatime<T>(
  n: number,
  values: Iterable<T>,
): Generator<Array<T>, void, void> {
  invariant(n > 0);
  let chunk: Array<T> = [];
  for (const value of values) {
    chunk.push(value);
    if (chunk.length === n) {
      yield chunk;
      chunk = [];
    }
  }
  if (chunk.length) {
    yield chunk;
  }
}
