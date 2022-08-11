/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {isDateValid, isYearFourDigits}
  from '../static/scripts/edit/utility/dates.js';
import {applyPendingErrors} from '../utility/subfieldErrors.js';

/* eslint-disable flowtype/sort-keys */
export type ActionT =
  | {
      +type: 'set-date',
      +date: {+year?: string, +month?: string, +day?: string},
    }
  | {+type: 'show-pending-errors'};
/* eslint-enable flowtype/sort-keys */

type CommonProps = {
  +disabled?: boolean,
  +field: PartialDateFieldT,
};

type Props =
  | $ReadOnly<{
      ...CommonProps,
      +dispatch: (ActionT) => void,
      +uncontrolled?: false,
    }>
  | $ReadOnly<{
      ...CommonProps,
      +dispatch?: void,
      +uncontrolled: true,
    }>;

export type StateT = PartialDateFieldT;

export type WritableStateT = WritablePartialDateFieldT;

function validateDate(date: WritablePartialDateFieldT) {
  const year = String(date.field.year.value ?? '');
  const month = String(date.field.month.value ?? '');
  const day = String(date.field.day.value ?? '');

  const pendingErrors = [];
  if (!isYearFourDigits(year)) {
    pendingErrors.push(
      l(`The year should have four digits. If you want to enter a year
         earlier than 1000 CE, please pad with zeros, such as “0123”.`),
    );
  } else if (!isDateValid(year, month, day)) {
    pendingErrors.push(l('The date you\'ve entered is not valid'));
  }
  /*
   * If there's a new pending error, we don't show it until the
   * field is blurred. But if an existing error is resolved, we
   * hide the error right away.
   */
  date.errors = date.errors.filter(e => pendingErrors.includes(e));
  date.pendingErrors = pendingErrors;
}

export function runReducer(
  state: WritableStateT,
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
        state.field.year.value = newYear;
      }
      if (newMonth != null) {
        state.field.month.value = newMonth;
      }
      if (newDay != null) {
        state.field.day.value = newDay;
      }
      validateDate(state);
      break;
    }
  }
}

const PartialDateInput = (props: Props): React.Element<'span'> => {
  const disabled = props.disabled ?? false;
  const field = props.field;

  const yearProps = {};
  const monthProps = {};
  const dayProps = {};

  if (props.uncontrolled) {
    yearProps.defaultValue = field.field.year.value;
    monthProps.defaultValue = field.field.month.value;
    dayProps.defaultValue = field.field.day.value;
  } else {
    const handleDateChange = (
      event: SyntheticEvent<HTMLInputElement>,
      fieldName: 'year' | 'month' | 'day',
    ) => {
      props.dispatch({
        // $FlowIssue[invalid-computed-prop]
        date: {[fieldName]: event.currentTarget.value},
        type: 'set-date',
      });
    };

    const handleBlur = () => {
      props.dispatch({type: 'show-pending-errors'});
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
        maxLength={4}
        name={field.field.year.html_name}
        placeholder={l('YYYY')}
        size={4}
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
};

export default PartialDateInput;
