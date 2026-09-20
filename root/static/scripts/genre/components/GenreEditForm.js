/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import mutate from 'mutate-cow';
import * as React from 'react';

import {SanitizedCatalystContext} from '../../../../context.mjs';
import type {
  GenreFormT,
} from '../../../../genre/types.js';
import useContainingDialogEscape
  from '../../common/hooks/useContainingDialogEscape.js';
import useFormUnloadWarning from '../../common/hooks/useFormUnloadWarning.js';
import {getSourceEntityData} from '../../common/utility/catalyst.js';
import EnterEdit from '../../edit/components/EnterEdit.js';
import EnterEditNote from '../../edit/components/EnterEditNote.js';
import FormRowNameWithGuessCase, {
  type ActionT as NameActionT,
} from '../../edit/components/FormRowNameWithGuessCase.js';
import FormRowTextLong from '../../edit/components/FormRowTextLong.js';
import {
  withLoadedTypeInfoForRelationshipEditor,
} from '../../edit/components/withLoadedTypeInfo.js';
import useFormSubmitHandler
  from '../../edit/hooks/useFormSubmitHandler.js';
import {
  type CommonEntityEditFormActionT,
  type CommonEntityEditFormStateT,
  createCommonEntityEditFormState,
  getEditFormErrors,
  runCommonEntityEditFormActions,
  updateRequiredNameFieldErrors,
} from '../../edit/utility/forms.js';
import {applyAllPendingErrors} from '../../edit/utility/subfieldErrors.js';
import useChildDispatch from '../../edit/utility/useChildDispatch.js';
import ExternalLinksEditorFieldset
  // eslint-disable-next-line @stylistic/max-len
  from '../../external-links-editor/components/ExternalLinksEditorFieldset.js';
import RelationshipEditor
  from '../../relationship-editor/components/RelationshipEditor.js';
import type {
  RelationshipEditorActionT,
} from '../../relationship-editor/types/actions.js';

type ActionT =
  | CommonEntityEditFormActionT
  | {readonly type: 'show-all-pending-errors'};

type StateT = {
  ...CommonEntityEditFormStateT,
  readonly form: GenreFormT,
};

function createInitialState({
  $c,
  form,
}: {
  readonly $c: SanitizedCatalystContextT,
  readonly form: GenreFormT,
}) {
  const formCtx = mutate(form);
  const nameFieldCtx = formCtx.get('field', 'name');
  updateRequiredNameFieldErrors(nameFieldCtx);

  return {
    ...createCommonEntityEditFormState({$c, form}),
    form: formCtx.final(),
  };
}

function reducer(state: StateT, action: ActionT): StateT {
  const newStateCtx = mutate(state);
  match (action) {
    {type: 'show-all-pending-errors'} => {
      applyAllPendingErrors(newStateCtx.get('form'));
    }
    _ as action => {
      runCommonEntityEditFormActions(newStateCtx, action);
    }
  }
  return newStateCtx.final();
}

component GenreEditForm(form as initialForm: GenreFormT) {
  const $c = React.useContext(SanitizedCatalystContext);

  useFormUnloadWarning();
  useContainingDialogEscape();

  const [state, dispatch] = React.useReducer(
    reducer,
    {$c, form: initialForm},
    createInitialState,
  );

  const nameDispatch =
    useChildDispatch<NameActionT, _>(dispatch, 'update-name');
  const relationshipEditorDispatch = useChildDispatch<
    RelationshipEditorActionT, _,
  >(dispatch, 'update-relationship-editor');

  const {hasErrors, hasVisibleErrors} = getEditFormErrors(state);

  const genre: GenreT = getSourceEntityData($c, 'genre');

  const handleSubmit = useFormSubmitHandler(hasErrors, dispatch);

  return (
    <form
      className="edit-genre"
      method="post"
      onSubmit={handleSubmit}
    >
      <div className="half-width">
        <fieldset>
          <legend>{'Genre details'}</legend>
          <FormRowNameWithGuessCase
            dispatch={nameDispatch}
            entity={genre}
            field={state.form.field.name}
            guessCaseOptions={state.guessCaseOptions}
            isGuessCaseOptionsOpen={state.isGuessCaseOptionsOpen}
            label="Name:"
          />
          <FormRowTextLong
            field={state.form.field.comment}
            label="Disambiguation:"
            uncontrolled
          />
        </fieldset>
        <RelationshipEditor
          dispatch={relationshipEditorDispatch}
          formName={state.form.name}
          state={state.relationshipEditor}
        />
        <ExternalLinksEditorFieldset
          dispatch={dispatch}
          state={state.externalLinksEditor}
        />
        <EnterEditNote field={state.form.field.edit_note} />
        <EnterEdit errorsExist={hasVisibleErrors} form={state.form} />
      </div>
    </form>
  );
}

export default (
  hydrate<React.PropsOf<GenreEditForm>>(
    'div.genre-edit-form',
    withLoadedTypeInfoForRelationshipEditor<React.PropsOf<GenreEditForm>>(
      GenreEditForm,
    ),
  ) as component(...React.PropsOf<GenreEditForm>)
);
