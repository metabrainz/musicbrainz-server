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

import type {
  CollaboratorFieldT,
  CollaboratorsStateT,
  CollaboratorStateT,
  CollectionEditFormT,
  WritableCollaboratorsStateT,
} from '../../../../collection/types.js';
import {SanitizedCatalystContext} from '../../../../context.mjs';
import Autocomplete2, {
  createInitialState as createInitialAutocompleteState,
} from '../../common/components/Autocomplete2.js';
import {
  default as autocompleteReducer,
} from '../../common/components/Autocomplete2/reducer.js';
import type {
  ActionT as AutocompleteActionT,
  StateT as AutocompleteStateT,
} from '../../common/components/Autocomplete2/types.js';
import FieldErrors from '../../edit/components/FieldErrors.js';
import FormLabel from '../../edit/components/FormLabel.js';
import FormRow from '../../edit/components/FormRow.js';
import FormRowCheckbox from '../../edit/components/FormRowCheckbox.js';
import FormRowSelect from '../../edit/components/FormRowSelect.js';
import FormRowTextArea from '../../edit/components/FormRowTextArea.js';
import FormRowTextLong from '../../edit/components/FormRowTextLong.js';
import FormSubmit from '../../edit/components/FormSubmit.js';
import {
  createCompoundFieldFromObject,
} from '../../edit/utility/createField.js';

type Props = {
  +collectionTypes: SelectOptionsT,
  +form: CollectionEditFormT,
};

type StateT = {
  +collaborators: CollaboratorsStateT,
};

type ActionT =
  | {+type: 'add-collaborator'}
  | {+fieldId: number, +type: 'remove-collaborator'}
  | {
      +action: AutocompleteActionT<EditorT>,
      +fieldId: number,
      +type: 'update-collaborator',
    };

function createCollaboratorAutocompleteState(
  collaborator: CollaboratorFieldT,
): AutocompleteStateT<EditorT> {
  const field = collaborator.field;
  const name = field.name.value;
  const id = field.id.value;

  return createInitialAutocompleteState({
    entityType: 'editor',
    id: 'id-' + collaborator.html_name,
    inputValue: name,
    selectedItem: nonEmpty(id) ? {
      entity: {
        avatar: '',
        deleted: false,
        entityType: 'editor',
        id,
        is_limited: false,
        name,
        privileges: -1,
      },
      id,
      name,
      type: 'option',
    } : null,
  });
}

function addCollaborator(
  collaborators: CollaboratorsStateT,
): CollaboratorsStateT {
  return mutate(
    collaborators,
    (copy: WritableCollaboratorsStateT) => {
      const name = copy.html_name + '.' + String(++copy.last_index);
      const field = createCompoundFieldFromObject(name, {
        id: null,
        name: '',
      });
      copy.field.push({
        ...field,
        autocomplete: createCollaboratorAutocompleteState(field),
      });
    },
  );
}

function createInitialState(form: CollectionEditFormT): StateT {
  const initialCollaborators = form.field.collaborators;
  let collaborators: CollaboratorsStateT = {
    ...initialCollaborators,
    field: initialCollaborators.field.map((collaborator) => ({
      ...collaborator,
      autocomplete: createCollaboratorAutocompleteState(collaborator),
    })),
  };
  if (collaborators.last_index === -1) {
    collaborators = addCollaborator(collaborators);
  }
  return {collaborators};
}

function reducer(state: StateT, action: ActionT): StateT {
  let collaborators = state.collaborators;
  switch (action.type) {
    case 'add-collaborator': {
      collaborators = addCollaborator(collaborators);
      break;
    }
    case 'remove-collaborator': {
      const index = collaborators.field.findIndex(
        (collaborator) => collaborator.id === action.fieldId,
      );
      invariant(index >= 0);
      collaborators = mutate(
        collaborators,
        (copy: WritableCollaboratorsStateT) => {
          copy.field.splice(index, 1);
        },
      );
      break;
    }
    case 'update-collaborator': {
      const index = state.collaborators.field.findIndex(
        (collaborator) => collaborator.id === action.fieldId,
      );
      invariant(index >= 0);
      const oldAutocompleteState = collaborators.field[index].autocomplete;
      const oldEditor = oldAutocompleteState.selectedItem?.entity;
      collaborators = mutate(
        collaborators,
        (copy: WritableCollaboratorsStateT) => {
          const newAutocompleteState = autocompleteReducer(
            oldAutocompleteState,
            action.action,
          );
          copy.field[index].autocomplete = newAutocompleteState;
          const newEditor = newAutocompleteState.selectedItem?.entity;
          if (newEditor !== oldEditor) {
            let id = null;
            let name = '';
            if (newEditor) {
              id = newEditor.id;
              name = newEditor.name;
            }
            copy.field[index].field.id.value = id;
            copy.field[index].field.name.value = name;
          }
        },
      );
      break;
    }
  }
  return {collaborators};
}

const CollectionEditForm = ({
  collectionTypes,
  form,
}: Props): React$MixedElement => {
  const typeOptions = {
    grouped: false,
    options: collectionTypes,
  };

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
                forField={form.field.collaborators}
                label={addColonText(l('Collaborators'))}
              />
              <CollaboratorsFormList form={form} />
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

type CollaboratorsFormListPropsT = {
  +form: CollectionEditFormT,
};

const CollaboratorsFormList = (hydrate<CollaboratorsFormListPropsT>(
  'div.collaborators-form-list',
  React.memo(({
    form,
  }: CollaboratorsFormListPropsT) => {
    const [state, dispatch] =
      React.useReducer<StateT, ActionT, CollectionEditFormT>(
        reducer,
        form,
        createInitialState,
      );

    const removeCollaborator = React.useCallback((
      fieldId: number,
    ): void => {
      dispatch({fieldId, type: 'remove-collaborator'});
    }, [dispatch]);

    const addCollaborator = React.useCallback(() => {
      dispatch({type: 'add-collaborator'});
    }, [dispatch]);

    const updateCollaborator = React.useCallback((
      fieldId: number,
      action: AutocompleteActionT<EditorT>,
    ) => {
      dispatch({action, fieldId, type: 'update-collaborator'});
    }, [dispatch]);

    return (
      <div className="form-row-text-list">
        {state.collaborators.field.map((collaborator) => (
          <CollaboratorRow
            collaborator={collaborator}
            key={collaborator.id}
            removeCollaborator={removeCollaborator}
            updateCollaborator={updateCollaborator}
          />
        ))}
        <div className="form-row-add short">
          <button
            className="with-label add-item"
            onClick={addCollaborator}
            type="button"
          >
            {l('Add collaborator')}
          </button>
        </div>
      </div>
    );
  }),
): React$AbstractComponent<CollaboratorsFormListPropsT, void>);

type CollaboratorRowPropsT = {
  +collaborator: CollaboratorStateT,
  +removeCollaborator: (fieldId: number) => void,
  +updateCollaborator: (
    fieldId: number,
    action: AutocompleteActionT<EditorT>,
  ) => void,
};

const CollaboratorRow = React.memo(({
  collaborator,
  removeCollaborator,
  updateCollaborator,
}: CollaboratorRowPropsT) => {
  const autocompleteDispatch = React.useCallback((
    action: AutocompleteActionT<EditorT>,
  ) => {
    updateCollaborator(collaborator.id, action);
  }, [updateCollaborator, collaborator.id]);

  const field = collaborator.field;
  const idField = field.id;
  const nameField = field.name;

  return (
    <div className="text-list-row">
      <Autocomplete2
        dispatch={autocompleteDispatch}
        state={collaborator.autocomplete}
      >
        <button
          className="nobutton icon remove-item"
          onClick={() => removeCollaborator(collaborator.id)}
          style={{alignSelf: 'center'}}
          title={l('Remove collaborator')}
          type="button"
        />
        <input
          name={idField.html_name}
          type="hidden"
          value={idField.value ?? ''}
        />
        <input
          name={nameField.html_name}
          type="hidden"
          value={nameField.value}
        />
      </Autocomplete2>
      <FieldErrors field={idField} />
      <FieldErrors field={nameField} />
    </div>
  );
});

export default CollectionEditForm;
