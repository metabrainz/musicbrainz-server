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
import {
  _ExternalLinksEditor,
  ExternalLinksEditor,
  prepareExternalLinksHtmlFormSubmission,
} from '../../edit/externalLinks.js';
import {
  NonHydratedRelationshipEditorWrapper as RelationshipEditorWrapper,
} from '../../relationship-editor/components/RelationshipEditorWrapper.js';

/* eslint-disable ft-flow/sort-keys */
type ActionT =
  | {+type: 'update-name', +action: NameActionT};
/* eslint-enable ft-flow/sort-keys */

type StateT = {
  +form: GenreFormT,
  +guessCaseOptions: GuessCaseOptionsStateT,
  +isGuessCaseOptionsOpen: boolean,
};

function createInitialState(form: GenreFormT) {
  return {
    form,
    guessCaseOptions: createGuessCaseOptionsState(),
    isGuessCaseOptionsOpen: false,
  };
}

function reducer(state: StateT, action: ActionT): StateT {
  let newState = state;
  switch (action.type) {
    case 'update-name': {
      const nameStateCtx = mutate({
        field: state.form.field.name,
        guessCaseOptions: state.guessCaseOptions,
        isGuessCaseOptionsOpen: state.isGuessCaseOptionsOpen,
      });
      runNameReducer(nameStateCtx, action.action);
      const nameState = nameStateCtx.read();
      newState = mutate(state)
        .set('form', 'field', 'name', nameState.field)
        .set('guessCaseOptions', nameState.guessCaseOptions)
        .set('isGuessCaseOptionsOpen', nameState.isGuessCaseOptionsOpen)
        .final();
      break;
    }
    default: {
      /*:: exhaustive(action); */
    }
  }
  return newState;
}

component GenreEditForm(form as initialForm: GenreFormT) {
  const $c = React.useContext(SanitizedCatalystContext);

  const [state, dispatch] = React.useReducer(
    reducer,
    createInitialState(initialForm),
  );

  const nameDispatch = React.useCallback((action: NameActionT) => {
    dispatch({action, type: 'update-name'});
  }, [dispatch]);

  const missingRequired = isBlank(state.form.field.name.value);

  const hasErrors = missingRequired;

  // Ensure errors are shown if the user tries to submit with Enter
  const handleKeyDown = (event: SyntheticKeyboardEvent<HTMLFormElement>) => {
    if (event.key === 'Enter' && hasErrors) {
      event.preventDefault();
    }
  };

  const genre = $c.stash.source_entity;
  invariant(genre && genre.entityType === 'genre');

  const externalLinksEditorRef = React.createRef<_ExternalLinksEditor>();

  const handleSubmit = (event: SyntheticEvent<HTMLFormElement>) => {
    if (hasErrors) {
      event.preventDefault();
    }
    invariant(externalLinksEditorRef.current);
    prepareExternalLinksHtmlFormSubmission(
      'edit-genre',
      externalLinksEditorRef.current,
    );
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
        <fieldset>
          <legend>{'External links'}</legend>
          <ExternalLinksEditor
            isNewEntity={!genre.id}
            ref={externalLinksEditorRef}
            sourceData={genre}
          />
        </fieldset>

        <EnterEditNote field={state.form.field.edit_note} />
        <EnterEdit disabled={hasErrors} form={state.form} />
      </div>
    </form>
  );
}

export default (hydrate<React.PropsOf<GenreEditForm>>(
  'div.genre-edit-form',
  GenreEditForm,
): React.AbstractComponent<React.PropsOf<GenreEditForm>, void>);
