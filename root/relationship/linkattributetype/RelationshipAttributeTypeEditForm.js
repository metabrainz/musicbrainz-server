/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import FormRow from '../../static/scripts/edit/components/FormRow.js';
import FormRowCheckbox
  from '../../static/scripts/edit/components/FormRowCheckbox.js';
import FormRowSelect
  from '../../static/scripts/edit/components/FormRowSelect.js';
import FormRowText
  from '../../static/scripts/edit/components/FormRowText.js';
import FormRowTextArea
  from '../../static/scripts/edit/components/FormRowTextArea.js';
import FormSubmit from '../../static/scripts/edit/components/FormSubmit.js';

import {type RelationshipAttributeTypeEditFormT} from './types.js';

component RelationshipAttributeTypeEditForm(
  disableCreditable?: boolean = false,
  disableFreeText?: boolean = false,
  form: RelationshipAttributeTypeEditFormT,
  parentSelectOptions: SelectOptionsT,
) {
  const parentOptions = {
    grouped: false,
    options: parentSelectOptions,
  };
  return (
    <form method="post">
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
      />

      <FormRowCheckbox
        disabled={disableCreditable}
        field={form.field.creditable}
        label="This attribute supports free text credits"
        uncontrolled
      />

      <FormRowCheckbox
        disabled={disableFreeText}
        field={form.field.free_text}
        label="This attribute uses free text values"
        uncontrolled
      />

      <FormRow hasNoLabel>
        <FormSubmit label="Save" />
      </FormRow>
    </form>
  );
}

export default RelationshipAttributeTypeEditForm;
