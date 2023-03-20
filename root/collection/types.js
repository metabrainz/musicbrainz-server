/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {
  StateT as AutocompleteStateT,
} from '../static/scripts/common/components/Autocomplete2/types.js';

export type CollaboratorFieldT = ReadOnlyCompoundFieldT<{
  +id: ReadOnlyFieldT<?number>,
  +name: ReadOnlyFieldT<string>,
}>;

export type WritableCollaboratorFieldT = CompoundFieldT<{
  +id: FieldT<?number>,
  +name: FieldT<string>,
}>;

export type CollaboratorStateT = $ReadOnly<{
  ...CollaboratorFieldT,
  +autocomplete: AutocompleteStateT<EditorT>,
}>;

export type WritableCollaboratorStateT = {
  ...WritableCollaboratorFieldT,
  autocomplete: AutocompleteStateT<EditorT>,
};

export type CollaboratorsStateT =
  ReadOnlyRepeatableFieldT<CollaboratorStateT>;

export type WritableCollaboratorsStateT =
  RepeatableFieldT<WritableCollaboratorStateT>;

export type CollectionEditFormT = FormT<{
  +collaborators: ReadOnlyRepeatableFieldT<CollaboratorFieldT>,
  +description: ReadOnlyFieldT<string>,
  +name: ReadOnlyFieldT<string>,
  +public: ReadOnlyFieldT<boolean>,
  +type_id: ReadOnlyFieldT<number>,
}>;
