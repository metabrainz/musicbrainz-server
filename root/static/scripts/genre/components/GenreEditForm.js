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
import {getSourceEntityData} from '../../common/utility/catalyst.js';
import EnterEdit from '../../edit/components/EnterEdit.js';
import EnterEditNote from '../../edit/components/EnterEditNote.js';
import FormRowNameWithGuessCase
  from '../../edit/components/FormRowNameWithGuessCase.js';
import FormRowTextLong from '../../edit/components/FormRowTextLong.js';
import {
  hydrateRelationshipEditorForm,
} from '../../edit/components/withLoadedTypeInfo.js';
import {
  type CommonEntityEditFormActionT,
  type CommonEntityEditFormStateT,
  createCommonEntityEditFormState,
  runCommonEntityEditFormActions,
  useCommonEntityEditForm,
} from '../../edit/utility/forms.js';
import ExternalLinksEditorFieldset
  // eslint-disable-next-line @stylistic/max-len
  from '../../external-links-editor/components/ExternalLinksEditorFieldset.js';
import RelationshipEditorFieldset
  from '../../relationship-editor/components/RelationshipEditorFieldset.js';

type ActionT = CommonEntityEditFormActionT;

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
  return {
    ...createCommonEntityEditFormState({$c, formCtx}),
    form: formCtx.final(),
  };
}

function reducer(state: StateT, action: ActionT): StateT {
  const newStateCtx = mutate(state);
  match (action) {
    _ as action => {
      runCommonEntityEditFormActions(newStateCtx, action);
    }
  }
  return newStateCtx.final();
}

component GenreEditForm(form as initialForm: GenreFormT) {
  const $c = React.useContext(SanitizedCatalystContext);

  const [state, dispatch] = React.useReducer(
    reducer,
    {$c, form: initialForm},
    createInitialState,
  );

  const {
    handleEditNoteChange,
    handleSubmit,
    hasVisibleErrors,
    nameDispatch,
  } = useCommonEntityEditForm(state, dispatch);

  const genre: GenreT = getSourceEntityData($c, 'genre');

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
        <RelationshipEditorFieldset
          dispatch={dispatch}
          formName={state.form.name}
          state={state.relationshipEditor}
        />
        <ExternalLinksEditorFieldset
          dispatch={dispatch}
          state={state.externalLinksEditor}
        />
        <EnterEditNote
          controlled
          field={state.form.field.edit_note}
          onChange={handleEditNoteChange}
        />
        <EnterEdit errorsExist={hasVisibleErrors} form={state.form} />
      </div>
    </form>
  );
}

export default (
  hydrateRelationshipEditorForm<React.PropsOf<GenreEditForm>>(
    'div.genre-edit-form',
    GenreEditForm,
  ) as component(...React.PropsOf<GenreEditForm>)
);
