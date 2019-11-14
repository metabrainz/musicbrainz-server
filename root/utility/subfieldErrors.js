/*
 * @flow
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import each from 'lodash/each';

export type FieldShape = {
  // `errors` is optional too because FormT has none
  +errors?: $ReadOnlyArray<string>,
  +field?: FieldShape,
  ...,
};

export default function subfieldErrors(
  field: FieldShape,
  accum: $ReadOnlyArray<string> = [],
) {
  if (field.errors && field.errors.length) {
    accum = accum.concat(field.errors);
  }
  if (field.field) {
    each(field.field, function (subfield) {
      accum = subfieldErrors(subfield, accum);
    });
  }
  return accum;
}
