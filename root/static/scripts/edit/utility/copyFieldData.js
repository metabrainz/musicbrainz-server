/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export function copyFieldErrors(
  sourceField: {
    +errors: $ReadOnlyArray<string>,
    +pendingErrors?: $ReadOnlyArray<string>,
    ...
  },
  targetField: {
    errors: Array<string>,
    pendingErrors?: Array<string>,
    ...
  },
): void {
  targetField.errors = [...sourceField.errors];
  targetField.pendingErrors = sourceField.pendingErrors
    ? [...sourceField.pendingErrors]
    : undefined;
}

export default function copyFieldData<T>(
  sourceField: ReadOnlyFieldT<T>,
  targetField: FieldT<T>,
): void {
  targetField.value = sourceField.value;
  copyFieldErrors(sourceField, targetField);
}
