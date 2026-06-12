/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable no-unused-vars */

declare type ConfirmFormT = FormT<{
  readonly cancel: FieldT<string>,
  readonly edit_note: FieldT<string>,
  readonly make_votable: FieldT<boolean>,
  readonly submit: FieldT<string>,
}>;

declare type TextListItemFieldT = CompoundFieldT<{
  readonly removed: FieldT<boolean>,
  readonly value: FieldT<string>,
}>;

declare type TextListFieldT = RepeatableFieldT<TextListItemFieldT>;

declare type MediumFieldT = CompoundFieldT<{
  readonly id: FieldT<number>,
  readonly name: FieldT<string>,
  readonly position: FieldT<number>,
  readonly release_id: FieldT<number>,
}>;

declare type MergeFormT = FormT<{
  readonly edit_note: FieldT<string>,
  readonly make_votable: FieldT<boolean>,
  readonly merging: RepeatableFieldT<FieldT<number>>,
  readonly rename: FieldT<boolean>,
  readonly target: FieldT<number>,
}>;

declare type MergeReleasesFormT = FormT<{
  readonly edit_note: FieldT<string>,
  readonly make_votable: FieldT<boolean>,
  readonly medium_positions: CompoundFieldT<{
    readonly map: CompoundFieldT<ReadonlyArray<MediumFieldT | void>>,
  }>,
  readonly merge_rgs: FieldT<boolean>,
  readonly merge_strategy: FieldT<StrOrNum>,
  readonly merging: RepeatableFieldT<FieldT<StrOrNum>>,
  readonly rename: FieldT<boolean>,
  readonly target: FieldT<StrOrNum>,
}>;

declare type SearchFormT = FormT<{
  readonly limit: FieldT<number>,
  readonly method: FieldT<'advanced' | 'direct' | 'indexed'>,
  readonly query: FieldT<string>,
  readonly type: FieldT<string>,
}>;

declare type SecureConfirmFormT = FormT<{
  readonly cancel: FieldT<string>,
  readonly csrf_token: FieldT<string>,
  readonly submit: FieldT<string>,
}>;

declare type TagLookupFormT = FormT<{
  readonly artist: FieldT<string>,
  readonly duration: FieldT<string>,
  readonly filename: FieldT<string>,
  readonly release: FieldT<string>,
  readonly track: FieldT<string>,
  readonly tracknum: FieldT<string>,
}, 'tag-lookup'>;
