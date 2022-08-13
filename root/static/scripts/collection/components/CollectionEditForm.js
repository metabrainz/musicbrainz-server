/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import mutate from 'mutate-cow';
import * as React from 'react';

import type {CollaboratorStateT, CollectionEditFormT}
  from '../../../../collection/types.js';
import {SanitizedCatalystContext} from '../../../../context.mjs';
import Autocomplete from '../../common/components/Autocomplete.js';
import FieldErrors from '../../edit/components/FieldErrors.js';
import FormRow from '../../edit/components/FormRow.js';
import FormLabel from '../../edit/components/FormLabel.js';
import FormRowCheckbox from '../../edit/components/FormRowCheckbox.js';
import FormRowSelect from '../../edit/components/FormRowSelect.js';
import FormRowTextArea from '../../edit/components/FormRowTextArea.js';
import FormRowTextLong from '../../edit/components/FormRowTextLong.js';
import FormSubmit from '../../edit/components/FormSubmit.js';
import {pushCompoundField} from '../../edit/utility/pushField.js';

type Props = {
  +collectionTypes: SelectOptionsT,
  +form: CollectionEditFormT,
};

const CollectionEditForm = ({collectionTypes, form}: Props) => {
  const [collaborators, setCollaborators] =
    React.useState(form.field.collaborators);

  function removeCollaborator(collaboratorIndex: number) {
    setCollaborators(mutate<CollaboratorStateT, _>(collaborators, copy => {
      copy.field.splice(collaboratorIndex, 1);
    }));
  }

  function handleCollaboratorAdd() {
    setCollaborators(mutate<CollaboratorStateT, _>(collaborators, copy => {
      pushCompoundField(copy, {
        id: null,
        name: '',
      });
    }));
  }

  function handleCollaboratorChange(
    newCollaborator: EditorT,
    index: number,
  ) {
    setCollaborators(mutate<CollaboratorStateT, _>(collaborators, copy => {
      copy.field[index].field.id.value = newCollaborator.id;
      copy.field[index].field.name.value = newCollaborator.name;
    }));
  }

  const typeOptions = {
    grouped: false,
    options: collectionTypes,
  };

  if (collaborators.last_index === -1) {
    handleCollaboratorAdd();
  }

  return (
    <SanitizedCatalystContext.Consumer>
      {$c => (
        <form method="post">
          <fieldset>
            <legend>{l('Collection details')}</legend>
            <FormRowTextLong
              field={form.field.name}
              label={addColonText(l('Name'))}
              required
              uncontrolled
            />
            <FormRowSelect
              field={form.field.type_id}
              label={addColonText(l('Type'))}
              options={typeOptions}
              uncontrolled
            />
            <FormRowTextArea
              field={form.field.description}
              label={addColonText(l('Description'))}
            />
            <FormRowCheckbox
              field={form.field.public}
              label={l('Allow other users to see this collection')}
              uncontrolled
            />

            <FormRow>
              <FormLabel
                forField={collaborators}
                label={addColonText(l('Collaborators'))}
              />
              <div className="form-row-text-list">
                {collaborators.field.map((collaborator, index) => (
                  <div
                    className="text-list-row"
                    id="collaborators-form-list"
                    key={collaborator.html_name}
                  >
                    <Autocomplete
                      currentSelection={{
                        id: collaborator.field.id.value,
                        name: collaborator.field.name.value,
                      }}
                      entity="editor"
                      inputID={'id-' + collaborator.html_name}
                      inputName={collaborator.field.name.html_name}
                      onChange={(
                        collaborator: EditorT,
                      ) => handleCollaboratorChange(collaborator, index)}
                    >
                      <input
                        name={collaborator.field.id.html_name}
                        type="hidden"
                        value={collaborator.field.id.value || ''}
                      />
                    </Autocomplete>
                    <button
                      className="nobutton icon remove-item"
                      onClick={() => (removeCollaborator(index))}
                      title={l('Remove collaborator')}
                      type="button"
                    />

                    <FieldErrors field={collaborator.field.id} />
                    <FieldErrors field={collaborator.field.name} />
                  </div>
                ))}
                <div className="form-row-add">
                  <button
                    className="with-label add-item"
                    onClick={handleCollaboratorAdd}
                    type="button"
                  >
                    {l('Add collaborator')}
                  </button>
                </div>
              </div>
            </FormRow>
          </fieldset>

          <div className="row no-label">
            {$c.action.name === 'create' ? (
              <FormSubmit label={l('Create collection')} />
            ) : (
              <FormSubmit label={l('Update collection')} />
            )}
          </div>
        </form>
      )}
    </SanitizedCatalystContext.Consumer>
  );
};

export default (hydrate<Props>(
  'div.collection-edit-form',
  CollectionEditForm,
): React.AbstractComponent<Props, void>);
