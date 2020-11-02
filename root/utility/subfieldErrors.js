/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  iterSubfields,
  type FormOrAnyFieldT,
} from './iterSubfields';

export default function subfieldErrors(
  formOrField: FormOrAnyFieldT,
  accum: $ReadOnlyArray<string> = [],
): $ReadOnlyArray<string> {
  let result = accum;
  for (const subfield of iterSubfields(formOrField)) {
    if (subfield.errors?.length) {
      result = result.concat(subfield.errors);
    }
  }
  return result;
}
