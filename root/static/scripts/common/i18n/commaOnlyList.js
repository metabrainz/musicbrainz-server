/*
 * @flow strict
 * Copyright (C) 2015-2016 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

function _commaOnlyList<Input, Output>(
  l: ExpandLFunc<Input, Output>,
  items: $ReadOnlyArray<Input>,
): Output | string {
  const length = items.length;

  if (!length) {
    return '';
  }

  // The __wantArray argument is only used with exp.l, not texp.l.

  let output = l('{last_list_item}', {
    __wantArray: 'true',
    last_list_item: items[length - 1],
  });

  for (let i = length - 2; i >= 0; i--) {
    output = l('{commas_only_list_item}, {rest}', {
      __wantArray: 'true',
      commas_only_list_item: items[i],
      rest: output,
    });
  }

  return output;
}

const commaOnlyList = (
  items: $ReadOnlyArray<VarSubstArg>,
): Expand2ReactOutput | string => {
  const result =
    _commaOnlyList<VarSubstArg, Expand2ReactOutput>(exp.l, items);
  if (Array.isArray(result)) {
    return React.createElement(React.Fragment, null, ...result);
  }
  return result;
};

const commaOnlyListText = (items: $ReadOnlyArray<StrOrNum>): string => (
  _commaOnlyList<StrOrNum, string>(texp.l, items)
);

export default commaOnlyList;

export {commaOnlyListText};
