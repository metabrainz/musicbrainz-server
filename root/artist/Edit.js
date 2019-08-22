import React from 'react';

import * as manifest from '../static/manifest';
import {withCatalystContext} from '../context';

import EditForm from './EditForm';
import Layout from './ArtistLayout';

const Edit = ({
  $c,
  editEntity,
  form,
  optionsGenderId,
  optionsTypeId,
}) => {
  return (
    <Layout entity={editEntity} fullWidth page="edit" title={l('Edit Artist')}>
      {manifest.js('edit')}
      <div id="content">
        <EditForm
          editEntity={editEntity}
          entityType="artist"
          form={form}
          formType="edit"
          optionsGenderId={optionsGenderId}
          optionsTypeId={optionsTypeId}
          relationshipEditorHTML={$c.stash.relationship_editor_html}
          uri={$c.req.uri}
        />
      </div>
      <div id="guesscase-options" />
    </Layout>
  );
};

export default withCatalystContext(Edit);
