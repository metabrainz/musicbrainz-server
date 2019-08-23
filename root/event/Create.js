import React from 'react';

import Layout from '../layout';
import {withCatalystContext} from '../context';
import * as manifest from '../static/manifest';

import EditForm from './EditForm';

const Create = ({
  $c,
  form,
  optionsTypeId,
}) => {
  return (
    <>
      <Layout fullWidth title={l('Add Event')}>
        {manifest.js('edit')}
        <div id="content">
          <h1>{l('Add Event')}</h1>
          <EditForm
            entityType="event"
            form={form}
            formType="add"
            optionsTypeId={optionsTypeId}
            relationshipEditorHTML={$c.stash.relationship_editor_html}
            uri={$c.req.uri}
          />
        </div>
        <div id="guesscase-options" />
      </Layout>
    </>
  );
};

export default withCatalystContext(Create);
