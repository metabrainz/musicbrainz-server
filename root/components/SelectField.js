/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {unwrapNl} from '../static/scripts/common/i18n.js';
import getSelectValue from '../utility/getSelectValue.js';

const buildOption = (option: SelectOptionT, index: number) => (
  <option key={index} value={option.value}>
    {unwrapNl<string>(option.label)}
  </option>
);

const buildOptGroup = (
  optgroup: {+optgroup: string, +options: SelectOptionsT},
  index: number,
) => (
  <optgroup key={index} label={optgroup.optgroup}>
    {optgroup.options.map(buildOption)}
  </optgroup>
);

type SharedElementProps = {
  className?: string,
  disabled?: boolean,
  id?: string,
  name?: string,
  onChange?: (event: SyntheticEvent<HTMLSelectElement>) => void,
  required?: boolean,
  style?: {},
};

type MultipleSelectElementProps = {
  defaultValue?: Array<StrOrNum>,
  multiple: boolean,
  value?: Array<StrOrNum>,
  ...SharedElementProps,
  ...
};

type SelectElementProps = {
  defaultValue?: StrOrNum,
  value?: StrOrNum,
  ...SharedElementProps,
  ...
};

type SharedFieldProps = {
  +allowEmpty?: boolean,
  +className?: string,
  +disabled?: boolean,
  +onChange?: (event: SyntheticEvent<HTMLSelectElement>) => void,
  +options: MaybeGroupedOptionsT,
  +required?: boolean,
  +uncontrolled?: boolean,
};

type MultipleSelectFieldProps = {
  +field: ReadOnlyFieldT<?Array<StrOrNum>>,
  ...SharedFieldProps,
  ...
};

type SelectFieldProps = {
  +field: ReadOnlyFieldT<?StrOrNum>,
  ...SharedFieldProps,
  ...
};

export const MultipleSelectField = ({
  allowEmpty = true,
  disabled = false,
  field,
  onChange,
  options,
  required,
  uncontrolled = false,
  ...props
}: MultipleSelectFieldProps): React.Element<'select'> => {
  const selectProps: MultipleSelectElementProps = {...props, multiple: true};

  if (selectProps.className === undefined) {
    selectProps.className = 'with-button';
  }

  selectProps.disabled = disabled;
  selectProps.id = 'id-' + field.html_name;
  selectProps.name = field.html_name;
  selectProps.required = required;

  if (uncontrolled) {
    selectProps.defaultValue = field.value || [];
  } else {
    selectProps.onChange = onChange;
    selectProps.value = field.value || [];
  }

  return (
    <select {...selectProps}>
      {allowEmpty
        ? <option value="">{'\xA0'}</option>
        : null}
      {options.grouped
        ? options.options.map(buildOptGroup)
        : options.options.map(buildOption)}
    </select>
  );
};

const SelectField = ({
  allowEmpty = true,
  disabled = false,
  field,
  onChange,
  options,
  required,
  uncontrolled = false,
  ...props
}: SelectFieldProps): React.Element<'select'> => {
  const selectProps: SelectElementProps = props;

  if (selectProps.className === undefined) {
    selectProps.className = 'with-button';
  }

  selectProps.disabled = disabled;
  selectProps.id = 'id-' + field.html_name;
  selectProps.name = field.html_name;
  selectProps.required = required;

  if (uncontrolled) {
    selectProps.defaultValue = getSelectValue(field, options, allowEmpty);
  } else {
    selectProps.onChange = onChange;
    selectProps.value = getSelectValue(field, options, allowEmpty);
  }

  return (
    <select {...selectProps}>
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
