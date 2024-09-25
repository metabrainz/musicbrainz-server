/*
 * @flow strict-local
 * Copyright (C) 2016 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';
import mutate, {type CowContext} from 'mutate-cow';
import * as React from 'react';

import {
  ArtistAutocomplete,
  createInitialState as createInitialAutocompleteState,
} from '../../common/components/Autocomplete2.js';
import {
  default as autocompleteReducer,
  generateItems as generateAutocompleteItems,
} from '../../common/components/Autocomplete2/reducer.js';
import type {
  ActionT as AutocompleteActionT,
} from '../../common/components/Autocomplete2/types.js';
import ButtonPopover from '../../common/components/ButtonPopover.js';
import {createArtistObject} from '../../common/entity2.js';
import {
  reduceArtistCreditNames,
} from '../../common/immutable-entities.js';
import {uniqueId} from '../../common/utility/numbers.js';
import {localStorage} from '../../common/utility/storage.js';

import type {
  ActionT,
  ArtistCreditableT,
  ArtistCreditNameStateT,
  StateT,
} from './ArtistCreditEditor/types.js';
import {
  artistCreditStateToString,
  incompleteArtistCreditFromState,
  isArtistCreditStateComplete,
} from './ArtistCreditEditor/utilities.js';
import ArtistCreditBubble from './ArtistCreditBubble.js';

function isNameRemoved(name: ArtistCreditNameStateT): boolean {
  return name.removed;
}

function isNameNotRemoved(name: ArtistCreditNameStateT): boolean {
  return !name.removed;
}

function setAutoJoinPhrases(
  namesCtx: CowContext<$ReadOnlyArray<ArtistCreditNameStateT>>,
): void {
  const names = namesCtx.read();

  const nonRemovedIndexes = names.reduce((
    accum: Array<number>,
    credit: ArtistCreditNameStateT,
    index: number,
  ) => {
    if (!credit.removed) {
      accum.push(index);
    }
    return accum;
  }, []);
  const size = nonRemovedIndexes.length;
  const auto = /^(| & |, )$/;

  if (size > 0) {
    const index = nonRemovedIndexes[size - 1];
    const name0 = names[index];
    if (name0 && name0.automaticJoinPhrase !== false) {
      namesCtx.set(index, 'joinPhrase', '');
    }
  }

  if (size > 1) {
    const index = nonRemovedIndexes[size - 2];
    const name1 = names[index];
    if (name1 && name1.automaticJoinPhrase !== false &&
        auto.test(name1.joinPhrase)) {
      namesCtx.set(index, 'joinPhrase', ' & ');
    }
  }

  if (size > 2) {
    const index = nonRemovedIndexes[size - 3];
    const name2 = names[index];
    if (name2 && name2.automaticJoinPhrase !== false &&
        auto.test(name2.joinPhrase)) {
      namesCtx.set(index, 'joinPhrase', ', ');
    }
  }
}

function removeRemovedCredits(stateCtx: CowContext<StateT>): void {
  const {id, names} = stateCtx.read();
  if (names.some(isNameRemoved)) {
    const namesCtx = stateCtx.get('names');
    namesCtx.set(names.filter(isNameNotRemoved));
    const totalNames = stateCtx.read().names.length;
    for (let i = 0; i < totalNames; i++) {
      namesCtx.set(i, 'artist', 'id', getArtistCreditNameInputId(id, i));
    }
    if (!names.length) {
      addEmptyCredit(stateCtx);
    }
  }
}

function getArtistCreditNameInputId(
  artistCreditEditorId: string,
  index: number,
): string {
  return 'ac-' + artistCreditEditorId + '-artist-' + String(index);
}

function getEmptyArtistCreditNameState(
  artistCreditEditorId: string,
  index: number,
): ArtistCreditNameStateT {
  const key = uniqueId();
  return {
    artist: createInitialAutocompleteState<ArtistT>({
      entityType: 'artist',
      id: getArtistCreditNameInputId(artistCreditEditorId, index),
    }),
    automaticJoinPhrase: true,
    joinPhrase: '',
    key,
    name: '',
    removed: false,
  };
}

function addEmptyCredit(stateCtx: CowContext<StateT>) {
  const namesCtx = stateCtx.get('names');
  namesCtx.write().push(getEmptyArtistCreditNameState(
    stateCtx.read().id,
    namesCtx.read().length,
  ));
  setAutoJoinPhrases(namesCtx);
}

function swapCredits(
  stateCtx: CowContext<StateT>,
  i: number,
  j: number,
) {
  const tmpName = stateCtx.read().names[i];
  stateCtx.set('names', i, stateCtx.read().names[j]);
  stateCtx.set('names', j, tmpName);

  // Preserve join phrase positions if neither credit is removed.
  const names = stateCtx.read().names;
  if (!names[i].removed && !names[j].removed) {
    const tmpJoinPhrase = names[i].joinPhrase;
    stateCtx.set('names', i, 'joinPhrase', names[j].joinPhrase);
    stateCtx.set('names', j, 'joinPhrase', tmpJoinPhrase);
  }
}

export function closeDialog(
  stateCtx: CowContext<StateT>,
): void {
  stateCtx.set('isOpen', false);
  removeRemovedCredits(stateCtx);
}

export function reducer(
  state: StateT,
  action: ActionT,
): StateT {
  const stateCtx = mutate(state);
  const names = state.names;

  switch (action.type) {
    case 'copy': {
      const artistCredit = incompleteArtistCreditFromState(names);
      localStorage('copiedArtistCredit', JSON.stringify(artistCredit));
      break;
    }

    case 'open-dialog':
      stateCtx
        .set('isOpen', true)
        .set('changeMatchingTrackArtists', false)
        .set('initialArtistCreditString',
             artistCreditStateToString(names))
        .set('initialBubbleFocus', action.initialFocus);
      break;

    case 'close-dialog': {
      closeDialog(stateCtx);
      break;
    }

    case 'add-name': {
      addEmptyCredit(stateCtx);
      break;
    }

    case 'update-single-artist-autocomplete': {
      stateCtx.set('singleArtistAutocomplete', autocompleteReducer<ArtistT>(
        state.singleArtistAutocomplete,
        action.action,
      ));
      break;
    }

    case 'edit-artist': {
      const {index, action: origAction} = action;

      stateCtx.update('names', index, (nameCtx) => {
        const name = nameCtx.read();
        const prevInputValue = name.artist.inputValue;
        const artistAutocomplete = autocompleteReducer<ArtistT>(
          name.artist,
          origAction,
        );
        nameCtx.set('artist', artistAutocomplete);
        if (
          (name.name === prevInputValue) ||
          (artistAutocomplete.selectedItem && empty(name.name))
        ) {
          nameCtx.set('name', artistAutocomplete.inputValue);
        }
      });

      break;
    }

    case 'edit-name': {
      // eslint-disable-next-line no-unused-vars
      const {index, type, ...editData} = action;

      stateCtx.update('names', index, (nameCtx) => {
        if (editData.automaticJoinPhrase != null) {
          nameCtx.set('automaticJoinPhrase', editData.automaticJoinPhrase);
        }

        if (editData.joinPhrase != null) {
          nameCtx.set('joinPhrase', editData.joinPhrase);
        }

        if (editData.name != null) {
          nameCtx.set('name', editData.name);
        }

        const {artist, name} = nameCtx.read();
        if (!artist.selectedItem && artist.inputValue !== name) {
          nameCtx.set('artist', autocompleteReducer<ArtistT>(artist, {
            type: 'type-value',
            value: name,
          }));
        }
      });

      break;
    }

    case 'move-name-down': {
      if (action.index < names.length - 1) {
        swapCredits(stateCtx, action.index, action.index + 1);
      }
      break;
    }

    case 'move-name-up': {
      if (action.index > 0) {
        swapCredits(stateCtx, action.index, action.index - 1);
      }
      break;
    }

    case 'remove-name': {
      const nonRemovedCount = state.names.reduce((accum, name) => {
        return accum + (name.removed ? 0 : 1);
      }, 0);
      const namesCtx = stateCtx.get('names');
      if (nonRemovedCount > 1) {
        namesCtx.set(action.index, 'removed', true);
        setAutoJoinPhrases(namesCtx);
      }
      break;
    }

    case 'undo-remove-name': {
      const namesCtx = stateCtx.get('names');
      namesCtx.set(action.index, 'removed', false);
      setAutoJoinPhrases(namesCtx);
      break;
    }

    case 'paste': {
      try {
        const copiedArtistCreditString = localStorage('copiedArtistCredit');
        if (copiedArtistCreditString != null) {
          const artistCredit = JSON.parse(copiedArtistCreditString);
          stateCtx.set(
            'names',
            createInitialNamesState(
              artistCredit,
              state.id,
              /* automaticJoinPhrase = */ false,
            ),
          );
          if (!stateCtx.read().names.length) {
            addEmptyCredit(stateCtx);
          }
        }
      } catch (e) {
        console.error(e);
      }
      break;
    }

    case 'set-names-from-artist-credit': {
      let artistCredit = action.artistCredit;
      const artistCreditCtx = mutate(artistCredit);
      for (let i = 0; i < artistCredit.names.length; i++) {
        const name = artistCredit.names[i];
        if (!name.artist) {
          artistCreditCtx.set(
            'names', i, 'artist', createArtistObject({name: name.name}),
          );
        }
      }
      // $FlowIgnore[incompatible-cast] - null artists were filled in
      artistCredit = (artistCreditCtx.final(): ArtistCreditT);
      stateCtx.set('names',
                   createInitialNamesState(artistCredit, state.id));
      break;
    }

    case 'next-track':
    case 'previous-track':
    case 'set-change-matching-artists': {
      invariant(false);
    }
  }

  const newState = stateCtx.read();
  const newSingleArtistAutocomplete =
    newState.singleArtistAutocomplete;
  const newNames = newState.names;

  if (
    state.singleArtistAutocomplete !== newSingleArtistAutocomplete &&
    isSingleArtistEditableInState(state.names)
  ) {
    stateCtx.update('names', 0, (nameCtx) => {
      const artistName = newSingleArtistAutocomplete.inputValue;
      nameCtx
        .set('name', artistName)
        .set('joinPhrase', '')
        .get('artist')
        .set('selectedItem', newSingleArtistAutocomplete.selectedItem)
        .set('inputValue', artistName);
    });
  } else if (names !== newNames) {
    if (isSingleArtistEditableInState(newNames)) {
      const firstNameAutocomplete = newNames[0].artist;
      stateCtx.get('singleArtistAutocomplete')
        .set('disabled', false)
        .set('selectedItem', firstNameAutocomplete.selectedItem)
        .set('inputValue', firstNameAutocomplete.inputValue)
        .update((ctx) => {
          ctx.set('items', generateAutocompleteItems(ctx.read()));
        });
    } else {
      stateCtx.get('singleArtistAutocomplete')
        .set('disabled', true)
        .set('selectedItem', null)
        .set('inputValue', artistCreditStateToString(newNames));
    }
  }

  stateCtx.get('singleArtistAutocomplete')
    .set('isLookupPerformed', isArtistCreditStateComplete(newState.names));

  return stateCtx.final();
}

function isSingleArtistEditableInState(
  names: $ReadOnlyArray<ArtistCreditNameStateT>,
): boolean {
  if (names.filter(isNameNotRemoved).length === 1) {
    const firstArtist = names[0].artist.selectedItem?.entity;
    return !(
      firstArtist &&
      firstArtist.name !== artistCreditStateToString(names)
    );
  }
  return false;
}

function createInitialNamesState(
  artistCredit: IncompleteArtistCreditT,
  artistCreditEditorId: string,
  automaticJoinPhrase?: boolean = true,
): $ReadOnlyArray<ArtistCreditNameStateT> {
  const names = artistCredit.names;

  if (!names.length) {
    return [getEmptyArtistCreditNameState(artistCreditEditorId, 0)];
  }

  return names.map((name, index) => {
    const key = uniqueId();
    const artist = name.artist;
    let artistName = '';
    let selectedItem = null;
    if (artist != null) {
      artistName = artist.name;
      if (artist.id) {
        selectedItem = {
          entity: artist,
          id: artist.id,
          name: artistName,
          type: 'option',
        };
      }
    }
    return {
      artist: createInitialAutocompleteState<ArtistT>({
        containerClass: 'artist-credit-editor',
        entityType: 'artist',
        id: getArtistCreditNameInputId(artistCreditEditorId, index),
        inputValue: artistName,
        selectedItem,
      }),
      automaticJoinPhrase,
      joinPhrase: name.joinPhrase ?? '',
      key,
      name: name.name || artistName,
      removed: false,
    };
  });
}

export function createInitialState(
  initialState: {
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

component _ArtistCreditEditor(
  dispatch: (ActionT) => void,
  state: StateT,
) {
  const {
    entity,
    formName,
    isOpen,
    names,
    singleArtistAutocomplete,
  } = state;

  // For the single-artist autocomplete.
  const firstArtistDispatch = React.useCallback((
    action: AutocompleteActionT<ArtistT>,
  ) => {
    dispatch({
      action,
      type: 'update-single-artist-autocomplete',
    });
  }, [dispatch]);

  const hiddenInputsPrefix = nonEmpty(formName) ? (
    formName + '.artist_credit.names.'
  ) : '';

  const buildPopoverChildren = React.useCallback((
    closeAndReturnFocus: () => void,
    initialFocusRef: {-current: HTMLElement | null},
  ) => (
    <ArtistCreditBubble
      closeAndReturnFocus={closeAndReturnFocus}
      dispatch={dispatch}
      initialFocusRef={initialFocusRef}
      state={state}
    />
  ), [dispatch, state]);

  const toggleDialog = React.useCallback((open: boolean) => {
    if (open) {
      dispatch({type: 'open-dialog'});
    } else {
      dispatch({type: 'close-dialog'});
    }
  }, [dispatch]);

  const buttonProps = React.useMemo(() => ({
    className: 'open-ac',
    id: 'open-ac-' + String(entity.id),
  }), [entity.id]);

  return (
    <>
      <ArtistAutocomplete
        dispatch={firstArtistDispatch}
        state={singleArtistAutocomplete}
      >
        <ButtonPopover
          buildChildren={buildPopoverChildren}
          buttonContent={lp('Edit', 'verb, interactive')}
          buttonProps={buttonProps}
          id="artist-credit-bubble"
          isOpen={isOpen}
          toggle={toggleDialog}
        />
      </ArtistAutocomplete>

      {hiddenInputsPrefix ? (
        names.filter(isNameNotRemoved).map(function (name, i) {
          const curPrefix = hiddenInputsPrefix + i + '.';
          const artistAutocomplete = name.artist;
          const artist = artistAutocomplete.selectedItem?.entity;
          return (
            <React.Fragment key={curPrefix}>
              <input
                name={curPrefix + 'name'}
                type="hidden"
                value={name.name ?? ''}
              />
              <input
                name={curPrefix + 'join_phrase'}
                type="hidden"
                value={name.joinPhrase ?? ''}
              />
              <input
                name={curPrefix + 'artist.name'}
                type="hidden"
                value={(artist?.name) ?? artistAutocomplete.inputValue}
              />
              <input
                name={curPrefix + 'artist.id'}
                type="hidden"
                value={String((artist?.id) ?? '')}
              />
            </React.Fragment>
          );
        })
      ) : null}
    </>
  );
}

const ArtistCreditEditor: React.AbstractComponent<
  React.PropsOf<_ArtistCreditEditor>
> = React.memo(_ArtistCreditEditor);

export default ArtistCreditEditor;
