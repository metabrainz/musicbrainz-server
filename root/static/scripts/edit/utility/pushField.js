/*
 * @flow strict
 * Copyright (C) 2015-2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  createCompoundField,
  createField,
  type MapFields,
} from './createField';

export function pushField<V>(
  repeatable: RepeatableFieldT<FieldT<V>>,
  value: V,
) {
  repeatable.field.push(
    createField(
      repeatable.html_name + '.' + String(++repeatable.last_index),
      value,
    ),
  );
}

export function pushCompoundField<F: {...}>(
  repeatable: RepeatableFieldT<CompoundFieldT<MapFields<$ReadOnly<F>>>>,
  fieldValues: F,
) {
  const name = repeatable.html_name + '.' + String(++repeatable.last_index);
  repeatable.field.push(createCompoundField(name, fieldValues));
}
