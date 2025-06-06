/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {unwrapNl} from '../i18n.js';
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
  onFocus?: (event: SyntheticEvent<HTMLSelectElement>) => void,
  required?: boolean,
  style?: {maxWidth?: string},
};

type MultipleSelectElementProps = {
  defaultValue?: $ReadOnlyArray<string>,
  multiple: boolean,
  value?: $ReadOnlyArray<string>,
  ...SharedElementProps,
};

type SelectElementProps = {
  defaultValue?: StrOrNum,
  value?: StrOrNum,
  ...SharedElementProps,
};

export component MultipleSelectField(
  allowEmpty: boolean = true,
  field: FieldT<?$ReadOnlyArray<string>>,
  options: MaybeGroupedOptionsT,
  uncontrolled: boolean = false,
  ...passedSelectProps: MultipleSelectElementProps
) {
  const selectProps = {...passedSelectProps, multiple: true};

  if (selectProps.className === undefined) {
    selectProps.className = 'with-button';
  }

  selectProps.disabled = passedSelectProps.disabled || false;
  selectProps.id = 'id-' + field.html_name;
  selectProps.name = field.html_name;

  if (uncontrolled) {
    selectProps.defaultValue = field.value || [];
    selectProps.onChange = undefined;
  } else {
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
}

component SelectField(
  allowEmpty: boolean = true,
  field: FieldT<?StrOrNum>,
  options: MaybeGroupedOptionsT,
  uncontrolled: boolean = false,
  ...passedSelectProps: SelectElementProps
 ) {
  const selectProps = {...passedSelectProps};

  if (selectProps.className === undefined) {
    selectProps.className = 'with-button';
  }

  selectProps.disabled = passedSelectProps.disabled || false;
  selectProps.id = 'id-' + field.html_name;
  selectProps.name = field.html_name;

  if (uncontrolled) {
    selectProps.defaultValue = getSelectValue(field, options, allowEmpty);
    selectProps.onChange = undefined;
  } else {
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
}

export default SelectField;
