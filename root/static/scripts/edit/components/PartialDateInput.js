/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {CowContext} from 'mutate-cow';

import {isDateValid, isYearFourDigits} from '../utility/dates.js';
import {applyPendingErrors} from '../utility/subfieldErrors.js';

/* eslint-disable ft-flow/sort-keys */
export type ActionT =
  | {
      +type: 'set-date',
      +date: {+year?: string, +month?: string, +day?: string},
    }
  | {+type: 'show-pending-errors'};
/* eslint-enable ft-flow/sort-keys */

type ControlledPropsT =
  | $ReadOnly<{+dispatch: (ActionT) => void, +uncontrolled?: false}>
  | $ReadOnly<{+dispatch?: void, +uncontrolled: true}>;

export type StateT = PartialDateFieldT;

function validateDate(dateCtx: CowContext<StateT>) {
  const date = dateCtx.read();
  const year = String(date.field.year.value ?? '');
  const month = String(date.field.month.value ?? '');
  const day = String(date.field.day.value ?? '');

  const pendingErrors = [];
  if (year === '0000') {
    pendingErrors.push(
      l('0 is not a valid year.'),
    );
  } else if (!isYearFourDigits(year)) {
    pendingErrors.push(
      l(`The year should have four digits. If you want to enter a year
         earlier than 1000 CE, please pad with zeros, such as “0123”.`),
    );
  } else if (!isDateValid({day, month, year})) {
    pendingErrors.push(l('The date you\'ve entered is not valid'));
  }
  /*
   * If there's a new pending error, we don't show it until the
   * field is blurred. But if an existing error is resolved, we
   * hide the error right away.
   */
  dateCtx
    .set('errors', date.errors.filter(e => pendingErrors.includes(e)))
    .set('pendingErrors', pendingErrors);
}

export function runReducer(
  state: CowContext<StateT>,
  action: ActionT,
): void {
  switch (action.type) {
    case 'show-pending-errors': {
      applyPendingErrors(state);
      break;
    }
    case 'set-date': {
      const newYear = action.date.year;
      const newMonth = action.date.month;
      const newDay = action.date.day;
      if (newYear != null) {
        state.set('field', 'year', 'value', newYear);
      }
      if (newMonth != null) {
        state.set('field', 'month', 'value', newMonth);
      }
      if (newDay != null) {
        state.set('field', 'day', 'value', newDay);
      }
      validateDate(state);
      break;
    }
  }
}

type DatePartPropsT = {
  defaultValue?: StrOrNum | null,
  onBlur?: () => void,
  onChange?: (SyntheticEvent<HTMLInputElement>) => void,
  value?: StrOrNum,
};

component PartialDateInput(
  disabled: boolean = false,
  field: PartialDateFieldT,
  yearInputRef?: {current: HTMLInputElement | null},
  ...controlledProps: ControlledPropsT
) {
  const yearProps: DatePartPropsT = {};
  const monthProps: DatePartPropsT = {};
  const dayProps: DatePartPropsT = {};

  if (controlledProps.uncontrolled /*:: === true */) {
    yearProps.defaultValue = field.field.year.value;
    monthProps.defaultValue = field.field.month.value;
    dayProps.defaultValue = field.field.day.value;
  } else {
    const handleDateChange = (
      event: SyntheticEvent<HTMLInputElement>,
      fieldName: 'year' | 'month' | 'day',
    ) => {
      controlledProps.dispatch({
        // $FlowIssue[invalid-computed-prop]
        date: {[fieldName]: event.currentTarget.value},
        type: 'set-date',
      });
    };

    const handleBlur = () => {
      controlledProps.dispatch({type: 'show-pending-errors'});
    };

    yearProps.onBlur = handleBlur;
    monthProps.onBlur = handleBlur;
    dayProps.onBlur = handleBlur;

    yearProps.onChange = (event) => handleDateChange(
      event,
      'year',
    );
    monthProps.onChange = (event) => handleDateChange(
      event,
      'month',
    );
    dayProps.onChange = (event) => handleDateChange(
      event,
      'day',
    );

    yearProps.value = field.field.year.value ?? '';
    monthProps.value = field.field.month.value ?? '';
    dayProps.value = field.field.day.value ?? '';
  }

  return (
    <span className="partial-date">
      <input
        className="partial-date-year"
        disabled={disabled}
        id={'id-' + field.field.year.html_name}
        maxLength={5}
        name={field.field.year.html_name}
        placeholder={l('YYYY')}
        ref={yearInputRef}
        size={5}
        type="text"
        {...yearProps}
      />
      {'-'}
      <input
        className="partial-date-month"
        disabled={disabled}
        id={'id-' + field.field.month.html_name}
        maxLength={2}
        name={field.field.month.html_name}
        placeholder={l('MM')}
        size={2}
        type="text"
        {...monthProps}
      />
      {'-'}
      <input
        className="partial-date-day"
        disabled={disabled}
        id={'id-' + field.field.day.html_name}
        maxLength={2}
        name={field.field.day.html_name}
        placeholder={l('DD')}
        size={2}
        type="text"
        {...dayProps}
      />
    </span>
  );
}

export default PartialDateInput;
