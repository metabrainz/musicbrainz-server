/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import isDateEmpty from '../../common/utility/isDateEmpty.js';
import type {
  ActionT as DateRangeFieldsetActionT,
} from '../../edit/components/DateRangeFieldset.js';
import {
  partialDateFromField,
  reducer as dateRangeFieldsetReducer,
} from '../../edit/components/DateRangeFieldset.js';
import FieldErrors, {
  FieldErrorsList,
} from '../../edit/components/FieldErrors.js';
import FormRowCheckbox from '../../edit/components/FormRowCheckbox.js';
import PartialDateInput from '../../edit/components/PartialDateInput.js';
import useDateRangeFieldset from '../../edit/hooks/useDateRangeFieldset.js';
import {
  createCompoundField,
  createField,
} from '../../edit/utility/createField.js';
import type {DialogDatePeriodStateT} from '../types.js';

type PropsT = {
  +dispatch: (DateRangeFieldsetActionT) => void,
  +isHelpVisible: boolean,
  +state: DialogDatePeriodStateT,
};

export type ActionT = DateRangeFieldsetActionT;

export function createInitialState(
  datePeriod: $ReadOnly<{...DatePeriodRoleT, ...}>,
): DialogDatePeriodStateT {
  const {
    begin_date: beginDate,
    end_date: endDate,
    ended,
  } = datePeriod;

  const field = createCompoundField('period', {
    begin_date: createCompoundField(
      'period.begin_date',
      {
        day: createField(
          'period.begin_date.day',
          (beginDate?.day ?? null),
        ),
        month: createField(
          'period.begin_date.month',
          (beginDate?.month ?? null),
        ),
        year: createField(
          'period.begin_date.year',
          (beginDate?.year ?? null),
        ),
      },
    ),
    end_date: createCompoundField(
      'period.end_date',
      {
        day: createField(
          'period.end_date.day',
          (endDate?.day ?? null),
        ),
        month: createField(
          'period.end_date.month',
          (endDate?.month ?? null),
        ),
        year: createField(
          'period.end_date.year',
          (endDate?.year ?? null),
        ),
      },
    ),
    ended: createField('period.ended', ended),
  });

  return {
    field,
    result: {
      begin_date: beginDate,
      end_date: endDate,
      ended,
    },
  };
}

export function updateDialogDatePeriodState(
  state: DialogDatePeriodStateT,
  action: DateRangeFieldsetActionT,
): DialogDatePeriodStateT {
  const newState: {...DialogDatePeriodStateT} = {...state};
  const oldField = state.field;
  const newField = dateRangeFieldsetReducer(
    newState.field,
    action,
  );
  newState.field = newField;

  const newBeginDate = newField.field.begin_date;
  const newEndDate = newField.field.end_date;
  const newEnded = newField.field.ended.value;

  const beginDateChanged =
    oldField.field.begin_date.field !== newBeginDate.field;
  const endDateChanged =
    oldField.field.end_date.field !== newEndDate.field;
  const endedChanged =
    oldField.field.ended.value !== newEnded;

  if (
    beginDateChanged ||
    endDateChanged ||
    endedChanged
  ) {
    if (!(
      newBeginDate.errors.length ||
      newBeginDate.pendingErrors?.length ||
      newEndDate.errors.length ||
      newEndDate.pendingErrors?.length
    )) {
      newState.result = {
        begin_date: beginDateChanged
          ? partialDateFromField(newBeginDate)
          : state.result.begin_date,
        end_date: endDateChanged
          ? partialDateFromField(newEndDate)
          : state.result.end_date,
        ended: newEnded,
      };
    }
  } else if (newField === oldField) {
    return state;
  }

  return newState;
}

const DialogDatePeriod = (React.memo<PropsT>(({
  dispatch,
  isHelpVisible,
  state,
}: PropsT): React$MixedElement | null => {
  const hooks = useDateRangeFieldset(dispatch);

  const field = state.field;
  const {
    begin_date: beginDateField,
    end_date: endDateField,
  } = field.field;
  const endDate = partialDateFromField(endDateField);

  return (
    <>
      <tr>
        <td className="section">
          <label htmlFor={'id-' + beginDateField.field.year.html_name}>
            {l('Begin date')}
          </label>
        </td>
        <td className="fields">
          <PartialDateInput
            dispatch={hooks.beginDateDispatch}
            field={beginDateField}
            yearInputRef={hooks.beginYearInputRef}
          />
          <button
            className="icon copy-date"
            onClick={hooks.handleDateCopy}
            title={l('Copy to end date')}
            type="button"
          />
          <FieldErrors field={beginDateField} />
        </td>
      </tr>
      <tr>
        <td className="section">
          <label htmlFor={'id-' + endDateField.field.year.html_name}>
            {l('End date')}
          </label>
        </td>
        <td className="fields end-date">
          <PartialDateInput
            dispatch={hooks.endDateDispatch}
            field={endDateField}
            yearInputRef={hooks.endYearInputRef}
          />
          <FieldErrors field={endDateField} />
          <br />
          <FormRowCheckbox
            disabled={!isDateEmpty(endDate)}
            field={field.field.ended}
            label={l('This relationship has ended.')}
            onChange={hooks.handleEndedChange}
          />
          <FieldErrorsList
            errors={field.errors}
            hasHtmlErrors={false}
          />
        </td>
      </tr>
      {isHelpVisible ? (
        <tr>
          <td />
          <td>
            <div className="ar-descr">
              <p>
                {l(`If you want to set the relationship as happening on one
                    specific date, just set the same end date and start date.
                    You can use the arrow button to copy the begin date to
                    the end date.`)}
              </p>
              <p>
                {l(`If you do not know the end date, but you know the
                    relationship has ended and this seems like useful
                    information to store (for example, if someone is no
                    longer a member of a band), you can indicate it with the
                    checkbox above.`)}
              </p>
            </div>
          </td>
        </tr>
      ) : null}
    </>
  );
}): React$AbstractComponent<PropsT, mixed>);

export default DialogDatePeriod;
