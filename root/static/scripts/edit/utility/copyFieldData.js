/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {CowContext} from 'mutate-cow';

export function copyFieldErrors(
  sourceField: AnyFieldT,
  targetField: CowContext<AnyFieldT>,
): void {
  targetField
    .set('errors', [...sourceField.errors])
    .set(
      'pendingErrors',
      sourceField.pendingErrors
        ? [...sourceField.pendingErrors]
        : undefined,
    );
}

export default function copyFieldData<T>(
  sourceField: ReadOnlyFieldT<T>,
  targetField: CowContext<ReadOnlyFieldT<T>>,
): void {
  targetField.set('value', sourceField.value);
  copyFieldErrors(sourceField, targetField);
}

export function copyPartialDateField(
  sourceField: PartialDateFieldT,
  targetField: CowContext<PartialDateFieldT>,
): void {
  const sourceSubfields = sourceField.field;
  const targetSubfields = targetField.get('field');
  copyFieldData(sourceSubfields.year, targetSubfields.get('year'));
  copyFieldData(sourceSubfields.month, targetSubfields.get('month'));
  copyFieldData(sourceSubfields.day, targetSubfields.get('day'));
  copyFieldErrors(sourceField, targetField);
}

export function copyDatePeriodField(
  sourceField: DatePeriodFieldT,
  targetField: CowContext<DatePeriodFieldT>,
): void {
  const sourceSubfields = sourceField.field;
  const targetSubfields = targetField.get('field');
  copyPartialDateField(
    sourceSubfields.begin_date,
    targetSubfields.get('begin_date'),
  );
  copyPartialDateField(
    sourceSubfields.end_date,
    targetSubfields.get('end_date'),
  );
  copyFieldData(sourceSubfields.ended, targetSubfields.get('ended'));
  copyFieldErrors(sourceField, targetField);
}
