/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import mutate from 'mutate-cow';
import * as React from 'react';

import isDateEmpty from '../../common/utility/isDateEmpty.js';
import parseIntegerOrNull from '../../common/utility/parseIntegerOrNull.js';
import FieldErrors from '../../edit/components/FieldErrors.js';
import useDateRangeFieldset from '../hooks/useDateRangeFieldset.js';
import {isDatePeriodValid} from '../utility/dates.js';
import {applyAllPendingErrors} from '../utility/subfieldErrors.js';

import FormRowCheckbox from './FormRowCheckbox.js';
import FormRowPartialDate, {
  type ActionT as FormRowPartialDateActionT,
  runReducer as runFormRowPartialDateReducer,
} from './FormRowPartialDate.js';

/* eslint-disable flowtype/sort-keys */
export type ActionT =
  | {+type: 'update-begin-date', +action: FormRowPartialDateActionT}
  | {+type: 'update-end-date', +action: FormRowPartialDateActionT}
  | {+type: 'set-ended', +enabled: boolean}
  | {+type: 'copy-date'};
/* eslint-enable flowtype/sort-keys */

type PropsT = {
  +disabled?: boolean,
  +dispatch: (ActionT) => void,
  +endedLabel: string,
  +field: DatePeriodFieldT,
};

export type StateT = DatePeriodFieldT;

export type WritableStateT = WritableDatePeriodFieldT;

export function partialDateFromField(
  compoundField: PartialDateFieldT,
): PartialDateT {
  const fields = compoundField.field;
  return {
    day: parseIntegerOrNull(fields.day.value),
    month: parseIntegerOrNull(fields.month.value),
    year: parseIntegerOrNull(fields.year.value),
  };
}

function validateDatePeriod(state: WritableStateT) {
  const beginDateField = state.field.begin_date;
  const endDateField = state.field.end_date;
  const pendingErrors = [];
  if (!(
    beginDateField.pendingErrors?.length ||
    endDateField.pendingErrors?.length ||
    isDatePeriodValid(
      partialDateFromField(beginDateField),
      partialDateFromField(endDateField),
    )
  )) {
    pendingErrors.push(l('The end date cannot precede the begin date.'));
  }
  state.errors = state.errors.filter(e => pendingErrors.includes(e));
  state.pendingErrors = pendingErrors;
}

function runDateFieldReducer(
  dateField: WritablePartialDateFieldT,
  action: FormRowPartialDateActionT,
  state: WritableStateT,
) {
  runFormRowPartialDateReducer(
    dateField,
    action,
  );
  switch (action.type) {
    case 'set-date': {
      validateDatePeriod(state);
      break;
    }
    case 'show-pending-errors': {
      /*
       * Changing the begin date may produce on an error on the end date
       * field ("The end date cannot precede the begin date.").
       */
      applyAllPendingErrors(state);
      break;
    }
  }
}

export function runReducer(
  state: WritableStateT,
  action: ActionT,
): void {
  const subfields = state.field;
  switch (action.type) {
    case 'update-begin-date': {
      runDateFieldReducer(
        subfields.begin_date,
        action.action,
        state,
      );
      break;
    }
    case 'update-end-date': {
      runDateFieldReducer(
        subfields.end_date,
        action.action,
        state,
      );
      if (action.action.type === 'set-date') {
        const newDate = action.action.date;
        if (!isDateEmpty(newDate)) {
          runReducer(
            state,
            {enabled: true, type: 'set-ended'},
          );
        }
      }
      break;
    }
    case 'set-ended': {
      const enabled = action.enabled;
      subfields.ended.value = enabled;
      break;
    }
    case 'copy-date': {
      const beginDateFields = subfields.begin_date.field;
      const year = String(beginDateFields.year.value ?? '');
      const month = String(beginDateFields.month.value ?? '');
      const day = String(beginDateFields.day.value ?? '');
      const newEndDate: PartialDateStringsT =
        {day: day, month: month, year: year};
      runFormRowPartialDateReducer(
        subfields.end_date,
        {
          date: newEndDate,
          type: 'set-date',
        },
      );
      if (!isDateEmpty(newEndDate)) {
        runReducer(
          state,
          {enabled: true, type: 'set-ended'},
        );
      }
      validateDatePeriod(state);
      applyAllPendingErrors(state);
      break;
    }
  }
}

export function reducer(
  state: StateT,
  action: ActionT,
): StateT {
  return mutate<WritableStateT, StateT>(state, (newState) => {
    runReducer(newState, action);
  });
}

const DateRangeFieldset = (React.memo<PropsT>(({
  disabled = false,
  dispatch,
  endedLabel,
  field,
}: PropsT): React$Element<React$FragmentType> => {
  const subfields = field.field;

  const hooks = useDateRangeFieldset(dispatch);

  return (
    <>
      <fieldset>
        <legend>{l('Date Period')}</legend>
        <p>
          {l(`Dates are in the format YYYY-MM-DD.
              Partial dates such as YYYY-MM or just YYYY are OK,
              or you can omit the date entirely.`)}
        </p>
        <FormRowPartialDate
          disabled={disabled}
          dispatch={hooks.beginDateDispatch}
          field={subfields.begin_date}
          label={addColonText(l('Begin date'))}
          yearInputRef={hooks.beginYearInputRef}
        >
          <button
            className="icon copy-date"
            disabled={disabled}
            onClick={hooks.handleDateCopy}
            title={l('Copy to end date')}
            type="button"
          />
        </FormRowPartialDate>
        <FormRowPartialDate
          disabled={disabled}
          dispatch={hooks.endDateDispatch}
          field={subfields.end_date}
          label={addColonText(l('End date'))}
          yearInputRef={hooks.endYearInputRef}
        />
        <FieldErrors
          field={field}
          includeSubFields={false}
        />
        <FormRowCheckbox
          disabled={
            disabled ||
            !isDateEmpty(partialDateFromField(subfields.end_date))
          }
          field={subfields.ended}
          label={endedLabel}
          onChange={hooks.handleEndedChange}
        />
      </fieldset>
    </>
  );
}): React.AbstractComponent<PropsT>);

export default DateRangeFieldset;
