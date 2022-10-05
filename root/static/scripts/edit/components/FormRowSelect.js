/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import SelectField from '../../common/components/SelectField.js';

import FieldErrors from './FieldErrors.js';
import FormLabel from './FormLabel.js';
import FormRow from './FormRow.js';
import HiddenField from './HiddenField.js';

type Props = {
  // `allowEmpty` prepends an empty default option to the list.
  +allowEmpty?: boolean,
  +disabled?: boolean,
  +field: ReadOnlyFieldT<number | string>,
  +frozen?: boolean,
  +hasHtmlErrors?: boolean,
  +helpers?: React.Node,
  +label: string,
  +onChange?: (event: SyntheticEvent<HTMLSelectElement>) => void,
  +options: MaybeGroupedOptionsT,
  /*
   * `required` makes the field text bold to indicate a selection is required.
   * Only useful when `allowEmpty` is true.
   */
  +required?: boolean,
  +uncontrolled?: boolean,
};

const FormRowSelect = ({
  allowEmpty = false,
  disabled = false,
  frozen = false,
  field,
  hasHtmlErrors,
  helpers,
  label,
  onChange,
  options,
  required: passedRequired = false,
  uncontrolled = false,
}: Props): React.Element<typeof FormRow> => {
  let required = passedRequired;
  if (!allowEmpty) {
    // If the field can't be unset, there's nothing required from the user.
    required = false;
  }
  return (
    <FormRow>
      <FormLabel forField={field} label={label} required={required} />
      <SelectField
        allowEmpty={allowEmpty}
        disabled={disabled || frozen}
        field={field}
        onChange={onChange}
        options={options}
        required={required}
        uncontrolled={uncontrolled}
      />
      {frozen ? <HiddenField field={field} /> : null}
      {helpers}
      <FieldErrors field={field} hasHtmlErrors={hasHtmlErrors} />
    </FormRow>
  );
};

export default FormRowSelect;
