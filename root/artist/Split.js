/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import EntityLink
  from '../static/scripts/common/components/EntityLink.js';
import entityHref from '../static/scripts/common/utility/entityHref.js';
import ArtistCreditEditor, {
  reducer as runArtistCreditReducer,
} from '../static/scripts/edit/components/ArtistCreditEditor.js';
import type {
  StateT as ArtistCreditStateT,
} from '../static/scripts/edit/components/ArtistCreditEditor/types.js';
import EnterEdit from '../static/scripts/edit/components/EnterEdit.js';
import EnterEditNote
  from '../static/scripts/edit/components/EnterEditNote.js';

import ArtistLayout from './ArtistLayout.js';

type EditArtistCreditFormT = FormT<{
  +artist_credit: FieldT<ArtistCreditT>,
  +edit_note: FieldT<string>,
  +make_votable: FieldT<boolean>,
  +preview: FieldT<string>,
}>;

type StateT = {
  +artistCredit: ArtistCreditStateT,
  +form: EditArtistCreditFormT,
};

function createInitialState(
  initialState: {
    +activeUser: ActiveEditorT,
    +entity: ArtistCreditableT,
    +formName?: string,
    /*
     * `id` should uniquely identify the artist credit editor instance
     * on the page. (Note: Using the entity ID may not suffice, as some
     * releases will repeat the same recording!)
     */
    +id: string,
    +isOpen?: boolean,
  },
): StateT {
  const {
    entity,
    id,
    isOpen = false,
    ...otherState
  } = initialState;
  const artistCredit: ?ArtistCreditT = ko.unwrap(entity.artistCredit);

  invariant(artistCredit);

  const names = createInitialNamesState(artistCredit, id);
  const isSingleArtistEditable = isSingleArtistEditableInState(names);

  return {
    artistCreditString: '',
    changeMatchingTrackArtists: false,
    entity,
    id,
    initialArtistCreditString: '',
    isOpen,
    names,
    singleArtistAutocomplete: createInitialAutocompleteState<ArtistT>({
      containerClass: 'artist-credit-editor',
      disabled: isOpen || !isSingleArtistEditable,
      entityType: 'artist',
      id: 'ac-' + id + '-single-artist',
      inputValue: reduceArtistCreditNames(artistCredit.names),
      isLookupPerformed: isArtistCreditStateComplete(names),
      selectedItem: (
        isSingleArtistEditable
          ? names[0].artist.selectedItem
          : null
      ),
    }),
    ...otherState,
  };
}

function reducer(state: StateT, action: ActionT): StateT {
  const newStateCtx = mutate(state);

  switch (action.type) {
    case 'update-artist-credit': {
      newStateCtx.set(
        'artistCredit',
        runArtistCreditReducer(state.artistCredit, action.action),
      );
      break;
    }
    default: {
      /*:: exhaustive(action); */
    }
  }
  return newStateCtx.final();
}

component Split(
  artist: ArtistT,
  collaborators: $ReadOnlyArray<ArtistT>,
  form: EditArtistCreditFormT,
  inUse: boolean,
) {
  const [state, dispatch] = React.useReducer(
    reducer,
    createInitialState(initialForm),
  );

  const artistCreditEditorDispatch = React.useCallback((
    action: ArtistCreditActionT,
  ) => {
    dispatch({action, type: 'update-artist-credit'});
  }, [dispatch]);

  return (
    <ArtistLayout
      entity={artist}
      fullWidth
      page="split"
      title={l('Split artist')}
    >
      <h2>{l('Split into separate artists')}</h2>

      {inUse ? (
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
              <ArtistCreditEditor
                dispatch={artistCreditEditorDispatch}
                state={state.artistCredit}
              />
            </fieldset>

            <EnterEditNote field={form.field.edit_note} />

            <EnterEdit form={form} />
          </div>
        </form>
      ) : (
        <p>
          {exp.l(
            `There are no recordings, release groups, releases or tracks
             credited to only {name}. If you are trying to remove {name},
             please edit all artist credits at the bottom of the
             {alias_uri|aliases} tab and remove all existing
             {rel_uri|relationships} instead, which will allow ModBot
             to automatically remove this artist in the upcoming days.`,
            {
              alias_uri: entityHref(artist, 'aliases'),
              name: <EntityLink entity={artist} />,
              rel_uri: entityHref(artist, 'relationships'),
            },
          )}
        </p>
      )}
    </ArtistLayout>
  );
}

export default Split;
