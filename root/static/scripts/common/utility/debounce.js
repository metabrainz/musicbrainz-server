/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export default function debounce<T: [...]>(
  func: (...T) => void,
  ms: number = 100,
): (...T) => void {
  let timeoutId: TimeoutID | null = null;
  return (...args: T) => {
    if (timeoutId) {
      clearTimeout(timeoutId);
    }
    timeoutId = setTimeout(() => {
      timeoutId = null;
      func(...args);
    }, ms);
  };
}
