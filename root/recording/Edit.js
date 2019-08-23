import React from 'react';

import {withCatalystContext} from '../context';
import * as manifest from '../static/manifest';

import EditForm from './EditForm';
import RecordingLayout from './RecordingLayout';

const Create = ({
  $c,
  editEntity,
  form,
  usedByTracks,
}) => {
  return (
    <>
      <RecordingLayout entity={editEntity} fullWidth title={lp('Add Standalone Recording', 'header')}>
        {manifest.js('edit')}
        <div id="content">
          <h2>{lp('Add Standalone Recording', 'header')}</h2>
          <EditForm
            entityType="recording"
            form={form}
            formType="Edit"
            relationshipEditorHTML={$c.stash.relationship_editor_html}
            uri={$c.req.uri}
            usedByTracks={usedByTracks}
          />
        </div>
        <div id="guesscase-options" />
      </RecordingLayout>
    </>
  );
};

export default withCatalystContext(Create);
