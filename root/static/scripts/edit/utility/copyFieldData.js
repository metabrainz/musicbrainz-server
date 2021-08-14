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


export function copyPartialDateField(
  sourceField: PartialDateFieldT,
  targetField: WritablePartialDateFieldT,
) {
  const sourceSubfields = sourceField.field;
  const targetSubfields = targetField.field;
  copyFieldData(sourceSubfields.year, targetSubfields.year);
  copyFieldData(sourceSubfields.month, targetSubfields.month);
  copyFieldData(sourceSubfields.day, targetSubfields.day);
  copyFieldErrors(sourceField, targetField);
}

export function copyDatePeriodField(
  sourceField: DatePeriodFieldT,
  targetField: WritableDatePeriodFieldT,
) {
  const sourceSubfields = sourceField.field;
  const targetSubfields = targetField.field;
  copyPartialDateField(
    sourceSubfields.begin_date,
    targetSubfields.begin_date,
  );
  copyPartialDateField(
    sourceSubfields.end_date,
    targetSubfields.end_date,
  );
  copyFieldData(sourceSubfields.ended, targetSubfields.ended);
  copyFieldErrors(sourceField, targetField);
}
