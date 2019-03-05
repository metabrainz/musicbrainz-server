/*
 * @flow
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

export default function createField<
  S,
  P: ReadOnlyCompoundFieldT<S> | ReadOnlyRepeatableFieldT<S>,
  N: number | string,
>(
  parent: P,
  name: N,
  value: mixed,
): $ElementType<P, N> {
  const field: any = {
    errors: [],
    has_errors: false,
    html_name: parent.html_name + '.' + String(name),
    id: ++LAST_FIELD_ID,
  };
  if (value && typeof value === 'object') {
    if (Array.isArray(value)) {
      field.field = value.map(
        (x, i) => createField(field, i, x),
      );
    } else {
      const fields = {};
      for (const key in value) {
        fields[key] = createField(field, key, value[key]);
      }
      field.field = fields;
    }
  } else {
    field.value = value;
  }
  return field;
}
