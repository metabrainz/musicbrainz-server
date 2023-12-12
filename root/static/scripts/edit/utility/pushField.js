/*
 * @flow strict
 * Copyright (C) 2015-2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {CowContext} from 'mutate-cow';

import {
  createCompoundFieldFromObject,
  createField,
} from './createField.js';

export function pushField<V>(
  repeatableCtx: CowContext<RepeatableFieldT<FieldT<V>>>,
  value: V,
) {
  const repeatable = repeatableCtx.read();
  const nextIndex = repeatable.last_index + 1;
  repeatableCtx
    .set('last_index', nextIndex)
    .get('field').write()
    .push(
      createField(repeatable.html_name + '.' + String(nextIndex), value),
    );
}

export function pushCompoundField<F: {...}>(
  repeatableCtx: CowContext<
    RepeatableFieldT<
      CompoundFieldT<{+[K in keyof F]: FieldT<F[K]>}>,
    >,
  >,
  fieldValues: F,
) {
  const repeatable = repeatableCtx.read();
  const nextIndex = repeatable.last_index + 1;
  const name = repeatable.html_name + '.' + String(nextIndex);
  repeatableCtx
    .set('last_index', nextIndex)
    .get('field').write()
    .push(createCompoundFieldFromObject(name, fieldValues));
}
