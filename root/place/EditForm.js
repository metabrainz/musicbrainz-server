// @flow
import React from 'react';

import * as manifest from '../static/manifest';
import FormRowNameWithGuesscase from '../components/FormRowNameWithGuesscase';
import FormRowTextLong from '../components/FormRowTextLong';
import DuplicateEntitiesSection from '../components/DuplicateEntitiesSection';

type Props = {
  uri: string,
  form: PlaceFormT,
};

const EditForm = ({uri, form}: Props) => {
  console.log(form);
  return (
    <>
      {manifest.js('edit')}
      <p>
        {exp.l('For more information, check the {doc_doc|documentation}.', {doc_doc: '/doc/Place'})}
      </p>
      <form action={uri} method="post" className="edit-place">
        <div className="half-width">
          <fieldset>
            <legend>{l('Place Details')}</legend>
            <FormRowNameWithGuesscase
              field={form.field.name}
              options={{}}
            />
            <DuplicateEntitiesSection />
          </fieldset>
        </div>
      </form>
    </>
  )
};

export default EditForm;