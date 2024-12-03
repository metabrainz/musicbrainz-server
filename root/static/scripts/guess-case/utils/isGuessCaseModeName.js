/*
 * @flow strict
 * Copyright (C) 2005 Stefan Kestenholz (keschte)
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {GuessCaseModeNameT} from '../types.js';

export default function isGuessCaseModeName(
  modeName: string,
): modeName is GuessCaseModeNameT {
  return (
    modeName === 'English' ||
    modeName === 'French' ||
    modeName === 'Sentence' ||
    modeName === 'Turkish'
  );
}
