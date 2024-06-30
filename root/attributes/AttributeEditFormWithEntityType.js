/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {ENTITY_NAMES} from '../static/scripts/common/constants.js';
import FormRow from '../static/scripts/edit/components/FormRow.js';
import FormRowSelect
  from '../static/scripts/edit/components/FormRowSelect.js';
import FormSubmit from '../static/scripts/edit/components/FormSubmit.js';

import AttributeEditFormGenericSection
  from './AttributeEditFormGenericSection.js';
import {type AttributeEditFormWithEntityTypeT} from './types.js';

type Props =
| $ReadOnly<{
  +action: 'add' | 'edit',
  +entityTypeSelectOptions: {
    [entityType: CollectableEntityTypeT]: CollectableEntityTypeT,
  },
  +form: AttributeEditFormWithEntityTypeT,
  +parentSelectOptions: SelectOptionsT,
  +type: 'CollectionType',
}>
| $ReadOnly<{
  +action: 'add' | 'edit',
  +entityTypeSelectOptions: {
    [entityType: SeriesEntityTypeT]: SeriesEntityTypeT,
  },
  +form: AttributeEditFormWithEntityTypeT,
  +parentSelectOptions: SelectOptionsT,
  +type: 'SeriesType',
}>;

component AttributeEditFormWithEntityType(...{
  action,
  entityTypeSelectOptions,
  form,
  parentSelectOptions,
}: Props) {
  const entityTypeOptions = {
    grouped: false,
    options: Object.keys(entityTypeSelectOptions).sort().map(type => {
      return {label: ENTITY_NAMES[type], value: type};
    }),
  };
  return (
    <form method="post">
      <FormRowSelect
        allowEmpty
        field={form.field.item_entity_type}
        frozen={action === 'edit'}
        label="Entity type:"
        options={entityTypeOptions}
        required
        uncontrolled
      />

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

export default AttributeEditFormWithEntityType;
