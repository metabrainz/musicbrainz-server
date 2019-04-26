import React from 'react';
import Layout from '../../layout';
import Form from './Form';

const Edit = ({attr, model}) => {
  return (
    <Layout fullWidth title={l("Edit Attribute")}>
      <div id="content">
        <h1>{l("Edit Attribute")}</h1>
        <Form attribute={attr} model={model} />
      </div>
    </Layout>
  )
};

export default Edit;
