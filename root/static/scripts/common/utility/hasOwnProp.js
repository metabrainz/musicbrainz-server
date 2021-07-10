/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// $FlowIgnore[method-unbinding]
const objectHasOwnProperty = Object.prototype.hasOwnProperty;

export default function hasOwnProp(
  object: {__proto__: null, ...} | {...},
  prop: string,
): boolean {
  return objectHasOwnProperty.call(object, prop);
}
