/*
 * @flow
 * Copyright (C) 2017 MetaBrainz Foundation
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

type Props = {|
  +allowEmpty?: boolean,
  +disabled?: boolean,
  +field: ReadOnlyFieldT<?StrOrNum>,
  +multiple?: boolean,
  +onChange?: (event: SyntheticEvent<HTMLSelectElement>) => void,
  +options: MaybeGroupedOptionsT,
  +required?: boolean,
|};

const SelectField = ({
  allowEmpty = true,
  disabled = false,
  field,
  multiple = false,
  onChange,
  options,
  required,
}: Props) => (
  <select
    className="with-button"
    disabled={disabled}
    id={'id-' + field.html_name}
    multiple={multiple}
    name={field.html_name}
    onChange={onChange}
    required={required}
    value={getSelectValue(field, options, allowEmpty)}
  >
    {allowEmpty
      ? <option value="">{'\xA0'}</option>
      : null}
    {options.grouped
      ? options.options.map(buildOptGroup)
      : options.options.map(buildOption)}
  </select>
);

export default SelectField;
