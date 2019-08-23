import React from 'react';

import {withCatalystContext} from '../context';
import * as manifest from '../static/manifest';

import EventLayout from './EventLayout';
import EditForm from './EditForm';

const Edit = ({
  $c,
  editEntity,
  form,
  optionsTypeId,
}) => {
  return (
    <>
      <EventLayout entity={editEntity} fullWidth>
        {manifest.js('edit')}
        <div id="content">
          <h1>{l('Add Event')}</h1>
          <EditForm
            editEntity={editEntity}
            entityType="event"
            form={form}
            formType="edit"
            optionsTypeId={optionsTypeId}
            relationshipEditorHTML={$c.stash.relationship_editor_html}
            uri={$c.req.uri}
          />
        </div>
        <div id="guesscase-options" />
      </EventLayout>
    </>
  );
};

export default withCatalystContext(Edit);
