/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export type CollectionEditFormT = FormT<{
  +collaborators: ReadOnlyRepeatableFieldT<ReadOnlyCompoundFieldT<{
    +id: ReadOnlyFieldT<number>,
    +name: ReadOnlyFieldT<string>,
  }>>,
  +description: ReadOnlyFieldT<string>,
  +name: ReadOnlyFieldT<string>,
  +public: ReadOnlyFieldT<boolean>,
  +type_id: ReadOnlyFieldT<number>,
}>;

export type CollaboratorStateT =
  RepeatableFieldT<CompoundFieldT<{
    +id: FieldT<number | null>,
    +name: FieldT<string>,
  }>>;
