/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/*
 * Returns false if `object` has any enumerable properties, or true
 * otherwise. (This includes properties in the prototype chain.)
 */
export default function isObjectEmpty(
  object: {__proto__: null, ...} | {...},
): boolean {
  for (const key in object) {
    return false;
  }
  return true;
}
