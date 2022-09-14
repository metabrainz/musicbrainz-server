/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  type FormOrAnyFieldT,
  type WritableAnyFieldT,
  type WritableFormOrAnyFieldT,
  iterSubfields,
  iterWritableSubfields,
} from './iterSubfields.js';

export function applyAllPendingErrors(
  formOrField: WritableFormOrAnyFieldT,
): void {
  const subfields = iterWritableSubfields(formOrField);
  for (const subfield of subfields) {
    if (subfield.pendingErrors?.length) {
      applyPendingErrors(subfield);
    }
  }
}

export function applyPendingErrors(
  field: WritableAnyFieldT,
): void {
  field.errors = field.pendingErrors ?? [];
}

export function hasSubfieldErrors(formOrField: FormOrAnyFieldT): boolean {
  for (const subfield of iterSubfields(formOrField)) {
    if (subfield.errors?.length || subfield.pendingErrors?.length) {
      return true;
    }
  }
  return false;
}

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
