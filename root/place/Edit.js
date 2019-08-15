import React from 'react';

import {withCatalystContext} from '../context';
import * as manifest from '../static/manifest';

import PlaceLayout from './PlaceLayout';
import EditForm from './EditForm';

const Edit = ({$c, editEntity, form, optionsTypeID}) => {
  return (
    <PlaceLayout entity={editEntity} fullWidth page="edit" title={l('Edit')}>
      {manifest.js('edit')}
      {manifest.js('place/map.js')}
      {manifest.js('place.js')}
      <EditForm
        editEntity={editEntity}
        form={form}
        formType="edit"
        optionsTypeId={optionsTypeID}
        relationshipEditorHTML={$c.stash.relationship_editor_html}
        uri={$c.req.uri}
      />
    </PlaceLayout>
  );
};

export default withCatalystContext(Edit);
