/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

declare type CompT<out T> = {
  readonly new: T,
  readonly old: T,
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

declare type EditWithIdT = Readonly<{...EditT, readonly id: number}>;

declare type EditNoteChangeT = {
  readonly change_editor_id: number,
  readonly change_time: string,
  readonly edit_note_id: number,
  readonly id: number,
  readonly new_note: string,
  readonly old_note: string,
  readonly reason: string,
  readonly status: 'edited' | 'deleted',
};

// MusicBrainz::Server::Entity::EditNote::TO_JSON
declare type EditNoteT = {
  readonly edit_id: number,
  readonly editor: EditorT | null,
  readonly editor_id: number,
  readonly formatted_text: string,
  readonly id: number,
  readonly latest_change?: EditNoteChangeT,
  readonly post_time: string | null,
};

// Reused by all other edit types
declare type GenericEditT = {
  readonly auto_edit: boolean,
  readonly close_time: string,
  readonly conditions: {
    readonly auto_edit: boolean,
    readonly duration: number,
    readonly expire_action: EditExpireActionT,
    readonly votes: number,
  },
  readonly created_time: string,
  readonly data: {readonly [dataProp: string]: any, ...},
  readonly edit_kind: 'add' | 'edit' | 'remove' | 'merge' | 'other',
  readonly edit_name: string,
  readonly edit_notes: ReadonlyArray<EditNoteT>,
  readonly edit_type: number,
  readonly edit_type_name_context: string,
  readonly editor_id: number,
  readonly expires_time: string,
  readonly historic_type: number | null,
  readonly id: number | null, // id is missing in previews
  readonly is_loaded: boolean,
  readonly is_open: boolean,
  readonly preview?: boolean,
  readonly quality: QualityT,
  readonly status: EditStatusT,
  readonly votes: ReadonlyArray<VoteT>,
};

declare type GenericEditWithIdT = Readonly<{
  ...GenericEditT,
  readonly id: number,
  ...
}>;
