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
import isBlank from '../../common/utility/isBlank.js';
import EnterEdit from '../../edit/components/EnterEdit.js';
import EnterEditNote from '../../edit/components/EnterEditNote.js';
import FormRowNameWithGuessCase, {
  type ActionT as NameActionT,
  runReducer as runNameReducer,
} from '../../edit/components/FormRowNameWithGuessCase.js';
import FormRowTextLong from '../../edit/components/FormRowTextLong.js';
import {
  type StateT as GuessCaseOptionsStateT,
  createInitialState as createGuessCaseOptionsState,
} from '../../edit/components/GuessCaseOptions.js';
import ExternalLinksEditorFieldset
  // eslint-disable-next-line @stylistic/max-len
  from '../../external-links-editor/components/ExternalLinksEditorFieldset.js';
import {
  createInitialState as createExternalLinksEditorState,
  reducer as externalLinksEditorReducer,
} from '../../external-links-editor/state.js';
import type {
  LinksEditorActionT,
  LinksEditorStateT,
} from '../../external-links-editor/types.js';
import {
  hasErrorsOnNewOrChangedLinks,
} from '../../external-links-editor/validation.js';
import {
  NonHydratedRelationshipEditorWrapper as RelationshipEditorWrapper,
} from '../../relationship-editor/components/RelationshipEditorWrapper.js';

/* eslint-disable ft-flow/sort-keys */
type ActionT =
  | {+type: 'update-external-links-editor', +action: LinksEditorActionT}
  | {+type: 'update-name', +action: NameActionT};
/* eslint-enable ft-flow/sort-keys */

type StateT = {
  +externalLinksEditor: LinksEditorStateT,
  +form: GenreFormT,
  +guessCaseOptions: GuessCaseOptionsStateT,
  +isGuessCaseOptionsOpen: boolean,
};

function createInitialState({
  $c,
  form,
}: {
  +$c: SanitizedCatalystContextT,
  +form: GenreFormT,
}) {
  return {
    externalLinksEditor: createExternalLinksEditorState($c),
    form,
    guessCaseOptions: createGuessCaseOptionsState(),
    isGuessCaseOptionsOpen: false,
  };
}

function reducer(state: StateT, action: ActionT): StateT {
  const newStateCtx = mutate(state);
  match (action) {
    {type: 'update-name', const action} => {
      const nameStateCtx = mutate({
        field: state.form.field.name,
        guessCaseOptions: state.guessCaseOptions,
        isGuessCaseOptionsOpen: state.isGuessCaseOptionsOpen,
      });
      runNameReducer(nameStateCtx, action);
      const nameState = nameStateCtx.read();
      newStateCtx
        .set('form', 'field', 'name', nameState.field)
        .set('guessCaseOptions', nameState.guessCaseOptions)
        .set('isGuessCaseOptionsOpen', nameState.isGuessCaseOptionsOpen);
    }
    {type: 'update-external-links-editor', const action} => {
      newStateCtx.set(
        'externalLinksEditor',
        externalLinksEditorReducer(state.externalLinksEditor, action),
      );
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

  const nameDispatch = React.useCallback((action: NameActionT) => {
    dispatch({action, type: 'update-name'});
  }, [dispatch]);

  const missingRequired = isBlank(state.form.field.name.value);

  const hasErrors = missingRequired ||
    hasErrorsOnNewOrChangedLinks(state.externalLinksEditor.links);

  // Ensure errors are shown if the user tries to submit with Enter
  const handleKeyDown = (event: SyntheticKeyboardEvent<HTMLFormElement>) => {
    if (event.key === 'Enter' && hasErrors) {
      event.preventDefault();
    }
  };

  const genre: GenreT = getSourceEntityData($c, 'genre');

  const handleSubmit = (event: SyntheticEvent<HTMLFormElement>) => {
    if (hasErrors) {
      event.preventDefault();
    }
  };

  return (
    <form
      className="edit-genre"
      method="post"
      onKeyDown={handleKeyDown}
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
        <RelationshipEditorWrapper
          formName={state.form.name}
          seededRelationships={$c.stash.seeded_relationships}
        />
        <ExternalLinksEditorFieldset
          dispatch={dispatch}
          state={state.externalLinksEditor}
        />
        <EnterEditNote field={state.form.field.edit_note} />
        <EnterEdit disabled={hasErrors} form={state.form} />
      </div>
    </form>
  );
}

export default (hydrate<React.PropsOf<GenreEditForm>>(
  'div.genre-edit-form',
  GenreEditForm,
): component(...React.PropsOf<GenreEditForm>));
