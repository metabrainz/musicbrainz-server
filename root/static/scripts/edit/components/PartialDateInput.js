/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {CowContext} from 'mutate-cow';

import formatDate from '../../common/utility/formatDate.js';
import parseNaturalDate from '../../common/utility/parseNaturalDate.js';
import {isDateValid, isYearFourDigits} from '../utility/dates.js';
import {applyPendingErrors} from '../utility/subfieldErrors.js';

/* eslint-disable ft-flow/sort-keys */
export type ActionT =
  | {
      +type: 'set-date',
      +date: PartialDateStringsT,
    }
  | {+type: 'set-parsed-date', +date: string}
  | {+type: 'show-pending-errors'};
/* eslint-enable ft-flow/sort-keys */

type ControlledPropsT =
  | $ReadOnly<{+dispatch: (ActionT) => void, +uncontrolled?: false}>
  | $ReadOnly<{+dispatch?: void, +uncontrolled: true}>;

export type StateT = PartialDateFieldT;

export function createInitialState(
  date: StateT,
): StateT {
  return {
    ...date,
    formattedDate: formatParserDate(date),
  };
}

export function formatParserDate(date: StateT): string {
  return formatDate({
    day: date.field.day.value,
    month: date.field.month.value,
    year: date.field.year.value,
  });
}

function updateDate(dateCtx: CowContext<StateT>, date: PartialDateStringsT) {
  const newYear = date.year;
  const newMonth = date.month;
  const newDay = date.day;
  if (newYear != null) {
    dateCtx.set('field', 'year', 'value', newYear);
  }
  if (newMonth != null) {
    dateCtx.set('field', 'month', 'value', newMonth);
  }
  if (newDay != null) {
    dateCtx.set('field', 'day', 'value', newDay);
  }
  validateDate(dateCtx);
}

function validateDate(dateCtx: CowContext<StateT>) {
  const date = dateCtx.read();
  const year = String(date.field.year.value ?? '');
  const month = String(date.field.month.value ?? '');
  const day = String(date.field.day.value ?? '');

  const pendingErrors = [];
  if (!isYearFourDigits(year)) {
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
  match (action) {
    {type: 'show-pending-errors'} => {
      applyPendingErrors(state);
    }
    {type: 'set-parsed-date', const date} => {
      const parsedDate = parseNaturalDate(date);
      updateDate(state, parsedDate);
      state.set('formattedDate', date);
    }
    {type: 'set-date', const date} => {
      updateDate(state, date);
      const formattedDate = formatParserDate(state.read());
      if (nonEmpty(formattedDate)) {
        state.set('formattedDate', formatParserDate(state.read()));
      } else {
        state.set('formattedDate', formatParserDate(state.read()));
      }
    }
  }
}

type DatePartPropsT = {
  defaultValue?: StrOrNum | null,
  onBlur?: () => void,
  onChange?: (SyntheticEvent<HTMLInputElement>) => void,
  value?: StrOrNum,
};

type DateParserPropsT = {
  onBlur?: () => void,
  onChange?: (SyntheticEvent<HTMLInputElement>) => void,
  value?: string,
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
  const parserProps: DateParserPropsT = {};

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
        // $FlowExpectedError[incompatible-indexer]
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
    parserProps.onBlur = handleBlur;

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

    parserProps.onChange = (event) => {
      controlledProps.dispatch({
        date: event.currentTarget.value,
        type: 'set-parsed-date',
      });
    };

    yearProps.value = field.field.year.value ?? '';
    monthProps.value = field.field.month.value ?? '';
    dayProps.value = field.field.day.value ?? '';
    parserProps.value = field.formattedDate ?? '';
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
        ref={yearInputRef}
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
      {controlledProps.uncontrolled /*:: === true */ ? null : (
        <>
          {' '}
          <input
            autoComplete="on"
            className="partial-date-parser"
            disabled={disabled}
            id={'id-' + field.html_name + '.partial-date-parser'}
            name={field.html_name + '.partial-date-parser'}
            placeholder={l('or paste a full date here')}
            size={12}
            type="text"
            {...parserProps}
          />
        </>
      )}
    </span>
  );
}

export default PartialDateInput;
