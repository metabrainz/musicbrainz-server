/*
 * @flow
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export default function createField<
  F,
  S,
  P: StructFieldT<S>,
  N: number | string,
>(
  form: FormT<F>,
  parent: P,
  name: N,
  value: mixed,
): $ElementType<P, N> {
  const field: any = {
    errors: [],
    has_errors: false,
    html_name: parent.html_name + '.' + String(name),
    id: ++form.last_field_id,
  };
  if (value && typeof value === 'object') {
    if (Array.isArray(value)) {
      field.field = value.map(
        (x, i) => createField(form, field, i, x),
      );
    } else {
      const fields = {};
      for (const key in value) {
        fields[key] = createField(form, field, key, value[key]);
      }
      field.field = fields;
    }
  } else {
    field.value = value;
  }
  return field;
}
