/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import AttributeEditFormWithEntityType
  from './AttributeEditFormWithEntityType.js';
import AttributeEditGenericForm from './AttributeEditGenericForm.js';
import LanguageEditForm from './LanguageEditForm.js';
import MediumFormatEditForm from './MediumFormatEditForm.js';
import ScriptEditForm from './ScriptEditForm.js';
import type {CreateOrEditAttributePropsT} from './types.js';
import WorkAttributeTypeEditForm from './WorkAttributeTypeEditForm.js';

component AttributeEditForm(...props: CreateOrEditAttributePropsT) {
  return match (props) {
    {type: 'Language', const form, ...} => <LanguageEditForm form={form} />,
    {type: 'Script', const form, ...} => <ScriptEditForm form={form} />,
    {type: 'CollectionType' | 'SeriesType', ...} as props => (
      // $FlowIssue[incompatible-type] series vs collection confuses Flow
      <AttributeEditFormWithEntityType
        action={props.action}
        entityTypeSelectOptions={props.entityTypeSelectOptions}
        form={props.form}
        parentSelectOptions={props.parentSelectOptions}
      />
    ),
    {type: 'MediumFormat', ...} as props => (
      <MediumFormatEditForm
        form={props.form}
        parentSelectOptions={props.parentSelectOptions}
      />
    ),
    {type: 'WorkAttributeType', ...} as props => (
      <WorkAttributeTypeEditForm
        form={props.form}
        parentSelectOptions={props.parentSelectOptions}
      />
    ),
    _ as props => (
      <AttributeEditGenericForm
        form={props.form}
        parentSelectOptions={props.parentSelectOptions}
      />
    ),
  };
}

export default AttributeEditForm;
