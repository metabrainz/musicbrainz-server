import React from 'react';

import {withCatalystContext} from '../context';
import * as manifest from '../static/manifest';

import ReleaseGroupLayout from './ReleaseGroupLayout';
import EditForm from './EditForm';

const Edit = ({
  $c,
  editEntity,
  optionsPrimaryTypeId,
  optionsSecondaryTypeIds,
  form,
}) => {
  return (
    <ReleaseGroupLayout entity={editEntity} fullWidth page="edit" title={l('Edit')}>
      {manifest.js('edit')}
      <EditForm
        editEntity={editEntity}
        entityType="release_group"
        form={form}
        formType="edit"
        optionsPrimaryTypeId={optionsPrimaryTypeId}
        optionsSecondaryTypeIds={optionsSecondaryTypeIds}
        relationshipEditorHTML={$c.stash.relationship_editor_html}
        uri={$c.req.uri}
      />
    </ReleaseGroupLayout>
  );
};

export default withCatalystContext(Edit);
