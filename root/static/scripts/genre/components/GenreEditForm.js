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
  WritableGenreFormT,
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
  type WritableStateT as WritableGuessCaseOptionsStateT,
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

type Props = {
  +form: GenreFormT,
};

/* eslint-disable flowtype/sort-keys */
type ActionT =
  | {+type: 'update-name', +action: NameActionT};
/* eslint-enable flowtype/sort-keys */

type StateT = {
  +form: GenreFormT,
  +guessCaseOptions: GuessCaseOptionsStateT,
  +isGuessCaseOptionsOpen: boolean,
};

type WritableStateT = {
  ...StateT,
  form: WritableGenreFormT,
  guessCaseOptions: WritableGuessCaseOptionsStateT,
};

function createInitialState(form: GenreFormT) {
  return {
    form,
    guessCaseOptions: createGuessCaseOptionsState(),
    isGuessCaseOptionsOpen: false,
  };
}

function reducer(state: StateT, action: ActionT): StateT {
  return mutate<WritableStateT, StateT>(state, newState => {
    switch (action.type) {
      case 'update-name': {
        const nameState = {
          field: newState.form.field.name,
          guessCaseOptions: newState.guessCaseOptions,
          isGuessCaseOptionsOpen: newState.isGuessCaseOptionsOpen,
        };
        runNameReducer(nameState, action.action);
        newState.guessCaseOptions = nameState.guessCaseOptions;
        newState.isGuessCaseOptionsOpen = nameState.isGuessCaseOptionsOpen;
        break;
      }
      default: {
        /*:: exhaustive(action); */
      }
    }
  });
}

const GenreEditForm = ({
  form: initialForm,
}: Props): React$Element<'form'> => {
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
          <legend>{l('Genre details')}</legend>
          <FormRowNameWithGuessCase
            dispatch={nameDispatch}
            entity={genre}
            field={state.form.field.name}
            guessCaseOptions={state.guessCaseOptions}
            isGuessCaseOptionsOpen={state.isGuessCaseOptionsOpen}
            label={addColonText(l('Name'))}
          />
          <FormRowTextLong
            field={state.form.field.comment}
            label={addColonText(l('Disambiguation'))}
            uncontrolled
          />
        </fieldset>
        <RelationshipEditorWrapper
          formName={state.form.name}
          seededRelationships={$c.stash.seeded_relationships}
        />
        <fieldset>
          <legend>{l('External Links')}</legend>
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
};

export default (hydrate<Props>(
  'div.genre-edit-form',
  GenreEditForm,
): React$AbstractComponent<Props, void>);
