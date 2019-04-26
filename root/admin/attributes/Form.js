import React from 'react';
import FormRowText from '../../components/FormRowText';

const Form = ({attr, model}) => {
  return (
    <Form action={`/admin/attributes/${model}/edit/${attr.id}`} method="post">
      <FormRowText field={attr.name} label={addColon(l('Name'))} />
      <FormRowText field={attr.iso_code_1} label={addColon(l('ISO 639-1'))} />
      <FormRowText field={attr.iso_code_2b} label={addColon(l('ISO 639-2/B'))} />
      <FormRowText field={attr.iso_code_2t} label={addColon(l('ISO 639-2/T'))} />
      <FormRowText field={attr.iso_code_3} label={addColon(l('ISO 639-3'))} />
      <FormRowText field={attr.frequency} label={addColon(l('Frequency'))} />
      <p>
        {l('Frequency notes:')}
        <ul>
          <li>{l('2: Shown in the commonly used section')}</li>
          <li>{l('1: Shown in the "other" section')}</li>
          <li>{l('0: Hidden, always used for sign languages and languages with no ISO 639-3 code, used by default until requested for ancient languages and languages only in ISO 639-3')}</li>
        </ul>
      </p>
    </Form>
  )
}

export default Form;
