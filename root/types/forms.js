/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

declare type ConfirmFormT = FormT<{
  +cancel: ReadOnlyFieldT<string>,
  +edit_note: ReadOnlyFieldT<string>,
  +make_votable: ReadOnlyFieldT<boolean>,
  +submit: ReadOnlyFieldT<string>,
}>;

declare type MediumFieldT = CompoundFieldT<{
  +id: FieldT<number>,
  +name: FieldT<string>,
  +position: FieldT<number>,
  +release_id: FieldT<number>,
}>;

declare type MergeFormT = FormT<{
  +edit_note: FieldT<string>,
  +make_votable: FieldT<boolean>,
  +merging: RepeatableFieldT<FieldT<number>>,
  +rename: FieldT<boolean>,
  +target: FieldT<number>,
}>;

declare type MergeReleasesFormT = FormT<{
  +edit_note: FieldT<string>,
  +make_votable: FieldT<boolean>,
  +medium_positions: CompoundFieldT<{
    +map: CompoundFieldT<$ReadOnlyArray<MediumFieldT>>,
  }>,
  +merge_strategy: FieldT<StrOrNum>,
  +merging: RepeatableFieldT<FieldT<StrOrNum>>,
  +rename: FieldT<boolean>,
  +target: FieldT<StrOrNum>,
}>;

declare type SearchFormT = FormT<{
  +limit: ReadOnlyFieldT<number>,
  +method: ReadOnlyFieldT<'advanced' | 'direct' | 'indexed'>,
  +query: ReadOnlyFieldT<string>,
  +type: ReadOnlyFieldT<string>,
}>;

declare type SecureConfirmFormT = FormT<{
  +cancel: ReadOnlyFieldT<string>,
  +csrf_token: ReadOnlyFieldT<string>,
  +submit: ReadOnlyFieldT<string>,
}>;

declare type TagLookupFormT = FormT<{
  +artist: ReadOnlyFieldT<string>,
  +duration: ReadOnlyFieldT<string>,
  +filename: ReadOnlyFieldT<string>,
  +release: ReadOnlyFieldT<string>,
  +track: ReadOnlyFieldT<string>,
  +tracknum: ReadOnlyFieldT<string>,
}, 'tag-lookup'>;
