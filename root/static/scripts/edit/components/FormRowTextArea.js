/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import FieldErrors from './FieldErrors.js';
import FormLabel from './FormLabel.js';
import FormRow from './FormRow.js';

component FormRowTextArea(
  cols: number = 80,
  field: FieldT<string>,
  label: React.Node,
  required: boolean = false,
  rows: number = 5,
) {
  return (
    <FormRow>
      <FormLabel forField={field} label={label} required={required} />
      <textarea
        cols={cols}
        defaultValue={field.value}
        id={'id-' + field.html_name}
        name={field.html_name}
        required={required}
        rows={rows}
      />
      <FieldErrors field={field} />
    </FormRow>
  );
}

export default FormRowTextArea;
