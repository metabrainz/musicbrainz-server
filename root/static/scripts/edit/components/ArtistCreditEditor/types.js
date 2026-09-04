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
  readonly artist: AutocompleteStateT<ArtistT>,
  readonly automaticJoinPhrase: boolean,
  readonly joinPhrase: string,
  readonly key: number,
  readonly name: string,
  readonly removed: boolean,
};

export type StateT = {
  readonly artistCreditString: string,
  readonly changeMatchingTrackArtists?: boolean,
  readonly editsPending?: boolean,
  readonly entity?: ArtistCreditableT,
  readonly formName?: string,
  readonly id: string,
  readonly initialArtistCreditString: string,
  readonly initialBubbleFocus?:
    | 'default'
    | 'next-track'
    | 'prev-track'
    | void,
  readonly isOpen: boolean,
  readonly names: ReadonlyArray<ArtistCreditNameStateT>,
  readonly singleArtistAutocomplete: AutocompleteStateT<ArtistT>,
};

/* eslint-disable ft-flow/sort-keys */
export type EditArtistActionT = {
  readonly type: 'edit-artist',
  readonly index: number,
  readonly action: AutocompleteActionT<ArtistT>,
};

export type EditNameActionT = {
  readonly type: 'edit-name',
  readonly index: number,
  readonly joinPhrase?: string,
  readonly name?: string,
  readonly automaticJoinPhrase?: boolean,
};

export type ActionT =
  | {
      readonly type: 'open-dialog',
      readonly initialFocus?: StateT['initialBubbleFocus'],
    }
  | {readonly type: 'close-dialog'}
  | {readonly type: 'add-name'}
  | {readonly type: 'move-name-down', readonly index: number}
  | {readonly type: 'move-name-up', readonly index: number}
  | {readonly type: 'remove-name', readonly index: number}
  | {readonly type: 'undo-remove-name', readonly index: number}
  | {
      readonly type: 'update-single-artist-autocomplete',
      readonly action: AutocompleteActionT<ArtistT>,
    }
  | EditArtistActionT
  | EditNameActionT
  | {readonly type: 'copy'}
  | {readonly type: 'paste'}
  | {
      readonly type: 'next-track',
      readonly initialFocus?: StateT['initialBubbleFocus'],
    }
  | {readonly type: 'previous-track'}
  | {readonly type: 'set-change-matching-artists', readonly checked: boolean}
  | {
      readonly type: 'set-names-from-artist-credit',
      readonly artistCredit: Readonly<{
        ...ArtistCreditT,
        readonly names: ReadonlyArray<Readonly<{
          ...ArtistCreditNameT,
          readonly artist?: ?ArtistT,
        }>>,
      }>,
    };
/* eslint-enable ft-flow/sort-keys */
