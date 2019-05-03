// @flow

import React from 'react';

import FormRowText from '../../components/FormRowText';
import FormSubmit from '../../components/FormSubmit';
import FormRowSelect from '../../components/FormRowSelect';
import FormRow from '../../components/FormRow';
import FormRowCheckbox from '../../components/FormRowCheckbox';
import FieldErrors from '../../components/FieldErrors';
import FormRowTextArea from '../../components/FormRowTextArea';

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

const Form = ({model, form, id, parentOptions}: Props) => {
  switch (model) {
    case 'Language': {
      return (
        <form action={`/admin/attributes/Language/edit/${id}`} method="post">
          <FormRowText field={form.field.name} label={addColonText(l('Name'))} required />
          <FormRowText field={form.field.iso_code_1} label={addColonText(l('ISO 639-1'))} />
          <FormRowText field={form.field.iso_code_2b} label={addColonText(l('ISO 639-2/B'))} />
          <FormRowText field={form.field.iso_code_2t} label={addColonText(l('ISO 639-2/T'))} />
          <FormRowText field={form.field.iso_code_3} label={addColonText(l('ISO 639-3'))} required />
          <FormRowText field={form.field.frequency} label={addColonText(l('Frequency'))} type="number" />
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
        <form action={`/admin/attributes/Language/edit/${id}`} method="post">
          <FormRowText field={form.field.name} label={addColonText(l('Name'))} required />
          <FormRowText field={form.field.iso_code} label={addColonText(l('ISO code'))} required />
          <FormRowText field={form.field.iso_number} label={addColonText(l('ISO number'))} />
          <FormRowText field={form.field.frequency} label={addColonText(l('Frequency'))} />
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
        options: [{value: 1, label: 'area'}, {value: 2, label: 'artist'}, {value: 3, label: 'event'}, {value: 4, label: 'instrument'}, {value: 5, label: 'label'}, {value: 6, label: 'place'}, {value: 7, label: 'recording'}, {value: 8, label: 'release'}, {value: 9, label: 'release_group'}, {value: 10, label: 'series'}, {value: 11, label: 'work'}],
      };
      return (
        <form action={`/admin/attributes/${model}/edit/${id}`} method="post">
          {(model === 'CollectionType' || model === 'SeriesType') ? <FormRowSelect field={form.field.entity_type} frozen label={addColonText(l('Entity type'))} options={entityOptions} allowEmpty={true}/> : null}
          <FormRowSelect field={form.field.parent_id} label={addColonText(l('Parent'))} options={{options: parentOptions}} allowEmpty={true} />
          <FormRow>
            <FormRowText field={form.field.child_order} label={addColonText(l('Child order'))} size={5} />
            <FieldErrors field={form.field.child_order} />
          </FormRow>
          <FormRowText field={form.field.name} label={addColonText(l('Name'))} required />
          <FormRow>
            <FormRowTextArea field={form.field.description} label={addColonText(l('Description'))} />
            <FieldErrors field={form.field.description} />
          </FormRow>
          {(model === 'MediumFormat') ?
            <>
              <FormRow>
                <FormRowText field={form.field.year} label={addColonText(l('Year'))} size={5} />
                <FieldErrors field={form.field.year} />
              </FormRow>
              <FormRowCheckbox field={form.field.has_discids} label={addColonText(l('This format can have disc IDs'))} />
            </> : null}
          {(model === 'WorkAttributeType') ? <FormRowCheckbox field={form.field.free_text} label={addColonText(l('This is a free text work attribute'))} /> : null}
          <div className="row no-label">
            <FormSubmit label={l('Save')} />
          </div>
        </form>
      );
    }
  }
};

export default Form;
