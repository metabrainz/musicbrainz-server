/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FieldErrors from './FieldErrors';
import FormRow from './FormRow';

type Props = {
  +field: ReadOnlyFieldT<boolean>,
  +help?: React.Node,
  +label: string,
  +onChange?: (event: SyntheticEvent<HTMLInputElement>) => void,
};

const FormRowCheckbox = ({
  field,
  help,
  label,
  onChange,
}: Props): React.Element<typeof FormRow> => (
  <FormRow hasNoLabel>
    <label className="inline">
      <input
        aria-describedby={help ? `field-help-${field.id}` : null}
        defaultChecked={field.value}
        id={'id-' + String(field.html_name)}
        name={field.html_name}
        onChange={onChange}
        type="checkbox"
        value="1"
      />
      {' '}
      {label}
    </label>
    <FieldErrors field={field} />
    {help ? (
      <div className="form-help" id={`field-help-${field.id}`}>
        {help}
      </div>
    ) : null}
  </FormRow>
);

export default FormRowCheckbox;
