/*
 * @flow strict-local
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {useCallback} from 'react';

import FieldErrors from '../../../../components/FieldErrors.js';
import FormRowPartialDate, {
  type ActionT as FormRowPartialDateActionT,
  runReducer as runFormRowPartialDateReducer,
} from '../../../../components/FormRowPartialDate.js';
import FormRowCheckbox from '../../../../components/FormRowCheckbox.js';
import {applyAllPendingErrors} from '../../../../utility/subfieldErrors.js';
import isDateEmpty from '../../common/utility/isDateEmpty.js';
import parseIntegerOrNull from '../../common/utility/parseIntegerOrNull.js';
import {isDatePeriodValid} from '../utility/dates.js';

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
      runFormRowPartialDateReducer(
        subfields.end_date,
        {
          date: {day: day, month: month, year: year},
          type: 'set-date',
        },
      );
      validateDatePeriod(state);
      applyAllPendingErrors(state);
      break;
    }
  }
}

const DateRangeFieldset = ({
  disabled = false,
  dispatch,
  endedLabel,
  field,
}: PropsT): React$Element<React$FragmentType> => {
  const subfields = field.field;

  const handleEndedChange = useCallback((
    event: SyntheticEvent<HTMLInputElement>,
  ) => {
    dispatch({
      enabled: event.currentTarget.checked,
      type: 'set-ended',
    });
  }, [dispatch]);

  const handleDateCopy = () => {
    dispatch({type: 'copy-date'});
  };

  const beginDateDispatch = useCallback((
    action: FormRowPartialDateActionT,
  ) => {
    dispatch({action, type: 'update-begin-date'});
  }, [dispatch]);

  const endDateDispatch = useCallback((
    action: FormRowPartialDateActionT,
  ) => {
    dispatch({action, type: 'update-end-date'});
  }, [dispatch]);

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
          dispatch={beginDateDispatch}
          field={subfields.begin_date}
          label={addColonText(l('Begin date'))}
        >
          <button
            className="icon copy-date"
            disabled={disabled}
            onClick={handleDateCopy}
            title={l('Copy date')}
            type="button"
          />
        </FormRowPartialDate>
        <FormRowPartialDate
          disabled={disabled}
          dispatch={endDateDispatch}
          field={subfields.end_date}
          label={addColonText(l('End date'))}
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
          onChange={handleEndedChange}
        />
      </fieldset>
    </>
  );
};

export default DateRangeFieldset;
