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

export type InitialBubbleFocusT =
  | 'default'
  | 'next-track'
  | 'prev-track';

export type StateT = {
  readonly artistCreditString: string,
  readonly changeMatchingTrackArtists?: boolean,
  readonly editsPending?: boolean,
  readonly entity?: ArtistCreditableT,
  readonly formName?: string,
  readonly htmlId: string,
  readonly initialArtistCreditString: string,
  readonly initialBubbleFocus?: InitialBubbleFocusT | void,
  readonly isOpen: boolean,
  readonly names: ReadonlyArray<ArtistCreditNameStateT>,
  readonly singleArtistAutocomplete: AutocompleteStateT<ArtistT>,
};

/* eslint-disable ft-flow/sort-keys */
export type EditArtistActionT = {
  readonly type: 'edit-artist',
  readonly key: number,
  readonly action: AutocompleteActionT<ArtistT>,
};

export type EditNameActionT = {
  readonly type: 'edit-name',
  readonly key: number,
  readonly joinPhrase?: string,
  readonly name?: string,
  readonly automaticJoinPhrase?: boolean,
};

export type ActionT =
  | {
      readonly type: 'open-dialog',
      readonly initialFocus?: InitialBubbleFocusT,
    }
  | {readonly type: 'close-dialog'}
  | {readonly type: 'add-name'}
  | {readonly type: 'move-name-down', readonly key: number}
  | {readonly type: 'move-name-up', readonly key: number}
  | {readonly type: 'remove-name', readonly key: number}
  | {readonly type: 'undo-remove-name', readonly key: number}
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
      readonly initialFocus?: InitialBubbleFocusT,
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
