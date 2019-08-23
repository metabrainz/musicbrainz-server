import React from 'react';

import Layout from '../layout';
import * as manifest from '../static/manifest';
import {withCatalystContext} from '../context';

import EditForm from './EditForm';

const Create = ({
  $c,
  form,
  optionsTypeId,
}) => {
  return (
    <Layout fullWidth label={l('Add Label')}>
      <div id="content">
        {manifest.js('edit')}
        <h1>{l('Add Label')}</h1>
        <EditForm
          entityType="label"
          form={form}
          optionsTypeId={optionsTypeId}
          uri={$c.req.uri}
        />
      </div>
    </Layout>
  );
};

export default withCatalystContext(Create);
