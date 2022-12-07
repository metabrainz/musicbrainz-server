/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import mutate from 'mutate-cow';
import * as React from 'react';

import type {EditArtistCreditFormT} from '../../../../artist/types.js';
import EntityLink from '../../common/components/EntityLink.js';
import ArtistCreditEditor, {
  createInitialState as createArtistCreditState,
  reducer as runArtistCreditReducer,
} from '../../edit/components/ArtistCreditEditor.js';
import {
  type ActionT as ArtistCreditActionT,
  type StateT as ArtistCreditStateT,
} from '../../edit/components/ArtistCreditEditor/types.js';
import EnterEdit from '../../edit/components/EnterEdit.js';
import EnterEditNote from '../../edit/components/EnterEditNote.js';
import FormRow from '../../edit/components/FormRow.js';

/* eslint-disable ft-flow/sort-keys */
type ActionT =
  | {+type: 'update-artist-credit', +action: ArtistCreditActionT};
/* eslint-enable ft-flow/sort-keys */

type CreateInitialStatePropsT = {
  +artistCredit: ArtistCreditT,
  +form: EditArtistCreditFormT,
};

type StateT = {
  +artistCredit: ArtistCreditStateT,
  +form: EditArtistCreditFormT,
};

function createInitialState({
  artistCredit,
  form,
}: CreateInitialStatePropsT): StateT {
  return {
    artistCredit: createArtistCreditState({
      artistCredit,
      formName: form.name,
      id: 'source',
    }),
    form,
  };
}

function reducer(state: StateT, action: ActionT): StateT {
  const newStateCtx = mutate(state);

  match (action) {
    {type: 'update-artist-credit', const action} => {
      newStateCtx.set(
        'artistCredit',
        runArtistCreditReducer(state.artistCredit, action),
      );
    }
  }
  return newStateCtx.final();
}

component SplitArtistForm(
  artist: ArtistT,
  artistCredit: ArtistCreditT,
  collaborators: $ReadOnlyArray<ArtistT>,
  form as initialForm: EditArtistCreditFormT,
) {
  const [state, dispatch] = React.useReducer(
    reducer,
    {artistCredit, form: initialForm},
    createInitialState,
  );

  const artistCreditEditorDispatch = React.useCallback((
    action: ArtistCreditActionT,
  ) => {
    dispatch({action, type: 'update-artist-credit'});
  }, [dispatch]);

  return (
    <form method="post">
      <div className="half-width">
        <p>
          {exp.l(
            `This form allows you to split {artist} into separate artists.
              When the edit is accepted, existing artist credits will be
              updated, and collaboration relationships will be removed.`,
            {artist: <EntityLink entity={artist} />},
          )}
        </p>

        {collaborators.length ? (
          <>
            <h3>{addColonText(l('Collaborators on this artist'))}</h3>
            <ul>
              {collaborators.map((collaborator, index) => (
                <li key={index}>
                  <EntityLink entity={collaborator} />
                </li>
              ))}
            </ul>
          </>
        ) : null}

        <fieldset>
          <legend>{l('New artist credit')}</legend>
          <FormRow>
            <label className="required" htmlFor="ac-source-single-artist">
              {addColonText(l('Artist'))}
            </label>
            <ArtistCreditEditor
              dispatch={artistCreditEditorDispatch}
              state={state.artistCredit}
            />
          </FormRow>
        </fieldset>

        <EnterEditNote field={state.form.field.edit_note} />
        <EnterEdit form={state.form} />
      </div>
    </form>
  );
}

export default (hydrate<React.PropsOf<SplitArtistForm>>(
  'div.split-artist-form',
  SplitArtistForm,
): component(...React.PropsOf<SplitArtistForm>));
