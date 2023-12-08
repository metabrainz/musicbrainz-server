/*
 * @flow strict
 * Copyright (C) 2015-2016 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

function _commaList<Input, Output>(
  l: ExpandLFunc<Input, Output>,
  items: $ReadOnlyArray<Input>,
): Output | string {
  const count = items.length;

  if (!count) {
    return '';
  }

  if (count === 1) {
    return l('{last_list_item}', {last_list_item: items[0]});
  }

  // The __wantArray argument is only used with exp.l, not texp.l.

  let output = l('{almost_last_list_item} and {last_list_item}', {
    __wantArray: 'true',
    almost_last_list_item: items[count - 2],
    last_list_item: items[count - 1],
  });

  for (let i = count - 3; i >= 0; i--) {
    output = l('{list_item}, {rest}', {
      __wantArray: 'true',
      list_item: items[i],
      rest: output,
    });
  }

  return output;
}

const commaList = (
  items: $ReadOnlyArray<VarSubstArg>,
): Expand2ReactOutput | string => {
  const result =
  _commaList<VarSubstArg, Expand2ReactOutput>(exp.l, items);
  if (Array.isArray(result)) {
    return React.createElement(React.Fragment, null, ...result);
  }
  return result;
};

const commaListText = (items: $ReadOnlyArray<StrOrNum>): string => (
  _commaList<StrOrNum, string>(texp.l, items)
);

export default commaList;

export {commaListText};
