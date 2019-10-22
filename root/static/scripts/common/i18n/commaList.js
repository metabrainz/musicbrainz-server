/*
 * @flow
 * Copyright (C) 2015-2016 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

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

  let output = l('{almost_last_list_item} and {last_list_item}', {
    almost_last_list_item: items[count - 2],
    last_list_item: items[count - 1],
  });

  for (let i = count - 3; i >= 0; i--) {
    output = l('{list_item}, {rest}', {
      list_item: items[i],
      rest: output,
    });
  }

  return output;
}

const commaList = (items: $ReadOnlyArray<VarSubstArg>) => (
  _commaList<VarSubstArg, Expand2ReactOutput>(exp.l, items)
);

const commaListText = (items: $ReadOnlyArray<StrOrNum>) => (
  _commaList<StrOrNum, string>(texp.l, items)
);

export default commaList;

export {commaListText};
