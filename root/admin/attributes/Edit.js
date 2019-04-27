import React from 'react';

import Layout from '../../layout';

import Form from './Form';

const Edit = ({model, form, id}) => {
  console.log("This is from React Console.log\n", form)
  return (
    <Layout fullWidth title={l('Edit Attribute')}>
      <div id="content">
        <h1>{l('Edit Attribute')}</h1>
        <Form form={form} model={model} id={id}/>
      </div>
    </Layout>
  );
};

export default Edit;
