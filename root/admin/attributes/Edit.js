import React from 'react';

import Layout from '../../layout';

import Form from './Form';

const Edit = ({model, form, id, parentOptions}) => {
  return (
    <Layout fullWidth title={l('Edit Attribute')}>
      <div id="content">
        <h1>{l('Edit Attribute')}</h1>
        <Form
          form={form}
          id={id}
          model={model}
          parentOptions={parentOptions}
        />
      </div>
    </Layout>
  );
};

export default Edit;
