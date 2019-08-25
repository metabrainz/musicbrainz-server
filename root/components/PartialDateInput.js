/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

type Props = {|
  +field: PartialDateFieldT,
  +onChangeDay?: (e: SyntheticInputEvent<HTMLInputElement>) => void,
  +onChangeMonth?: (e: SyntheticInputEvent<HTMLInputElement>) => void,
  +onChangeYear?: (e: SyntheticInputEvent<HTMLInputElement>) => void,
|};

const PartialDateInput = ({
  field,
  onChangeDay,
  onChangeMonth,
  onChangeYear,
  ...inputProps
}: Props) => (
  <span className="partial-date">
    <input
      className="partial-date-year"
      defaultValue={field.field.year.value}
      id={'id-' + field.field.year.html_name}
      maxLength={4}
      name={field.field.year.html_name}
      onChange={onChangeYear}
      placeholder={l('YYYY')}
      size={4}
      type="text"
      {...inputProps}
    />
    {'-'}
    <input
      className="partial-date-month"
      defaultValue={field.field.month.value}
      id={'id-' + field.field.month.html_name}
      maxLength={2}
      name={field.field.month.html_name}
      onChange={onChangeMonth}
      placeholder={l('MM')}
      size={2}
      type="text"
      {...inputProps}
    />
    {'-'}
    <input
      className="partial-date-day"
      defaultValue={field.field.day.value}
      id={'id-' + field.field.day.html_name}
      maxLength={2}
      name={field.field.day.html_name}
      onChange={onChangeDay}
      placeholder={l('DD')}
      size={2}
      type="text"
      {...inputProps}
    />
  </span>
);

export default PartialDateInput;
