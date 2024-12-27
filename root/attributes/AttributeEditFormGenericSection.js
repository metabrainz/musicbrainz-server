/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import FormCsrfToken
  from '../static/scripts/edit/components/FormCsrfToken.js';
import FormRowSelect
  from '../static/scripts/edit/components/FormRowSelect.js';
import FormRowText
  from '../static/scripts/edit/components/FormRowText.js';
import FormRowTextArea
  from '../static/scripts/edit/components/FormRowTextArea.js';

import {type AnyAttributeEditFormT} from './types.js';

component AttributeEditFormGenericSection(
  form: AnyAttributeEditFormT,
  parentSelectOptions: SelectOptionsT,
) {
  const parentOptions = {
    grouped: false,
    options: parentSelectOptions,
  };
  return (
    <>
      <FormCsrfToken form={form} />

      <FormRowSelect
        allowEmpty
        field={form.field.parent_id}
        label="Parent:"
        options={parentOptions}
        uncontrolled
      />

      <FormRowText
        field={form.field.child_order}
        label="Child order:"
        required
        type="number"
        uncontrolled
      />

      <FormRowText
        field={form.field.name}
        label="Name:"
        required
        uncontrolled
      />

      <FormRowTextArea
        cols={80}
        field={form.field.description}
        label="Description:"
        rows={6}
        uncontrolled
      />
    </>
  );
}

export default AttributeEditFormGenericSection;
