// @flow
import React from 'react';

import * as manifest from '../static/manifest';
import FormRowNameWithGuesscase from '../components/FormRowNameWithGuesscase';
import FormRowTextLong from '../components/FormRowTextLong';
import FormRowSelect from '../components/FormRowSelect';
import DuplicateEntitiesSection from '../components/DuplicateEntitiesSection';
import FormRow from '../components/FormRow';
import SearchIcon from '../static/scripts/common/components/SearchIcon';
import HiddenField from '../components/HiddenField';
import FieldErrors from '../components/FieldErrors';

type Props = {
  $c: CatalystContextT,
  form: PlaceFormT,
  optionsTypeId: SelectOptionsT
};

const EditForm = ({$c, form, optionsTypeId}: Props) => {
  console.log(form);
  const typeOptions = {
    grouped: false,
    options: optionsTypeId,
  };
  return (
    <>
      {manifest.js('edit')}
      <p>
        {exp.l('For more information, check the {doc_doc|documentation}.', {doc_doc: '/doc/Place'})}
      </p>
      <form action={$c.req.uri} method="post" className="edit-place">
        <div className="half-width">
          <fieldset>
            <legend>{l('Place Details')}</legend>
            <FormRowNameWithGuesscase
              field={form.field.name}
              options={{}}
            />
            <DuplicateEntitiesSection />
            <FormRowTextLong
              field={form.field.comment}
              label={addColonText(l('Disambiguation'))}
            />
            <FormRowSelect
              field={form.field.type_id}
              label={l('Type:')}
              options={typeOptions}
            />
            <FormRowTextLong
              field={form.field.address}
              label={l('Address:')}
            />
            <FormRow>
              <label for="id-edit-place.area.name">{l('Area:')}</label>
              <span class="area autocomplete">
                <SearchIcon />
                <HiddenField field={form.field.area.field.gid} className="gid"/>
                <HiddenField field={form.field.area_id} className="id"/>
                <input className="name" value={form.field.area.name}/>
              </span>
              <FieldErrors field={form.field.area.name}/>
            </FormRow>
            <FormRowTextLong
              field={form.field.coordinates}
              label={l('Coordinates')}
            />
            <ul class="errors coordinates-errors" style="display:none"><li>{l('These coordinates could not be parsed.')}</li></ul>
          </fieldset>
        </div>
      </form>
    </>
  )
};

export default EditForm;