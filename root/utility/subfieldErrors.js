/*
 * @flow
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import each from 'lodash/each';

const hasOwnProperty = Object.prototype.hasOwnProperty;

export default function subfieldErrors<F>(
  field: AnyFieldT<F>,
  accum: $ReadOnlyArray<string> = [],
) {
  if (field.errors.length) {
    accum = accum.concat(field.errors);
  }
  if (hasOwnProperty.call(field, 'field')) {
    // $FlowFixMe
    each(field.field, function (subfield) {
      accum = subfieldErrors(subfield, accum);
    });
  }
  return accum;
}
