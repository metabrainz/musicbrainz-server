/*
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

function* _iterSubfields(formOrField) {
  switch (formOrField.type) {
    case 'compound_field':
      yield formOrField;
      // falls through
    case 'form':
      for (const subfield of Object.values(formOrField.field)) {
        yield* iterSubfields(subfield);
      }
      break;
    case 'field':
      yield formOrField;
      break;
    case 'repeatable_field':
      yield formOrField;
      for (const subfield of formOrField.field) {
        yield* iterSubfields(subfield);
      }
      break;
  }
}

export const iterSubfields = _iterSubfields;
export const iterWritableSubfields = _iterSubfields;
