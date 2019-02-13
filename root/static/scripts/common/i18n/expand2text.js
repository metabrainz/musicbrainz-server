/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import expand from './expand2';

/*
 * TODO: This isn't implemented yet.
 *
 * Like expand2react, but can only interpolate and produce plain text
 * values. To be more specific: HTML isn't parsed, link interpolation
 * syntax isn't supported, and only strings and numbers can be used
 * as var args. The result is always a string.
 *
 * This is useful in cases where strings are /required/, such as HTML
 * title or aria attributes and select option values. It can also be
 * used where plain text is expected (if not required), simply for the
 * stricter types.
 */
export default function expand2text(
  source: string,
  args?: ?{+[string]: StrOrNum},
) {
  const result = expand(source, args);
  return result[0] || '';
}
