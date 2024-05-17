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
  switch (props.type) {
    case 'Language':
      return <LanguageEditForm form={props.form} />;
    case 'Script':
      return <ScriptEditForm form={props.form} />;
    case 'CollectionType':
    case 'SeriesType':
      return (
        // $FlowIssue[incompatible-type] series vs collection confuses Flow
        <AttributeEditFormWithEntityType
          action={props.action}
          entityTypeSelectOptions={props.entityTypeSelectOptions}
          form={props.form}
          parentSelectOptions={props.parentSelectOptions}
        />
      );
    case 'MediumFormat':
      return (
        <MediumFormatEditForm
          form={props.form}
          parentSelectOptions={props.parentSelectOptions}
        />
      );
    case 'WorkAttributeType':
      return (
        <WorkAttributeTypeEditForm
          form={props.form}
          parentSelectOptions={props.parentSelectOptions}
        />
      );
    default:
      return (
        <AttributeEditGenericForm
          form={props.form}
          parentSelectOptions={props.parentSelectOptions}
        />
      );
  }
}

export default AttributeEditForm;
