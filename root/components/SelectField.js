/*
 * @flow
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import getSelectValue from '../utility/getSelectValue';

const buildOption = (option: SelectOptionT, index: number) => (
  <option key={index} value={option.value}>
    {option.label}
  </option>
);

const buildOptGroup = (optgroup, index) => (
  <optgroup key={index} label={optgroup.optgroup}>
    {optgroup.options.map(buildOption)}
  </optgroup>
);

type Props = {|
  +allowEmpty?: boolean,
  +field: FieldT<number> | FieldT<string>,
  +name: string,
  +onChange?: (event: SyntheticEvent<HTMLSelectElement>) => void,
  +options: MaybeGroupedOptionsT,
|};

const SelectField = ({
  allowEmpty = true,
  field,
  name,
  onChange,
  options,
}: Props) => (
  <select
    className="with-button"
    name={name}
    onChange={onChange}
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
