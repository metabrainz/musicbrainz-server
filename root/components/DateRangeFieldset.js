// @flow
import React from 'react';

import FormRowPartialDate from './FormRowPartialDate';
import FormRowCheckbox from './FormRowCheckbox';

type DateRangeFieldsetT = {
  disabled?: boolean,
  endDateOnChangeDay?: (e: SyntheticInputEvent<HTMLInputElement>) => void,
  endDateOnChangeMonth?: (e: SyntheticInputEvent<HTMLInputElement>) => void,
  endDateOnChangeYear?: (e: SyntheticInputEvent<HTMLInputElement>) => void,
  endedLabel: string,
  onChangeEnded?: (e: SyntheticEvent<HTMLInputElement>) => void,
  period: {
    field: {
      begin_date: PartialDateFieldT,
      end_date: PartialDateFieldT,
      ended: FieldT<boolean>,
    },
  },
  startDateOnChangeDay?: (e: SyntheticInputEvent<HTMLInputElement>) => void,
  startDateOnChangeMonth?: (e: SyntheticInputEvent<HTMLInputElement>) => void,
  startDateOnChangeYear?: (e: SyntheticInputEvent<HTMLInputElement>) => void,
};


const DateRangeFieldset = ({
  period,
  endedLabel,
  disabled,
  endDateOnChangeMonth,
  endDateOnChangeDay,
  endDateOnChangeYear,
  onChangeEnded,
  startDateOnChangeMonth,
  startDateOnChangeDay,
  startDateOnChangeYear,
}: DateRangeFieldsetT) => {
  return (
    <>
      <fieldset>
        <legend>{l('Date Period')}</legend>
        <p>
          {l('Dates are in the format YYYY-MM-DD. Partial dates such as YYYY-MM or just YYYY are OK, or you can omit the date entirely.')}
        </p>
        <FormRowPartialDate
          disabled={disabled}
          field={period.field.begin_date}
          label={l('Begin date:')}
          onChangeDay={startDateOnChangeDay}
          onChangeMonth={startDateOnChangeMonth}
          onChangeYear={startDateOnChangeYear}
        />
        <FormRowPartialDate
          disabled={disabled}
          field={period.field.end_date}
          label={l('End date:')}
          onChangeDay={endDateOnChangeDay}
          onChangeMonth={endDateOnChangeMonth}
          onChangeYear={endDateOnChangeYear}
        />
        <FormRowCheckbox
          disabled={disabled}
          field={period.field.ended}
          label={endedLabel}
          onChange={onChangeEnded}
        />
      </fieldset>
    </>
  );
};

export default DateRangeFieldset;
