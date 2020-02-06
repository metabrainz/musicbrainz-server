/*
 * @flow strict
 * Copyright (C) 2015-2016 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

function _semicolonOnlyList<Input, Output>(
  l: ExpandLFunc<Input, Output>,
  items: $ReadOnlyArray<Input>,
): Output | string {
  const length = items.length;

  if (!length) {
    return '';
  }

  let output = l('{last_list_item}', {
    last_list_item: items[length - 1],
  });

  for (let i = length - 2; i >= 0; i--) {
    output = l('{semicolon_only_list_item}; {rest}', {
      rest: output,
      semicolon_only_list_item: items[i],
    });
  }

  return output;
}

export default function semicolonOnlyList(
  items: $ReadOnlyArray<VarSubstArg>,
) {
  return _semicolonOnlyList<VarSubstArg, Expand2ReactOutput>(exp.l, items);
}

export function semicolonOnlyListText(items: $ReadOnlyArray<StrOrNum>) {
  return _semicolonOnlyList<StrOrNum, string>(texp.l, items);
}
