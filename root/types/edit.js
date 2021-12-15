/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

declare type CompT<T> = {
  +new: T,
  +old: T,
};

// From Algorithm::Diff
declare type DiffChangeTypeT = '+' | '-' | 'c' | 'u';

declare type EditExpireActionT = 1 | 2;

declare type EditStatusT =
  | 1 // OPEN
  | 2 // APPLIED
  | 3 // FAILEDVOTE
  | 4 // FAILEDDEP
  | 5 // ERROR
  | 6 // FAILEDPREREQ
  | 7 // NOVOTES
  | 9; // DELETED

declare type EditT = CurrentEditT | HistoricEditT;

declare type EditWithIdT = $ReadOnly<{...EditT, +id: number}>;

// MusicBrainz::Server::Entity::EditNote::TO_JSON
declare type EditNoteT = {
  +edit_id: number,
  +editor: EditorT | null,
  +editor_id: number,
  +formatted_text: string,
  +post_time: string | null,
};


// Reused by all other edit types
declare type GenericEditT = {
  +auto_edit: boolean,
  +close_time: string,
  +conditions: {
    +auto_edit: boolean,
    +duration: number,
    +expire_action: EditExpireActionT,
    +votes: number,
  },
  +created_time: string,
  +data: {+[dataProp: string]: any, ...},
  +edit_kind: 'add' | 'edit' | 'remove' | 'merge' | 'other',
  +edit_name: string,
  +edit_notes: $ReadOnlyArray<EditNoteT>,
  +edit_type: number,
  +editor_id: number,
  +expires_time: string,
  +historic_type: number | null,
  +id: number | null, // id is missing in previews
  +is_loaded: boolean,
  +is_open: boolean,
  +preview?: boolean,
  +quality: QualityT,
  +status: EditStatusT,
  +votes: $ReadOnlyArray<VoteT>,
};

declare type GenericEditWithIdT = $ReadOnly<{
  ...GenericEditT,
  +id: number,
  ...
}>;
