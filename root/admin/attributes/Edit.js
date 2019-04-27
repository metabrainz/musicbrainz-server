import React from 'react';

import Layout from '../../layout';

import Form from './Form';

const Edit = ({model, form}) => {
  console.log("This is from React Console.log\n", form)
  return (
    <Layout fullWidth title={l('Edit Attribute')}>
      <div id="content">
        <h1>{l('Edit Attribute')}</h1>
        <Form form={form} model={model} />
      </div>
    </Layout>
  );
};

export default Edit;
