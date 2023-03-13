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
  StateT,
} from '../../edit/components/DateRangeFieldset.js';
import {
  partialDateFromField,
} from '../../edit/components/DateRangeFieldset.js';
import FieldErrors, {
  FieldErrorsList,
} from '../../edit/components/FieldErrors.js';
import FormRowCheckbox from '../../edit/components/FormRowCheckbox.js';
import PartialDateInput from '../../edit/components/PartialDateInput.js';
import useDateRangeFieldset from '../../edit/hooks/useDateRangeFieldset.js';

type PropsT = {
  +dispatch: (ActionT) => void,
  +isHelpVisible: boolean,
  +state: StateT,
};

export type ActionT = DateRangeFieldsetActionT;

const DialogDatePeriod = (React.memo<PropsT>(({
  dispatch,
  isHelpVisible,
  state,
}: PropsT): React$MixedElement | null => {
  const hooks = useDateRangeFieldset(dispatch);

  const beginDateField = state.field.begin_date;
  const endDateField = state.field.end_date;
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
            field={state.field.end_date}
            yearInputRef={hooks.endYearInputRef}
          />
          <FieldErrors field={state.field.end_date} />
          <br />
          <FormRowCheckbox
            disabled={!isDateEmpty(endDate)}
            field={state.field.ended}
            label={l('This relationship has ended.')}
            onChange={hooks.handleEndedChange}
          />
          <FieldErrorsList
            errors={state.errors}
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
