/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import expand2react from '../i18n/expand2react.js';
import expand2text from '../i18n/expand2text.js';

type Args = {+type: '()' | '[]'};

function _bracketed(args?: Args) {
  const type = args ? args.type : undefined;
  switch (type) {
    case '[]':
      return l('[{text}]');
    case '()':
    default:
      return l('({text})');
  }
}

export default function bracketed(
  text: ?VarSubstArg,
  args?: Args,
): Expand2ReactOutput {
  if (nonEmpty(text)) {
    return expand2react(_bracketed(args), {text});
  }
  return '';
}

export function bracketedText(text: ?StrOrNum, args?: Args): string {
  if (nonEmpty(text)) {
    return expand2text(_bracketed(args), {text});
  }
  return '';
}
