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

export type CollaboratorFieldT = CompoundFieldT<{
  +id: FieldT<?number>,
  +name: FieldT<string>,
}>;

export type CollaboratorStateT = $ReadOnly<{
  ...CollaboratorFieldT,
  +autocomplete: AutocompleteStateT<EditorT>,
}>;

export type CollaboratorsStateT =
  RepeatableFieldT<CollaboratorStateT>;

export type CollectionEditFormT = FormT<{
  +collaborators: RepeatableFieldT<CollaboratorFieldT>,
  +description: FieldT<string>,
  +name: FieldT<string>,
  +public: FieldT<boolean>,
  +type_id: FieldT<number>,
}>;
