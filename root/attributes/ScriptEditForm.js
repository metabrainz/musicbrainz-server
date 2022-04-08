/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import FormCsrfToken
  from '../static/scripts/edit/components/FormCsrfToken.js';
import FormRow from '../static/scripts/edit/components/FormRow.js';
import FormRowSelect
  from '../static/scripts/edit/components/FormRowSelect.js';
import FormRowText from '../static/scripts/edit/components/FormRowText.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';

import type {ScriptEditFormT} from './types.js';

const frequencyOptions = {
  grouped: false,
  options: [
    {label: 'Hidden', value: 1},
    {label: 'Other (Uncommon)', value: 2},
    {label: 'Other', value: 3},
    {label: 'Frequently used', value: 4},
  ],
};

component ScriptEditForm(form: ScriptEditFormT) {
  return (
    <form method="post">
      <FormCsrfToken form={form} />

      <FormRowText
        field={form.field.name}
        label="Name:"
        required
        uncontrolled
      />

      <FormRowText
        field={form.field.iso_code}
        label="ISO code:"
        required
        uncontrolled
      />

      <FormRowText
        field={form.field.iso_number}
        label="ISO number:"
        required
        uncontrolled
      />

      <FormRowSelect
        field={form.field.frequency}
        label="Frequency:"
        options={frequencyOptions}
        uncontrolled
      />

      <p>
        {'Frequency notes:'}
        <ul>
          <li>
            {l_admin(`Both Other and Uncommon are shown in the "other"
                      section, but Uncommon should be used for scripts in
                      Unicode which are unlikely to be used.`)}
          </li>
          <li>{'Hidden should be used for scripts not in Unicode.'}</li>
        </ul>
      </p>


      <FormRow hasNoLabel>
        <FormSubmit label="Save" />
      </FormRow>
    </form>
  );
}

export default ScriptEditForm;
