/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FormRow from './FormRow';
import FieldErrors from './FieldErrors';
import FormLabel from './FormLabel';
import HiddenField from './HiddenField';
import SelectField from './SelectField';

type Props = {|
  // `allowEmpty` prepends an empty default option to the list.
  +allowEmpty?: boolean,
  +field: ReadOnlyFieldT<number | string>,
  +frozen?: boolean,
  +helpers?: React.Node,
  +label: string,
  +onChange?: (event: SyntheticEvent<HTMLSelectElement>) => void,
  +options: MaybeGroupedOptionsT,
  /*
   * `required` makes the field text bold to indicate a selection is required.
   * Only useful when `allowEmpty` is true.
   */
  +required?: boolean,
|};

const FormRowSelect = ({
  allowEmpty = false,
  frozen = false,
  field,
  helpers,
  label,
  onChange,
  options,
  required = false,
}: Props) => {
  if (!allowEmpty) {
    // If the field can't be unset, there's nothing required from the user.
    required = false;
  }
  return (
    <FormRow>
      <FormLabel forField={field} label={label} required={required} />
      <SelectField
        allowEmpty={allowEmpty}
        disabled={frozen}
        field={field}
        onChange={onChange}
        options={options}
        required={required}
      />
      {frozen ? <HiddenField field={field} /> : null}
      {helpers}
      <FieldErrors field={field} />
    </FormRow>
  );
};

export default FormRowSelect;
