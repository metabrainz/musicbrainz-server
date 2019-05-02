// @flow
import React from 'react';

import Layout from '../../layout';

import Form from './Form';

type LanguageFieldT = {
  entity_type: FieldT<string | null>,
  frequency: FieldT<number>,
  iso_code_1: FieldT<string | null>,
  iso_code_2b: FieldT<string | null>,
  iso_code_2t: FieldT<string | null>,
  iso_code_3: FieldT<string | null>,
  name: FieldT<string>,
};

type ScriptFieldT = {
  entity_type: FieldT<string | null>,
  frequency: FieldT<number>,
  iso_code: FieldT<string | null>,
  iso_number: FieldT<string | null>,
  name: FieldT<string>,
};

type Props = {
  form: FormT<LanguageFieldT> | FormT<ScriptFieldT>,
  id: number,
  model: string,
  parentOptions: $ReadOnlyArray<{label: string, value: number}>,
};

const Edit = ({model, form, id, parentOptions}: Props) => {
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
