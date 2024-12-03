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

import type {LanguageEditFormT} from './types.js';

const frequencyOptions = {
  grouped: false,
  options: [
    {label: 'Hidden', value: 0},
    {label: 'Other', value: 1},
    {label: 'Frequently used', value: 2},
  ],
};

component LanguageEditForm(form: LanguageEditFormT) {
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
        field={form.field.iso_code_1}
        label="ISO 639-1:"
        uncontrolled
      />

      <FormRowText
        field={form.field.iso_code_2b}
        label="ISO 639-2/B:"
        uncontrolled
      />

      <FormRowText
        field={form.field.iso_code_2t}
        label="ISO 639-2/T:"
        uncontrolled
      />

      <FormRowText
        field={form.field.iso_code_3}
        label="ISO 639-3:"
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
            {l_admin(`Hidden should be used for sign languages
                      and languages with no ISO 639-3 code.`)}
          </li>
          <li>
            {l_admin(`Hidden is used by default for ancient languages
                      and languages only in ISO 639-3
                      (until requested by a user).`)}
          </li>
        </ul>
      </p>

      <FormRow hasNoLabel>
        <FormSubmit label="Save" />
      </FormRow>
    </form>
  );
}

export default LanguageEditForm;
