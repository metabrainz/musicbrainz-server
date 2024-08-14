/*
 * @flow strict
 * Copyright (C) 2016 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {ArtistAutocomplete} from '../../common/components/Autocomplete2.js';
import type {
  ActionT as AutocompleteActionT,
} from '../../common/components/Autocomplete2/types.js';
import clean from '../../common/utility/clean.js';

import type {
  ActionT,
  ArtistCreditNameStateT,
} from './ArtistCreditEditor/types.js';

component _ArtistCreditNameEditor(
  allowMoveDown: boolean,
  allowMoveUp: boolean,
  allowRemoval: boolean,
  artistCreditEditorId: string,
  dispatch: (ActionT) => void,
  index: number,
  name as artistCreditName: ArtistCreditNameStateT,
  showMoveButtons: boolean,
) {
  const artistDispatch = React.useCallback((
    action: AutocompleteActionT<ArtistT>,
  ) => {
    dispatch({
      action,
      index,
      type: 'edit-artist',
    });
  }, [dispatch, index]);

  function handleNameBlur(
    event: SyntheticEvent<HTMLInputElement>,
  ): void {
    let newName = clean(event.currentTarget.value);

    const artist = artistCreditName.artist.selectedItem?.entity;
    if (newName === '' && artist) {
      newName = artist.name;
    }

    dispatch({
      index,
      name: newName,
      type: 'edit-name',
    });
  }

  function handleNameChange(
    event: SyntheticKeyboardEvent<HTMLInputElement>,
  ): void {
    dispatch({
      index,
      name: event.currentTarget.value,
      type: 'edit-name',
    });
  }

  function handleJoinPhraseBlur(
    event: SyntheticEvent<HTMLInputElement>,
  ): void {
    if (!artistCreditName.automaticJoinPhrase) {
      return;
    }

    /*
     * This is the first value the user has entered into this field.
     * If it is a simple word (such as "and") or an abbreviation (such
     * as "feat.") it is likely that it should be surrounded by spaces.
     * Add those spaces automatically only this first time. Also
     * standardise "feat." according to our guidelines.
     */
    const currentJoinPhrase = event.currentTarget.value;

    let joinPhrase = clean(currentJoinPhrase);
    joinPhrase = joinPhrase.replace(/^\s*(feat\.?|ft\.?|featuring)\s*$/i, 'feat.');

    if (/^[A-Za-z]+\.?$/.test(joinPhrase)) {
      joinPhrase = ' ' + joinPhrase + ' ';
    } else if (/^,$/.test(joinPhrase)) {
      joinPhrase = ', ';
    } else if (/^&$/.test(joinPhrase)) {
      joinPhrase = ' & ';
    } else if (/^;$/.test(joinPhrase)) {
      joinPhrase = '; ';
    }

    if (joinPhrase !== currentJoinPhrase) {
      dispatch({
        index,
        joinPhrase,
        type: 'edit-name',
      });
    }
  }

  function handleJoinPhraseChange(
    event: SyntheticKeyboardEvent<HTMLInputElement>,
  ): void {
    // The join phrase has been changed, it should no longer be automatic.
    dispatch({
      automaticJoinPhrase: false,
      index,
      joinPhrase: event.currentTarget.value,
      type: 'edit-name',
    });
  }

  function handleMoveDown() {
    dispatch({
      index,
      type: 'move-name-down',
    });
  }

  function handleMoveUp() {
    dispatch({
      index,
      type: 'move-name-up',
    });
  }

  function handleRemove() {
    if (!artistCreditName.removed) {
      dispatch({
        index,
        type: 'remove-name',
      });
    }
  }

  function handleUndo() {
    if (artistCreditName.removed) {
      dispatch({
        index,
        type: 'undo-remove-name',
      });
    }
  }

  return (
    <tr>
      {artistCreditName.removed ? (
        <td className="removed-ac-name" colSpan="3">
          {lp('[removed]', 'artist credit name')}
        </td>
      ) : (
        <>
          <td>
            <ArtistAutocomplete
              dispatch={artistDispatch}
              state={artistCreditName.artist}
            />
          </td>
          <td>
            <input
              id={'ac-' + artistCreditEditorId + '-credited-as-' +
                  String(index)}
              onBlur={handleNameBlur}
              onChange={handleNameChange}
              type="text"
              value={artistCreditName.name ?? ''}
            />
          </td>
          <td>
            <input
              id={'ac-' + artistCreditEditorId + '-join-phrase-' +
                  String(index)}
              onBlur={handleJoinPhraseBlur}
              onChange={handleJoinPhraseChange}
              type="text"
              value={artistCreditName.joinPhrase ?? ''}
            />
          </td>
        </>
      )}
      <td>
        {showMoveButtons ? (
          <button
            className="icon move-down"
            disabled={!allowMoveDown}
            onClick={handleMoveDown}
            title={lp('Move artist credit down', 'interactive')}
            type="button"
          />
        ) : null}
      </td>
      <td>
        {showMoveButtons ? (
          <button
            className="icon move-up"
            disabled={!allowMoveUp}
            onClick={handleMoveUp}
            title={lp('Move artist credit up', 'interactive')}
            type="button"
          />
        ) : null}
      </td>
      <td className="align-right">
        {artistCreditName.removed ? (
          <button
            className="icon undo"
            onClick={handleUndo}
            title={lp('Undo artist credit removal', 'interactive')}
            type="button"
          />
        ) : allowRemoval ? (
          <button
            className="icon remove-item remove-artist-credit"
            onClick={handleRemove}
            title={lp('Remove artist credit', 'interactive')}
            type="button"
          />
        ) : null}
      </td>
    </tr>
  );
}

const ArtistCreditNameEditor: React.AbstractComponent<
  React.PropsOf<_ArtistCreditNameEditor>
> = React.memo(_ArtistCreditNameEditor);

export default ArtistCreditNameEditor;
