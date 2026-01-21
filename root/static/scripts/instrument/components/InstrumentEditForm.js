/*
 * @flow strict-local
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {CowContext} from 'mutate-cow';
import mutate from 'mutate-cow';
import * as React from 'react';

import {SanitizedCatalystContext} from '../../../../context.mjs';
import type {InstrumentFormT} from '../../../../instrument/types.js';
import useFormUnloadWarning from '../../common/hooks/useFormUnloadWarning.js';
import {commaOnlyListText} from '../../common/i18n/commaOnlyList.js';
import {supportedHtmlTags} from '../../common/i18n/expand2react.js';
import {
  getSourceEntityDataForRelationshipEditor,
} from '../../common/utility/catalyst.js';
import isBlank from '../../common/utility/isBlank.js';
import EnterEdit from '../../edit/components/EnterEdit.js';
import EnterEditNote from '../../edit/components/EnterEditNote.js';
import FormRow from '../../edit/components/FormRow.js';
import FormRowNameWithGuessCase, {
  type ActionT as NameActionT,
  runReducer as runNameReducer,
} from '../../edit/components/FormRowNameWithGuessCase.js';
import FormRowSelect from '../../edit/components/FormRowSelect.js';
import FormRowTextArea from '../../edit/components/FormRowTextArea.js';
import FormRowTextLong from '../../edit/components/FormRowTextLong.js';
import {
  type StateT as GuessCaseOptionsStateT,
  createInitialState as createGuessCaseOptionsState,
} from '../../edit/components/GuessCaseOptions.js';
import {
  _ExternalLinksEditor,
  ExternalLinksEditor,
  prepareExternalLinksHtmlFormSubmission,
} from '../../edit/externalLinks.js';
import isInvalidEditNote from '../../edit/utility/isInvalidEditNote.js';
import isParseableHtml from '../../edit/utility/isParseableHtml.js';
import {
  applyAllPendingErrors,
  hasSubfieldErrors,
} from '../../edit/utility/subfieldErrors.js';
import {
  NonHydratedRelationshipEditorWrapper as RelationshipEditorWrapper,
} from '../../relationship-editor/components/RelationshipEditorWrapper.js';

/* eslint-disable ft-flow/sort-keys */
type ActionT =
  | {+type: 'set-type', +type_id: string}
  | {+type: 'show-all-pending-errors'}
  | {+type: 'update-description', +description: string}
  | {+type: 'update-edit-note', +editNote: string}
  | {+type: 'update-name', +action: NameActionT};
/* eslint-enable ft-flow/sort-keys */

type StateT = {
  +actionName: string,
  +form: InstrumentFormT,
  +guessCaseOptions: GuessCaseOptionsStateT,
  +instrument: InstrumentT,
  +isGuessCaseOptionsOpen: boolean,
  +shownBubble: string,
};

type CreateInitialStatePropsT = {
  +$c: SanitizedCatalystContextT,
  +form: InstrumentFormT,
};

function updateNameFieldErrors(
  nameFieldCtx: CowContext<FieldT<string | null>>,
) {
  if (isBlank(nameFieldCtx.get('value').read())) {
    nameFieldCtx.set('has_errors', true);
    nameFieldCtx.set('pendingErrors', [
      l_admin('Required field.'),
    ]);
  } else {
    nameFieldCtx.set('has_errors', false);
    nameFieldCtx.set('pendingErrors', []);
    nameFieldCtx.set('errors', []);
  }
}

function updateDescriptionFieldErrors(
  descriptionFieldCtx: CowContext<FieldT<string>>,
) {
  const description = descriptionFieldCtx.get('value').read();
  const error = isParseableHtml(description);
  if (error) {
    descriptionFieldCtx.set('has_errors', true);
    descriptionFieldCtx.set('errors', [error]);
  } else {
    descriptionFieldCtx.set('has_errors', false);
    descriptionFieldCtx.set('pendingErrors', []);
    descriptionFieldCtx.set('errors', []);
  }
}

function updateNoteFieldErrors(
  actionName: string,
  editNoteFieldCtx: CowContext<FieldT<string>>,
) {
  const editNote = editNoteFieldCtx.get('value').read();
  if (isInvalidEditNote(editNote)) {
    editNoteFieldCtx.set('has_errors', true);
    editNoteFieldCtx.set('errors', [
      l_admin(`Your edit note seems to have no actual content.
               Please provide a note that will be helpful to
               your fellow editors!`),
    ]);
  } else {
    editNoteFieldCtx.set('has_errors', false);
    editNoteFieldCtx.set('pendingErrors', []);
    editNoteFieldCtx.set('errors', []);
  }
}

function createInitialState({
  $c,
  form,
}: CreateInitialStatePropsT): StateT {
  const instrument = getSourceEntityDataForRelationshipEditor($c);
  const actionName = $c.action.name;
  invariant(instrument && instrument.entityType === 'instrument');

  const formCtx = mutate(form);
  // $FlowExpectedError[incompatible-call]
  const nameFieldCtx = formCtx.get('field', 'name');
  updateNameFieldErrors(nameFieldCtx);
  const editNoteFieldCtx = formCtx.get('field', 'edit_note');
  updateNoteFieldErrors(actionName, editNoteFieldCtx);

  return {
    actionName,
    form: formCtx.final(),
    guessCaseOptions: createGuessCaseOptionsState(),
    instrument,
    isGuessCaseOptionsOpen: false,
    shownBubble: '',
  };
}

function reducer(state: StateT, action: ActionT): StateT {
  const newStateCtx = mutate(state);

  match (action) {
    {type: 'update-description', const description} => {
      newStateCtx
        .update('form', 'field', 'description', (descriptionFieldCtx) => {
          descriptionFieldCtx.set('value', description);
          updateDescriptionFieldErrors(descriptionFieldCtx);
        });
    }
    {type: 'update-edit-note', const editNote} => {
      newStateCtx
        .update('form', 'field', 'edit_note', (editNoteFieldCtx) => {
          editNoteFieldCtx.set('value', editNote);
          updateNoteFieldErrors(state.actionName, editNoteFieldCtx);
        });
    }
    {type: 'update-name', const action} => {
      const nameStateCtx = mutate({
        field: state.form.field.name,
        guessCaseOptions: state.guessCaseOptions,
        isGuessCaseOptionsOpen: state.isGuessCaseOptionsOpen,
      });
      runNameReducer(nameStateCtx, action);

      const nameState = nameStateCtx.final();
      newStateCtx
        .update('form', 'field', 'name', (nameFieldCtx) => {
          nameFieldCtx.set(nameState.field);
          updateNameFieldErrors(nameFieldCtx);
        })
        .set('guessCaseOptions', nameState.guessCaseOptions)
        .set('isGuessCaseOptionsOpen', nameState.isGuessCaseOptionsOpen);
    }
    {type: 'set-type', const type_id} => {
      newStateCtx
        .update('form', 'field', 'type_id', (typeIdFieldCtx) => {
          typeIdFieldCtx.set('value', type_id);
        });
    }
    {type: 'show-all-pending-errors'} => {
      applyAllPendingErrors(newStateCtx.get('form'));
    }
  }
  return newStateCtx.final();
}

component InstrumentEditForm(
  form as initialForm: InstrumentFormT,
  instrumentTypes: SelectOptionsT,
) {
  const $c = React.useContext(SanitizedCatalystContext);

  const typeOptions = {
    grouped: false as const,
    options: instrumentTypes,
  };

  useFormUnloadWarning();

  const [state, dispatch] = React.useReducer(
    reducer,
    {$c, form: initialForm},
    createInitialState,
  );

  const nameDispatch = React.useCallback((action: NameActionT) => {
    dispatch({action, type: 'update-name'});
  }, [dispatch]);

  const handleDescriptionChange = React.useCallback((
    event: SyntheticEvent<HTMLTextAreaElement>,
  ) => {
    dispatch({
      description: event.currentTarget.value,
      type: 'update-description',
    });
  }, [dispatch]);


  const handleEditNoteChange = React.useCallback((
    event: SyntheticEvent<HTMLTextAreaElement>,
  ) => {
    dispatch({
      editNote: event.currentTarget.value,
      type: 'update-edit-note',
    });
  }, [dispatch]);

  const setType = React.useCallback((
    event: SyntheticEvent<HTMLSelectElement>,
  ) => {
    dispatch({type: 'set-type', type_id: event.currentTarget.value});
  }, [dispatch]);

  const hasErrors = hasSubfieldErrors(state.form);

  const externalLinksEditorRef = React.createRef<_ExternalLinksEditor>();

  // Ensure errors are shown if the user tries to submit with Enter
  const handleKeyDown = (event: SyntheticKeyboardEvent<HTMLFormElement>) => {
    if (event.key === 'Enter' && hasErrors) {
      dispatch({type: 'show-all-pending-errors'});
    }
  };

  const handleSubmit = (event: SyntheticEvent<HTMLFormElement>) => {
    if (hasErrors) {
      dispatch({type: 'show-all-pending-errors'});
      event.preventDefault();
    }
    invariant(externalLinksEditorRef.current);
    prepareExternalLinksHtmlFormSubmission(
      'edit-instrument',
      externalLinksEditorRef.current,
    );
  };

  return (
    <form
      className="edit-instrument"
      method="post"
      onKeyDown={handleKeyDown}
      onSubmit={handleSubmit}
    >
      <div className="half-width">
        <fieldset>
          <legend>{l_admin('Instrument details')}</legend>
          <FormRowNameWithGuessCase
            dispatch={nameDispatch}
            entity={state.instrument}
            field={state.form.field.name}
            guessCaseOptions={state.guessCaseOptions}
            isGuessCaseOptionsOpen={state.isGuessCaseOptionsOpen}
            label={addColonText(l_admin('Name'))}
          />
          <FormRowTextLong
            field={state.form.field.comment}
            label={addColonText(l_admin('Disambiguation'))}
            uncontrolled
          />
          <FormRowSelect
            allowEmpty
            field={state.form.field.type_id}
            label={addColonText(l_admin('Type'))}
            onChange={setType}
            options={typeOptions}
          />
          <FormRowTextArea
            cols={80}
            field={state.form.field.description}
            label={addColonText(l_admin('Description'))}
            onChange={handleDescriptionChange}
            rows={5}
            uncontrolled={false}
          />
          <FormRow>
            <p>
              {'HTML tags allowed in the description: ' +
                commaOnlyListText(supportedHtmlTags) + '.'}
            </p>
          </FormRow>
        </fieldset>

        <RelationshipEditorWrapper
          formName={state.form.name}
          seededRelationships={$c.stash.seeded_relationships}
        />

        <fieldset>
          <legend>{l_admin('External links')}</legend>
          <ExternalLinksEditor
            isNewEntity={!state.instrument.id}
            ref={externalLinksEditorRef}
            sourceData={state.instrument}
          />
        </fieldset>

        <EnterEditNote
          controlled
          field={state.form.field.edit_note}
          onChange={handleEditNoteChange}
        />
        <EnterEdit disabled={hasErrors} form={state.form} />
      </div>
    </form>
  );
}

export default (hydrate<React.PropsOf<InstrumentEditForm>>(
  'div.instrument-edit-form',
  InstrumentEditForm,
): component(...React.PropsOf<InstrumentEditForm>));
