/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {CowContext} from 'mutate-cow';

function* iterSubfields(
  formOrField: FormOrAnyFieldT,
): Generator<AnyFieldT, void, void> {
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
    case 'repeatable_field': {
      yield formOrField;
      for (const subfield of formOrField.field) {
        yield* iterSubfields(subfield);
      }
      break;
    }
  }
}

function* iterContextSubfields(
  formOrFieldCtx: CowContext<FormOrAnyFieldT>,
): Generator<CowContext<AnyFieldT>, void, void> {
  const formOrField = formOrFieldCtx.read();
  switch (formOrField.type) {
    case 'compound_field':
      // $FlowIgnore[incompatible-type-arg]
      yield formOrFieldCtx;
      // falls through
    case 'form':
      for (const fieldName of Object.keys(formOrField.field)) {
        // $FlowIgnore[incompatible-call]
        yield* iterContextSubfields(formOrFieldCtx.get('field', fieldName));
      }
      break;
    case 'field':
      // $FlowIgnore[incompatible-type-arg]
      yield formOrFieldCtx;
      break;
    case 'repeatable_field': {
      // $FlowIgnore[incompatible-type-arg]
      yield formOrFieldCtx;
      for (let i = 0; i < formOrField.field.length; i++) {
        // $FlowIgnore[incompatible-call]
        yield* iterContextSubfields(formOrFieldCtx.get('field', i));
      }
      break;
    }
  }
}

export function applyAllPendingErrors(
  formOrFieldCtx: CowContext<FormOrAnyFieldT>,
): void {
  const subfields = iterContextSubfields(formOrFieldCtx);
  for (const subfieldCtx of subfields) {
    if (subfieldCtx.read().pendingErrors?.length) {
      applyPendingErrors(subfieldCtx);
    }
  }
}

export function applyPendingErrors(
  fieldCtx: CowContext<AnyFieldT>,
): void {
  fieldCtx.set('errors', fieldCtx.read().pendingErrors ?? []);
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
