/*
 * @flow
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export default function createField(
  form: FormT<$Subtype<{}>>,
  value: mixed,
): $Subtype<FieldRoleT> {
  const field: any = {
    errors: [],
    has_errors: false,
    id: ++form.last_field_id,
  };
  if (value && typeof value === 'object') {
    if (Array.isArray(value)) {
      field.field = value.map(x => createField(form, x));
    } else {
      const fields = {};
      for (const key in value) {
        fields[key] = createField(form, value[key]);
      }
      field.field = fields;
    }
  } else {
    field.value = value;
  }
  return field;
}
