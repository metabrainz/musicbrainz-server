/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import FormRow from '../static/scripts/edit/components/FormRow.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';

import AttributeEditFormGenericSection
  from './AttributeEditFormGenericSection.js';
import type {AttributeEditGenericFormT} from './types.js';

component AttributeEditForm(
  form: AttributeEditGenericFormT,
  parentSelectOptions: SelectOptionsT,
) {
  return (
    <form method="post">
      <AttributeEditFormGenericSection
        form={form}
        parentSelectOptions={parentSelectOptions}
      />

      <FormRow hasNoLabel>
        <FormSubmit label="Save" />
      </FormRow>
    </form>
  );
}

export default AttributeEditForm;
