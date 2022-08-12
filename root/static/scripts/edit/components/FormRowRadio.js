/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {unwrapNl} from '../../common/i18n.js';

import FormRow from './FormRow.js';
import FieldErrors from './FieldErrors.js';
import FormLabel from './FormLabel.js';

type RadioOptionsT = $ReadOnlyArray<{
  +label: string | (() => string | React$MixedElement),
  +value: number | string,
}>;

type Props = {
  +field: ReadOnlyFieldT<string>,
  +label: string,
  +options: RadioOptionsT,
  +required?: boolean,
};

const FormRowRadio = ({
  field,
  label,
  options,
  required = false,
}: Props): React.Element<typeof FormRow> => (
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
            {unwrapNl<string | React$MixedElement>(option.label)}
          </label>
          {index < options.length - 1 ? <br /> : null}
        </React.Fragment>
      ))}
    </div>
    <FieldErrors field={field} />
  </FormRow>
);

export default FormRowRadio;
