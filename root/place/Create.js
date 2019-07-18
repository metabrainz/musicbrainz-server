// @flow
import React from 'react';

import Layout from '../layout';
import {withCatalystContext} from '../context';

import EditForm from './EditForm';

type Props = {
  $c: CatalystContextT,
  entity: PlaceT,
  form: PlaceFormT,
  optionsTypeId: SelectOptionsT
};

const Create = ({$c, form, optionsTypeId}: Props) => {
  console.log('I was Called');
  return (
    <Layout fullWidth title={l('Add Place')}>
      <div id="content">
        <h1>{l("Add Place")}</h1>
        <EditForm
          $c={$c}
          form={form}
          optionsTypeId={optionsTypeId}
        />
      </div>
    </Layout>
  )
};

export default withCatalystContext(Create);