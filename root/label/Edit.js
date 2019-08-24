import React from 'react';

import * as manifest from '../static/manifest';
import {withCatalystContext} from '../context';

import LabelLayout from './LabelLayout';
import EditForm from './EditForm';

const Edit = ({
  $c,
  editEntity,
  form,
  optionsTypeId,
}) => {
  return (
    <LabelLayout entity={editEntity} fullWidth label={l('Add Label')}>
      <div id="content">
        {manifest.js('edit')}
        <EditForm
          editEntity={editEntity}
          entityType="label"
          form={form}
          formType="edit"
          optionsTypeId={optionsTypeId}
          relationshipEditorHTML={$c.stash.relationship_editor_html}
          uri={$c.req.uri}
        />
      </div>
    </LabelLayout>
  );
};

export default withCatalystContext(Edit);
