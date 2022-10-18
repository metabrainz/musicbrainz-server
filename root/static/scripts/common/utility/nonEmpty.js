/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// If you modify these, please do the same in root/vars.js
export function empty(value: mixed): boolean %checks {
  return !nonEmpty(value);
}

export default function nonEmpty(value: mixed): boolean %checks {
  return value !== null && value !== undefined && value !== '';
}
