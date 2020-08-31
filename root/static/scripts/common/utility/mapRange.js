/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export default function mapRange<T>(
  start: number,
  end: number,
  func: (number) => T,
): Array<T> {
  const result = [];
  for (let i = start; i <= end; i++) {
    result.push(func(i));
  }
  return result;
}
