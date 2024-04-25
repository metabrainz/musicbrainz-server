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
  +cancel: FieldT<string>,
  +edit_note: FieldT<string>,
  +make_votable: FieldT<boolean>,
  +submit: FieldT<string>,
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
  +merge_rgs: FieldT<boolean>,
  +merge_strategy: FieldT<StrOrNum>,
  +merging: RepeatableFieldT<FieldT<StrOrNum>>,
  +rename: FieldT<boolean>,
  +target: FieldT<StrOrNum>,
}>;

declare type SearchFormT = FormT<{
  +limit: FieldT<number>,
  +method: FieldT<'advanced' | 'direct' | 'indexed'>,
  +query: FieldT<string>,
  +type: FieldT<string>,
}>;

declare type SecureConfirmFormT = FormT<{
  +cancel: FieldT<string>,
  +csrf_token: FieldT<string>,
  +submit: FieldT<string>,
}>;

declare type TagLookupFormT = FormT<{
  +artist: FieldT<string>,
  +duration: FieldT<string>,
  +filename: FieldT<string>,
  +release: FieldT<string>,
  +track: FieldT<string>,
  +tracknum: FieldT<string>,
}, 'tag-lookup'>;
