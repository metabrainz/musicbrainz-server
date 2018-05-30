/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import FormRow from './FormRow';
import FieldErrors from './FieldErrors';
import FormLabel from './FormLabel';
import Frag from './Frag';

type Props = {|
  +field: FieldT<string>,
  +label: string,
  +options: SelectOptionsT,
  +required?: boolean,
|};

const FormRowRadio = ({
  field,
  label,
  onChange,
  options,
  required = false,
}: Props) => (
  <FormRow>
    <FormLabel label={label} required={required} />
    <div className="no-label">
      {options.map((option, index) => (
        <Frag key={option.value}>
          <label className="inline">
            <input
              defaultChecked={field.value === option.value}
              name={field.html_name}
              type="radio"
              value={option.value}
            />
            {' '}
            {option.label}
          </label>
          {index < options.length - 1 ? <br /> : null}
        </Frag>
      ))}
    </div>
    <FieldErrors field={field} />
  </FormRow>
);

export default FormRowRadio;
