/*
 * @flow strict
 * Copyright (C) 2005 Stefan Kestenholz (keschte)
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import clean from '../../common/utility/clean.js';

// Trim leading, trailing and running-line whitespace from the given string.
export default function trim(word: string): string {
  const cleanedWord = clean(word);
  return cleanedWord.replace(/([([])\s+/, '$1').replace(/\s+([)\]])/, '$1');
}
