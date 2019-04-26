import React from 'react';
import Layout from '../../layout';
import Form from './Form';

const Edit = ({model, form}) => {
  console.log("This is a React Console.log", model, "This next stuff is from form" ,form)
  return (
    <Layout fullWidth title={l("Edit Attribute")}>
      <div id="content">
        <h1>{l("Edit Attribute")}</h1>
        <Form form={form} model={model} />
      </div>
    </Layout>
  )
};

export default Edit;
