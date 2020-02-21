/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export default function setMapDefault<K, V>(
  map: Map<K, V>,
  key: K,
  default_: () => V,
): V {
  let value = map.get(key);
  if (value !== undefined) {
    return value;
  }
  value = default_();
  map.set(key, value);
  return value;
}
