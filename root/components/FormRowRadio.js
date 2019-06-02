/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import {unwrapNl} from '../static/scripts/common/i18n';

import FormRow from './FormRow';
import FieldErrors from './FieldErrors';
import FormLabel from './FormLabel';

type RadioOptionsT = $ReadOnlyArray<{|
  +label: string | (() => string | AnyReactElem),
  +value: number | string,
|}>;

type Props = {|
  +field: ReadOnlyFieldT<string>,
  +label: string,
  +options: RadioOptionsT,
  +required?: boolean,
|};

const FormRowRadio = ({
  field,
  label,
  options,
  required = false,
}: Props) => (
  <FormRow>
    <FormLabel label={label} required={required} />
    <div className="no-label">
      {options.map((option, index) => (
        <React.Fragment key={option.value}>
          <label className="inline">
            <input
              defaultChecked={field.value === option.value}
              name={field.html_name}
              required={required}
              type="radio"
              value={option.value}
            />
            {' '}
            {unwrapNl(option.label)}
          </label>
          {index < options.length - 1 ? <br /> : null}
        </React.Fragment>
      ))}
    </div>
    <FieldErrors field={field} />
  </FormRow>
);

export default FormRowRadio;
