import React from 'react';

import {withCatalystContext} from '../context';

import PlaceLayout from './PlaceLayout';
import EditForm from './EditForm';

const Edit = ({$c, editEntity, form, optionsTypeID}) => {
  return (
    <PlaceLayout entity={editEntity} fullWidth page="edit" title={l('Edit')}>
      <EditForm
        editEntity={editEntity}
        form={form}
        optionsTypeId={optionsTypeID}
        relationshipEditorHTML={$c.stash.relationship_editor_html}
        uri={$c.req.uri}
      />
    </PlaceLayout>
  );
};

export default withCatalystContext(Edit);
