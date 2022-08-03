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

import {SanitizedCatalystContext} from '../../../../context.mjs';
import FieldErrors from '../../../../components/FieldErrors';
import FormRow from '../../../../components/FormRow';
import FormLabel from '../../../../components/FormLabel';
import FormRowCheckbox from '../../../../components/FormRowCheckbox';
import FormRowSelect from '../../../../components/FormRowSelect';
import FormRowTextArea from '../../../../components/FormRowTextArea';
import FormRowTextLong from '../../../../components/FormRowTextLong';
import FormSubmit from '../../../../components/FormSubmit';
import Autocomplete from '../../common/components/Autocomplete';
import {pushCompoundField}
  from '../../edit/utility/pushField';
import type {CollaboratorStateT, CollectionEditFormT}
  from '../../../../collection/types';

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

  function handleCollaboratorChange(newCollaborator, index) {
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
        <form action={$c.req.uri} method="post">
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
                      onChange={(c) => handleCollaboratorChange(c, index)}
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
