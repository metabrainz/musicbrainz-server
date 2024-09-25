/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {
  ActionT as AutocompleteActionT,
  StateT as AutocompleteStateT,
} from '../../../common/components/Autocomplete2/types.js';
import type {ReleaseEditorTrackT} from '../../../release-editor/types.js';

export type ArtistCreditableT =
  | RecordingT
  | ReleaseT
  | ReleaseGroupT
  | ReleaseEditorTrackT;

export type ArtistCreditNameStateT = {
  +artist: AutocompleteStateT<ArtistT>,
  +automaticJoinPhrase: boolean,
  +joinPhrase: string,
  +key: number,
  +name: string,
  +removed: boolean,
};

export type StateT = {
  +artistCreditString: string,
  +changeMatchingTrackArtists?: boolean,
  +editsPending?: boolean,
  +entity: ArtistCreditableT,
  +formName?: string,
  +id: string,
  +initialArtistCreditString: string,
  +initialBubbleFocus?:
    | 'default'
    | 'next-track'
    | 'prev-track'
    | void,
  +isOpen: boolean,
  +names: $ReadOnlyArray<ArtistCreditNameStateT>,
  +singleArtistAutocomplete: AutocompleteStateT<ArtistT>,
};

/* eslint-disable ft-flow/sort-keys */
export type EditArtistActionT = {
  +type: 'edit-artist',
  +index: number,
  +action: AutocompleteActionT<ArtistT>,
};

export type EditNameActionT = {
  +type: 'edit-name',
  +index: number,
  +joinPhrase?: string,
  +name?: string,
  +automaticJoinPhrase?: boolean,
};

export type ActionT =
  | {
      +type: 'open-dialog',
      +initialFocus?: StateT['initialBubbleFocus'],
    }
  | {+type: 'close-dialog'}
  | {+type: 'toggle-dialog'}
  | {+type: 'add-name'}
  | {+type: 'move-name-down', +index: number}
  | {+type: 'move-name-up', +index: number}
  | {+type: 'remove-name', +index: number}
  | {+type: 'undo-remove-name', +index: number}
  | {
      +type: 'update-single-artist-autocomplete',
      +action: AutocompleteActionT<ArtistT>,
    }
  | EditArtistActionT
  | EditNameActionT
  | {+type: 'copy'}
  | {+type: 'paste'}
  | {+type: 'next-track', +initialFocus?: StateT['initialBubbleFocus']}
  | {+type: 'previous-track'}
  | {+type: 'set-change-matching-artists', +checked: boolean}
  | {
      +type: 'set-names-from-artist-credit',
      +artistCredit: $ReadOnly<{
        ...ArtistCreditT,
        +names: $ReadOnlyArray<$ReadOnly<{
          ...ArtistCreditNameT,
          +artist?: ?ArtistT,
        }>>,
      }>,
    };
/* eslint-enable ft-flow/sort-keys */
