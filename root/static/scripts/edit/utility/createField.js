/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/*
 * The Perl will assign a unique ID to all existing fields in
 * MusicBrainz::Server::Form::Role::ToJSON. The initial value of
 * `LAST_FIELD_ID` here is high enough that it should never overlap
 * with an ID assigned on the server.
 */
let LAST_FIELD_ID = 99999;

export type MapFields<F> = $ObjMap<F, <T>(T) => FieldT<T>>;

export function createCompoundField<F: {[fieldValueKey: string]: mixed, ...}>(
  name: string,
  fieldValues: F,
): CompoundFieldT<MapFields<F>> {
  const field: MapFields<F> = {};
  for (const key in fieldValues) {
    field[key] = createField(name + '.' + key, fieldValues[key]);
  }
  return {
    errors: [],
    field,
    has_errors: false,
    html_name: name,
    id: ++LAST_FIELD_ID,
    type: 'compound_field',
  };
}

export function createField<T>(
  name: string,
  value: T,
): FieldT<T> {
  return {
    errors: [],
    has_errors: false,
    html_name: name,
    id: ++LAST_FIELD_ID,
    type: 'field',
    value,
  };
}
