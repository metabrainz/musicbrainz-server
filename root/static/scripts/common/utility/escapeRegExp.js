/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// From https://developer.mozilla.org/en/docs/Web/JavaScript/Guide/Regular_Expressions
const regExpChars = /([.*+?^=!:${}()|\[\]\/\\])/g;

export default function escapeRegExp(string: string): string {
  return string.replace(regExpChars, '\\$1');
}
