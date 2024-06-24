/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {unwrapNl} from '../../common/i18n.js';

import FieldErrors from './FieldErrors.js';
import FormLabel from './FormLabel.js';
import FormRow from './FormRow.js';

type RadioOptionsT = $ReadOnlyArray<{
  +label: string | (() => Expand2ReactOutput),
  +value: number | string,
}>;

component FormRowRadio(
  field: FieldT<string>,
  label: React$Node,
  options: RadioOptionsT,
  required: boolean = false,
) {
  return (
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
              {unwrapNl<Expand2ReactOutput>(option.label)}
            </label>
            {index < options.length - 1 ? <br /> : null}
          </React.Fragment>
        ))}
      </div>
      <FieldErrors field={field} />
    </FormRow>
  );
}

export default FormRowRadio;
