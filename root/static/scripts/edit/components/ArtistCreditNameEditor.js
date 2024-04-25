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

type PropsT = {
  +artistCreditEditorId: string,
  +dispatch: (ActionT) => void,
  +index: number,
  +name: ArtistCreditNameStateT,
};

const ArtistCreditNameEditor = (React.memo<PropsT>(({
  artistCreditEditorId,
  dispatch,
  index,
  name: artistCreditName,
}: PropsT): React.MixedElement => {
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
      <td className="align-right">
        {artistCreditName.removed ? (
          <button
            className="icon undo"
            onClick={handleUndo}
            title={lp('Undo artist credit removal', 'interactive')}
            type="button"
          />
        ) : (
          <button
            className="icon remove-item remove-artist-credit"
            onClick={handleRemove}
            title={lp('Remove artist credit', 'interactive')}
            type="button"
          />
        )}
      </td>
    </tr>
  );
}): React.AbstractComponent<PropsT>);

export default ArtistCreditNameEditor;
