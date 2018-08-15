/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import FieldErrors from './FieldErrors';
import FormRow from './FormRow';

type Props = {|
  +field: FieldT<boolean>,
  +label: string,
|};

const FormRowCheckbox = ({field, label}: Props) => (
  <FormRow hasNoLabel>
    <label className="inline">
      <input checked={field.value} name={field.html_name} type="checkbox" />
      {label}
    </label>
    <FieldErrors field={field} />
  </FormRow>
);

export default FormRowCheckbox;
