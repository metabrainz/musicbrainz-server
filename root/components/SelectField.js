/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {unwrapNl} from '../static/scripts/common/i18n';
import getSelectValue from '../utility/getSelectValue';

const buildOption = (option: SelectOptionT, index: number) => (
  <option key={index} value={option.value}>
    {unwrapNl(option.label)}
  </option>
);

const buildOptGroup = (optgroup, index) => (
  <optgroup key={index} label={optgroup.optgroup}>
    {optgroup.options.map(buildOption)}
  </optgroup>
);

type SelectFieldProps = {|
  +allowEmpty?: boolean,
  +disabled?: boolean,
  +field: ReadOnlyFieldT<?StrOrNum>,
  +onChange?: (event: SyntheticEvent<HTMLSelectElement>) => void,
  +options: MaybeGroupedOptionsT,
  +required?: boolean,
  +uncontrolled?: boolean,
|};

const SelectField = ({
  allowEmpty = true,
  disabled = false,
  field,
  onChange,
  options,
  required,
  uncontrolled = false,
}: SelectFieldProps) => {
  const selectElementProps: any = {
    className: 'with-button',
    disabled: disabled,
    id: 'id-' + field.html_name,
    name: field.html_name,
    required: required,
  };

  if (uncontrolled) {
    selectElementProps.defaultValue =
      getSelectValue(field, options, allowEmpty);
  } else {
    selectElementProps.onChange = onChange;
    selectElementProps.value = getSelectValue(field, options, allowEmpty);
  }

  return (
    <select {...selectElementProps}>
      {allowEmpty
        ? <option value="">{'\xA0'}</option>
        : null}
      {options.grouped
        ? options.options.map(buildOptGroup)
        : options.options.map(buildOption)}
    </select>
  );
};

export default SelectField;
