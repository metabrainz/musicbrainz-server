/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import FormRow from '../static/scripts/edit/components/FormRow.js';
import FormRowCheckbox
  from '../static/scripts/edit/components/FormRowCheckbox.js';
import FormRowText
  from '../static/scripts/edit/components/FormRowText.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';

import AttributeEditFormGenericSection
  from './AttributeEditFormGenericSection.js';
import {type MediumFormatEditFormT} from './types.js';

component MediumFormatEditForm(
  form: MediumFormatEditFormT,
  parentSelectOptions: SelectOptionsT,
) {
  return (
    <form method="post">
      <AttributeEditFormGenericSection
        form={form}
        parentSelectOptions={parentSelectOptions}
      />

      <FormRowText
        field={form.field.year}
        label="Year:"
        size={5}
        uncontrolled
      />

      <FormRowCheckbox
        field={form.field.has_discids}
        label="This format can have disc IDs"
        uncontrolled
      />

      <FormRow hasNoLabel>
        <FormSubmit label="Save" />
      </FormRow>
    </form>
  );
}

export default MediumFormatEditForm;
