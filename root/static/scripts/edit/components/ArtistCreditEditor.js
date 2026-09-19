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

import Autocomplete2, {
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
import {arraysEqual} from '../../common/utility/arrays.js';
import clean from '../../common/utility/clean.js';
import isDatabaseRowId from '../../common/utility/isDatabaseRowId.js';
import {localStorage} from '../../common/utility/storage.js';
import {
  createCompoundField,
  createField,
  createRepeatableField,
} from '../utility/createField.js';
import {applyAllPendingErrors} from '../utility/subfieldErrors.js';

import type {
  ActionT,
  ArtistCreditableT,
  ArtistCreditNameStateT,
  StateT,
} from './ArtistCreditEditor/types.js';
import {
  artistCreditStateToString,
  getArtist,
  getArtistCreditNames,
  getArtistCreditNamesCtx,
  getJoinPhrase,
  incompleteArtistCreditFromState,
  isArtistCreditStateComplete,
  isNameNotRemoved,
  isNameRemoved,
  setCreditedName,
  setJoinPhrase,
} from './ArtistCreditEditor/utilities.js';
import ArtistCreditBubble from './ArtistCreditBubble.js';
import {HiddenFields} from './HiddenField.js';

function createArtistCreditNameField(
  creditedName: string,
  joinPhrase: string,
): ArtistCreditNameFieldT {
  // `html_name`s are assigned by `updateArtistCreditFieldData`.
  return createCompoundField('', {
    artist: createCompoundField('', {
      id: createField<string | null>('', null),
      name: createField('', ''),
    }),
    join_phrase: createField('', joinPhrase),
    name: createField('', creditedName),
  });
}

export function artistCreditFromField(
  field: ArtistCreditFieldT | StateT,
  artistsById?: ?{readonly [id: string]: ArtistT},
): IncompleteArtistCreditT {
  return {
    names: field.field.names.field.map((name) => {
      const {
        artist: artistField,
        join_phrase: joinPhraseField,
        name: creditedNameField,
      } = name.field;
      const artistId = artistField.field.id.value;
      const artistName = artistField.field.name.value;
      const creditedName = creditedNameField.value;
      let artist = null;
      if (nonEmpty(artistName) || nonEmpty(creditedName)) {
        artist = (
          nonEmpty(artistId)
            ? artistsById?.[String(artistId)]
            : null
        ) ?? createArtistObject({name: artistName});
      }
      return {
        artist,
        joinPhrase: joinPhraseField.value,
        name: creditedName,
      };
    }),
  };
}

function setPendingFieldErrors(
  fieldCtx: CowContext<AnyFieldT>,
  pendingErrors: ReadonlyArray<string>,
): void {
  const field = fieldCtx.read();
  const unfixedErrors = field.errors.filter(
    (error) => pendingErrors.includes(error),
  );
  if (unfixedErrors.length !== field.errors.length) {
    fieldCtx.set('errors', unfixedErrors);
  }
  if (!arraysEqual(field.pendingErrors ?? [], pendingErrors)) {
    fieldCtx.set('pendingErrors', pendingErrors);
  }
  fieldCtx.set('has_errors', pendingErrors.length > 0);
}

/*
 * Updates the artist subfields and `html_name`s of a credit, and validates
 * it. Please keep the validation in sync with
 * `MusicBrainz::Server::Form::Field::ArtistCredit`.
 */
function updateArtistCreditFieldData(
  stateCtx: CowContext<StateT>,
): void {
  const namesCtx = stateCtx.get('field', 'names');
  const {
    html_name: namesHtmlName,
    field: {length: totalNames},
  } = namesCtx.read();
  let totalSubmittedNames = 0;
  let totalArtists = 0;
  let hasCreditErrors = false;

  for (let index = 0; index < totalNames; index++) {
    const nameCtx = namesCtx.get('field', index);
    const name = nameCtx.read();

    if (name.removed) {
      setPendingFieldErrors(nameCtx, []);
      continue;
    }

    const nameHtmlName = namesHtmlName + '.' + String(totalSubmittedNames);
    const artistHtmlName = nameHtmlName + '.artist';
    const artist = getArtist(name);
    const artistName = name.artist.inputValue;
    const creditedName = clean(name.field.name.value) || artistName;

    nameCtx.merge({
      field: {
        artist: {
          field: {
            id: {
              html_name: artistHtmlName + '.id',
              value: artist == null ? null : String(artist.id),
            },
            name: {
              html_name: artistHtmlName + '.name',
              value: artistName,
            },
          },
          html_name: artistHtmlName,
        },
        join_phrase: {html_name: nameHtmlName + '.join_phrase'},
        name: {html_name: nameHtmlName + '.name'},
      },
      html_name: nameHtmlName,
    });

    const errors = [];
    if (artist != null && nonEmpty(creditedName)) {
      totalArtists++;
    } else if (empty(creditedName)) {
      errors.push(l('Please add an artist name for each credit.'));
    } else if (empty(artistName)) {
      errors.push(texp.l(
        'Please add an artist name for {credit}',
        {credit: creditedName},
      ));
    } else {
      errors.push(texp.l(
        `Artist "{artist}" is unlinked, please select an existing artist.
         You may need to add a new artist to MusicBrainz first.`,
        {artist: creditedName},
      ));
    }
    setPendingFieldErrors(nameCtx, errors);
    hasCreditErrors ||= (errors.length > 0);
    totalSubmittedNames++;
  }

  namesCtx.set('last_index', totalSubmittedNames - 1);

  setPendingFieldErrors(
    stateCtx,
    (totalArtists || hasCreditErrors)
      ? []
      : [l('Artist credit field is required')],
  );
}

function setAutoJoinPhrases(
  namesCtx: CowContext<ReadonlyArray<ArtistCreditNameStateT>>,
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
      setJoinPhrase(namesCtx.get(index), '');
    }
  }

  if (size > 1) {
    const index = nonRemovedIndexes[size - 2];
    const name1 = names[index];
    if (name1 && name1.automaticJoinPhrase !== false &&
        auto.test(getJoinPhrase(name1))) {
      setJoinPhrase(namesCtx.get(index), ' & ');
    }
  }

  if (size > 2) {
    const index = nonRemovedIndexes[size - 3];
    const name2 = names[index];
    if (name2 && name2.automaticJoinPhrase !== false &&
        auto.test(getJoinPhrase(name2))) {
      setJoinPhrase(namesCtx.get(index), ', ');
    }
  }
}

function removeRemovedCredits(stateCtx: CowContext<StateT>): void {
  const namesCtx = getArtistCreditNamesCtx(stateCtx);
  const names = namesCtx.read();
  if (names.some(isNameRemoved)) {
    namesCtx.set(names.filter(isNameNotRemoved));
    const htmlId = stateCtx.read().htmlId;
    const totalNames = namesCtx.read().length;
    for (let i = 0; i < totalNames; i++) {
      namesCtx.set(i, 'artist', 'id', getArtistCreditNameInputId(htmlId, i));
    }
    if (!totalNames) {
      addEmptyCredit(stateCtx);
    }
  }
}

function getArtistCreditNameInputId(
  htmlId: string,
  index: number,
): string {
  return 'ac-' + htmlId + '-artist-' + String(index);
}

function getEmptyArtistCreditNameState(
  htmlId: string,
  index: number,
): ArtistCreditNameStateT {
  return {
    ...createArtistCreditNameField('', ''),
    artist: createInitialAutocompleteState<ArtistT>({
      entityType: 'artist',
      id: getArtistCreditNameInputId(htmlId, index),
    }),
    automaticJoinPhrase: true,
    removed: false,
  };
}

function addEmptyCredit(stateCtx: CowContext<StateT>) {
  const namesCtx = getArtistCreditNamesCtx(stateCtx);
  namesCtx.write().push(getEmptyArtistCreditNameState(
    stateCtx.read().htmlId,
    namesCtx.read().length,
  ));
  setAutoJoinPhrases(namesCtx);
}

function swapCredits(
  stateCtx: CowContext<StateT>,
  i: number,
  j: number,
) {
  const namesCtx = getArtistCreditNamesCtx(stateCtx);
  const tmpName = namesCtx.read()[i];
  namesCtx.set(i, namesCtx.read()[j]);
  namesCtx.set(j, tmpName);

  // Preserve join phrase positions if neither credit is removed.
  const names = namesCtx.read();
  if (!names[i].removed && !names[j].removed) {
    const tmpJoinPhrase = getJoinPhrase(names[i]);
    setJoinPhrase(namesCtx.get(i), getJoinPhrase(names[j]));
    setJoinPhrase(namesCtx.get(j), tmpJoinPhrase);
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
  const names = getArtistCreditNames(state);

  // If this action is updating a specific AC name, retrieve its index.
  let nameIndex = -1;
  if (action.nameFieldId != null) {
    nameIndex = names.findIndex(name => name.id === action.nameFieldId);
    if (nameIndex < 0) {
      return state;
    }
  }

  match (action) {
    {type: 'copy'} => {
      const artistCredit = incompleteArtistCreditFromState(names);
      localStorage('copiedArtistCredit', JSON.stringify(artistCredit));
    }
    {type: 'open-dialog', ...} as action => {
      stateCtx.merge({
        changeMatchingTrackArtists: false,
        initialArtistCreditString: artistCreditStateToString(names),
        initialBubbleFocus: action.initialFocus,
        isOpen: true,
      });
    }
    {type: 'close-dialog'} => {
      closeDialog(stateCtx);
    }
    {type: 'add-name'} => {
      addEmptyCredit(stateCtx);
    }
    {type: 'update-single-artist-autocomplete', const action} => {
      stateCtx.set('singleArtistAutocomplete', autocompleteReducer<ArtistT>(
        state.singleArtistAutocomplete,
        action,
      ));
    }
    {type: 'edit-artist', const action, ...} => {
      const origAction = action;

      getArtistCreditNamesCtx(stateCtx).update(nameIndex, (nameCtx) => {
        const name = nameCtx.read();
        const creditedName = name.field.name.value;
        const prevInputValue = name.artist.inputValue;
        const artistAutocomplete = autocompleteReducer<ArtistT>(
          name.artist,
          origAction,
        );
        nameCtx.set('artist', artistAutocomplete);
        if (
          (creditedName === prevInputValue) ||
          (artistAutocomplete.selectedItem && empty(creditedName))
        ) {
          setCreditedName(nameCtx, artistAutocomplete.inputValue);
        }
      });
    }
    {type: 'edit-name', ...} as action => {
      // eslint-disable-next-line no-unused-vars
      const {nameFieldId, type, ...editData} = action;

      getArtistCreditNamesCtx(stateCtx).update(nameIndex, (nameCtx) => {
        if (editData.automaticJoinPhrase != null) {
          nameCtx.set('automaticJoinPhrase', editData.automaticJoinPhrase);
        }

        if (editData.joinPhrase != null) {
          setJoinPhrase(nameCtx, editData.joinPhrase);
        }

        if (editData.name != null) {
          setCreditedName(nameCtx, editData.name);
        }

        const {artist, field: {name: {value: name}}} = nameCtx.read();
        if (!artist.selectedItem && artist.inputValue !== name) {
          nameCtx.set('artist', autocompleteReducer<ArtistT>(artist, {
            type: 'type-value',
            value: name,
          }));
        }
      });
    }
    {type: 'move-name-down', ...} => {
      if (nameIndex < names.length - 1) {
        swapCredits(stateCtx, nameIndex, nameIndex + 1);
      }
    }
    {type: 'move-name-up', ...} => {
      if (nameIndex > 0) {
        swapCredits(stateCtx, nameIndex, nameIndex - 1);
      }
    }
    {type: 'remove-name', ...} => {
      const nonRemovedCount = names.reduce((accum, name) => {
        return accum + (name.removed ? 0 : 1);
      }, 0);
      if (nonRemovedCount > 1) {
        const namesCtx = getArtistCreditNamesCtx(stateCtx);
        namesCtx.set(nameIndex, 'removed', true);
        setAutoJoinPhrases(namesCtx);
      }
    }
    {type: 'undo-remove-name', ...} => {
      const namesCtx = getArtistCreditNamesCtx(stateCtx);
      namesCtx.set(nameIndex, 'removed', false);
      setAutoJoinPhrases(namesCtx);
    }
    {type: 'paste'} => {
      try {
        const copiedArtistCreditString = localStorage('copiedArtistCredit');
        if (copiedArtistCreditString != null) {
          const artistCredit = JSON.parse(copiedArtistCreditString);
          getArtistCreditNamesCtx(stateCtx).set(createInitialNamesState(
            artistCredit,
            state.htmlId,
            /* automaticJoinPhrase = */ false,
          ));
          if (!getArtistCreditNames(stateCtx.read()).length) {
            addEmptyCredit(stateCtx);
          }
        }
      } catch (e) {
        console.error(e);
      }
    }
    {type: 'set-names-from-artist-credit', const artistCredit} => {
      let writableArtistCredit = artistCredit;
      const artistCreditCtx = mutate(writableArtistCredit);
      for (let i = 0; i < writableArtistCredit.names.length; i++) {
        const name = writableArtistCredit.names[i];
        if (!name.artist) {
          artistCreditCtx.set(
            'names', i, 'artist', createArtistObject({name: name.name}),
          );
        }
      }
      // $FlowFixMe[incompatible-type] - null artists were filled in
      writableArtistCredit = artistCreditCtx.final() as ArtistCreditT;
      getArtistCreditNamesCtx(stateCtx).set(
        createInitialNamesState(writableArtistCredit, state.htmlId),
      );
    }
    {
      type: 'next-track' | 'previous-track' | 'set-change-matching-artists',
      ...
    } => {
      invariant(false);
    }
  }

  let newState = stateCtx.read();
  const newSingleArtistAutocomplete =
    newState.singleArtistAutocomplete;
  const newNames = getArtistCreditNames(newState);

  if (
    state.singleArtistAutocomplete !== newSingleArtistAutocomplete &&
    isSingleArtistEditableInState(names)
  ) {
    getArtistCreditNamesCtx(stateCtx).update(0, (nameCtx) => {
      const artistName = newSingleArtistAutocomplete.inputValue;
      nameCtx.merge({
        artist: {
          inputValue: artistName,
          selectedItem: newSingleArtistAutocomplete.selectedItem,
        },
        field: {
          join_phrase: {value: ''},
          name: {value: artistName},
        },
      });
    });
  } else if (names !== newNames) {
    if (isSingleArtistEditableInState(newNames)) {
      const firstNameAutocomplete = newNames[0].artist;
      stateCtx.get('singleArtistAutocomplete')
        .merge({
          disabled: false,
          inputValue: firstNameAutocomplete.inputValue,
          selectedItem: firstNameAutocomplete.selectedItem,
        })
        .update((ctx) => {
          ctx.set('items', generateAutocompleteItems(ctx.read()));
        });
    } else {
      stateCtx.get('singleArtistAutocomplete').merge({
        disabled: true,
        inputValue: artistCreditStateToString(newNames),
        selectedItem: null,
      });
    }
  }

  stateCtx.get('singleArtistAutocomplete')
    .set('isLookupPerformed', isArtistCreditStateComplete(
      getArtistCreditNames(stateCtx.read()),
    ));

  updateArtistCreditFieldData(stateCtx);

  // Show pending errors if the bubble was closed.
  newState = stateCtx.read();
  if (state.isOpen && !newState.isOpen) {
    applyAllPendingErrors(stateCtx);
  }

  return stateCtx.final();
}

function isSingleArtistEditableInState(
  names: ReadonlyArray<ArtistCreditNameStateT>,
): boolean {
  if (names.filter(isNameNotRemoved).length === 1) {
    const firstArtist = getArtist(names[0]);
    return !(
      firstArtist &&
      firstArtist.name !== artistCreditStateToString(names)
    );
  }
  return false;
}

function createInitialNamesState(
  artistCredit: IncompleteArtistCreditT,
  htmlId: string,
  automaticJoinPhrase?: boolean = true,
  initialNameFields?: ?ReadonlyArray<
    ArtistCreditNameFieldT | ArtistCreditNameStateT,
  >,
): ReadonlyArray<ArtistCreditNameStateT> {
  const names = artistCredit.names;

  if (!names.length) {
    return [getEmptyArtistCreditNameState(htmlId, 0)];
  }

  return names.map((name, index) => {
    const artist = name.artist;
    let artistName = '';
    let selectedItem = null;
    if (artist != null) {
      artistName = artist.name;
      if (isDatabaseRowId(artist.id)) {
        selectedItem = {
          entity: artist,
          id: artist.id,
          name: artistName,
          type: 'option' as const,
        };
      }
    }
    const initialField = initialNameFields?.[index];
    return {
      ...(initialField ?? createArtistCreditNameField(
        name.name || artistName,
        name.joinPhrase ?? '',
      )),
      artist: createInitialAutocompleteState<ArtistT>({
        containerClass: 'artist-credit-editor',
        entityType: 'artist',
        id: getArtistCreditNameInputId(htmlId, index),
        inputValue: artistName,
        selectedItem,
      }),
      automaticJoinPhrase,
      removed: false,
    };
  });
}

export function createInitialState(
  initialState: {
    readonly artistCredit?: ArtistCreditT,
    readonly artistsById?: ?{readonly [id: string]: ArtistT},
    readonly entity?: ArtistCreditableT,
    readonly formName?: string,
    /*
     * `htmlId` should uniquely identify the artist credit editor instance
     * on the page. (Note: Using the entity ID may not suffice, as some
     * releases will repeat the same recording!)
     */
    readonly htmlId: string,
    /*
     * The artist credit field received from the server, which may contain
     * validation error strings from FormHandler.
     */
    readonly initialField?: ?(ArtistCreditFieldT | StateT),
    readonly isOpen?: boolean,
  },
): StateT {
  const {
    artistCredit: passedArtistCredit,
    artistsById,
    entity,
    formName,
    htmlId: passedHtmlId,
    initialField,
    isOpen = false,
  } = initialState;
  // Consider enforcing AC once we use Flow everywhere
  const artistCredit: ?IncompleteArtistCreditT = initialField
    ? artistCreditFromField(initialField, artistsById)
    : (passedArtistCredit ?? ko.unwrap(entity?.artistCredit));

  invariant(artistCredit);

  let field = initialField;
  if (!field) {
    const htmlName = nonEmpty(formName) ? formName + '.artist_credit' : '';
    field = createCompoundField(htmlName, {
      names: createRepeatableField<ArtistCreditNameFieldT>(
        htmlName + '.names',
        [],
      ),
    });
  }

  const htmlId = passedHtmlId == null
    ? String(field.id)
    : String(passedHtmlId);

  const names = createInitialNamesState(
    artistCredit,
    htmlId,
    /* automaticJoinPhrase = */ true,
    field.field.names.field,
  );
  const isSingleArtistEditable = isSingleArtistEditableInState(names);

  const stateCtx = mutate<StateT>({
    ...field,
    entity,
    field: {
      names: {
        ...field.field.names,
        field: names,
      },
    },
    htmlId,
    initialArtistCreditString: '',
    isOpen,
    singleArtistAutocomplete: createInitialAutocompleteState<ArtistT>({
      containerClass: 'artist-credit-editor',
      disabled: isOpen || !isSingleArtistEditable,
      entityType: 'artist',
      id: 'ac-' + htmlId + '-single-artist',
      inputValue: reduceArtistCreditNames(artistCredit.names),
      isLookupPerformed: isArtistCreditStateComplete(names),
      selectedItem: (
        isSingleArtistEditable
          ? names[0].artist.selectedItem
          : null
      ),
    }),
  });

  updateArtistCreditFieldData(stateCtx);

  return stateCtx.final();
}

component _ArtistCreditEditor(
  dispatch: (ActionT) => void,
  onFocus?: (event: SyntheticEvent<HTMLInputElement>) => void,
  state: StateT,
) {
  const {
    isOpen,
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

  const buildPopoverChildren = React.useCallback((
    closeAndReturnFocus: () => void,
    initialFocusRef: {writeonly current: HTMLElement | null},
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
    id: 'open-ac-' + state.htmlId,
  }), [state.htmlId]);

  return (
    <>
      <Autocomplete2
        dispatch={firstArtistDispatch}
        onFocus={onFocus}
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
      </Autocomplete2>

      {nonEmpty(state.html_name) ? (
        getArtistCreditNames(state).map((name) => (
          name.removed
            ? null
            : <HiddenFields field={name} key={name.id} />
        ))
      ) : null}
    </>
  );
}

const ArtistCreditEditor:
  component(...React.PropsOf<_ArtistCreditEditor>) =
    React.memo(_ArtistCreditEditor);

export default ArtistCreditEditor;
