import React from 'react';

import Layout from '../layout';
import {withCatalystContext} from '../context';
import * as manifest from '../static/manifest';

import EditForm from './EditForm';

const Create = ({$c, form, optionsTypeId}) => {
  return (
    <Layout fullWidth title={lp('Add Work', 'header')}>
      {manifest.js('edit')}
      <h1>{lp('Add Work', 'header')}</h1>
      <EditForm
        entityType="Work"
        form={form}
        optionsTypeId={optionsTypeId}
        relationshipEditorHTML={$c.stash.relationship_editor_html}
        uri={$c.req.uri}
      />
      <div id="guesscase-options" />
      {manifest.js('work')}
    </Layout>
  );
};

export default withCatalystContext(Create);
