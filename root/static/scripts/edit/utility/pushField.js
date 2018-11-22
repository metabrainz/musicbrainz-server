/*
 * @flow
 * Copyright (C) 2015-2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import createField from './createField';

export default function pushField<F>(
  repeatable: ReadOnlyRepeatableFieldT<F>,
  value: mixed,
) {
  return createField(
    repeatable,
    String(repeatable.field.length),
    value,
  );
}
