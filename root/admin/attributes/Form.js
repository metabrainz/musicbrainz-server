// @flow

import React from 'react';

import FormRowText from '../../components/FormRowText';
import FormSubmit from '../../components/FormSubmit';
import FormRowSelect from '../../components/FormRowSelect';
import FormRow from '../../components/FormRow';
import FormRowCheckbox from '../../components/FormRowCheckbox';

type LanguageFieldT = {
  entity_type: FieldT<string | null>,
  frequency: FieldT<number>,
  id: FieldT<number>,
  iso_code_1: FieldT<string | null>,
  iso_code_2b: FieldT<string | null>,
  iso_code_2t: FieldT<string | null>,
  iso_code_3: FieldT<string | null>,
  name: FieldT<string>,
};

type ScriptFieldT = {
  entity_type: FieldT<string | null>,
  frequency: FieldT<number>,
  id: FieldT<number>,
  iso_code: FieldT<string | null>,
  iso_number: FieldT<string | null>,
  name: FieldT<string>,
};

type Props = {
  form: FormT<LanguageFieldT> | FormT<ScriptFieldT>,
  model: string,
};

const Form = ({model, form}: Props) => {
  switch (model) {
    case 'Language': {
      return (
        <form action={`/admin/attributes/Language/edit/${form.field.id}`} method="post">
          <FormRowText field={form.field.name} label={addColon(l('Name'))} />
          <FormRowText field={form.field.iso_code_1} label={addColon(l('ISO 639-1'))} />
          <FormRowText field={form.field.iso_code_2b} label={addColon(l('ISO 639-2/B'))} />
          <FormRowText field={form.field.iso_code_2t} label={addColon(l('ISO 639-2/T'))} />
          <FormRowText field={form.field.iso_code_3} label={addColon(l('ISO 639-3'))} />
          <FormRowText field={form.field.frequency} label={addColon(l('Frequency'))} type="number" />
          <p>
            {l('Frequency notes:')}
            <ul>
              <li>{l('2: Shown in the commonly used section')}</li>
              <li>{l('1: Shown in the "other" section')}</li>
              <li>{l('0: Hidden, always used for sign languages and languages with no ISO 639-3 code, used by default until requested for ancient languages and languages only in ISO 639-3')}</li>
            </ul>
          </p>
          <div className="row no-label">
            <FormSubmit label={l('Save')} />
          </div>
        </form>
      );
    }
    case 'Script': {
      return (
        <form action={`/admin/attributes/Language/edit/${form.field.id}`} method="post">
          <FormRowText field={form.field.name} label={addColon(l('Name'))} />
          <FormRowText field={form.field.iso_code} label={addColon(l('ISO CODE'))} />
          <FormRowText field={form.field.iso_number} label={addColon(l('ISO number'))} />
          <FormRowText field={form.field.frequency} label={addColon(l('Frequency'))} />
          <p>
            {l('Frequency notes:')}
            <ul>
              <li>{l('4: Shown in the commonly used section')}</li>
              <li>{l('3: Shown in the "other" section, used for scripts which are likely to get some usage')}</li>
              <li>{l('2: Shown in the "other" section, used for scripts in Unicode which are unlikely to be used')}</li>
              <li>{l('1: Hidden, used for scripts not in Unicode')}</li>
            </ul>
          </p>
          <div className="row no-label">
            <FormSubmit label={l('Save')} />
          </div>
        </form>
      );
    }
    default: {
      const entityOptions = {
        options: ['area', 'artist', 'event', 'instrument', 'label', 'place', 'recording', 'release', 'release_group', 'series', 'work'],
      };
      const parentOptions = {
        options: ['1', '2', '3']
      };
      return (
        <form action={`/admin/attributes/${model}/edit/${form.field.id}`} method="post">
          {(model === 'CollectionType' || model === 'SeriesType') ? <FormRowSelect field={form.field.entity_type} frozen={true} label={addColon(l('Entity type'))} options={entityOptions} /> : null}
          <FormRowSelect field={form.field.parent_id} label={addColon(l('Parent'))} options={parentOptions} />
          <FormRow>
            <FormRowText field={form.field.child_order} label={addColon(l('Child order'))} size={5} />
          </FormRow>
          <FormRowText field={form.field.name} label={addColon(l('Name'))} required={true} />
          {(model === 'MediumFormat') ? <FormRowCheckbox field={form.field.has_discids} label={addColon(l('This format can have disc IDs'))} /> : null}
          {(model === 'WorkAttributeType') ? <FormRowCheckbox field={form.field.free_text} label={addColon(l('This is a free text work attribute'))} /> : null}
          <div className="row no-label">
            <FormSubmit label={l('Save')} />
          </div>
        </form>
      );
    }
  }
};

export default Form;
