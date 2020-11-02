/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

type CommonProps = {
  +disabled?: boolean,
  +field: PartialDateFieldT,
};

type Props =
  | $ReadOnly<{
      ...CommonProps,
      +uncontrolled?: false,
    }>
  | $ReadOnly<{
      ...CommonProps,
      +uncontrolled: true,
    }>;

const PartialDateInput = ({
  disabled = false,
  field,
  uncontrolled = false,
  ...inputProps
}: Props): React.Element<'span'> => {
  const yearProps = {};
  const monthProps = {};
  const dayProps = {};

  if (uncontrolled) {
    yearProps.defaultValue = field.field.year.value;
    monthProps.defaultValue = field.field.month.value;
    dayProps.defaultValue = field.field.day.value;
  } else {
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
        {...inputProps}
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
        {...inputProps}
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
        {...inputProps}
      />
    </span>
  );
};

export default PartialDateInput;
