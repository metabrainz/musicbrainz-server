import React from 'react';

import Layout from '../layout';
import {withCatalystContext} from '../context';
import * as manifest from '../static/manifest';

import EditForm from './EditForm';

const Create = ({
  $c,
  form,
  usedByTracks,
}) => {
  return (
    <>
      <Layout fullWidth title={lp('Add Standalone Recording', 'header')}>
        {manifest.js('edit')}
        <div id="content">
          <h2>{lp('Add Standalone Recording', 'header')}</h2>
          <EditForm
            entityType="recording"
            form={form}
            formType="Add"
            relationshipEditorHTML={$c.stash.relationship_editor_html}
            uri={$c.req.uri}
            usedByTracks={usedByTracks}
          />
        </div>
        <div id="guesscase-options" />
      </Layout>
    </>
  );
};

export default withCatalystContext(Create);
