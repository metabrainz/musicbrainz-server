import React from 'react';

import Layout from '../layout';
import * as manifest from '../static/manifest';
import {withCatalystContext} from '../context';

import EditForm from './EditForm';


const Create = ({$c, form, entityType, optionsTypeId, optionsOrderingTypeId}) => {
  return (
    <Layout fullWidth title={l('Add Series')}>
      <div id="content">
        <h1>{l('Add Series')}</h1>
        {manifest.js('edit')}
        <EditForm
          entityType={entityType}
          form={form}
          optionsOrderingTypeId={optionsOrderingTypeId}
          optionsTypeId={optionsTypeId}
          uri={$c.req.uri}
          relationshipEditorHTML={$c.stash.relationship_editor_html}
        />
        {manifest.js('series')}
      </div>
    </Layout>
  );
};

export default withCatalystContext(Create);
