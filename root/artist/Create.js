import React from 'react';

import Layout from '../layout';
import * as manifest from '../static/manifest';
import {withCatalystContext} from '../context';

import EditForm from './EditForm';

const Create = ({
  $c,
  form,
  optionsGenderId,
  optionsTypeId,
}) => {
  return (
    <Layout fullWidth title={l('Add Artist')}>
      {manifest.js('edit')}
      <div id="content">
        <h1>{l('Add Artist')}</h1>
        <EditForm
          entityType="artist"
          form={form}
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

export default withCatalystContext(Create);
