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
  readonly id: FieldT<?number>,
  readonly name: FieldT<string>,
}>;

export type CollaboratorStateT = Readonly<{
  ...CollaboratorFieldT,
  readonly autocomplete: AutocompleteStateT<EditorT>,
}>;

export type CollaboratorsStateT =
  RepeatableFieldT<CollaboratorStateT>;

export type CollectionEditFormT = FormT<{
  readonly collaborators: RepeatableFieldT<CollaboratorFieldT>,
  readonly description: FieldT<string>,
  readonly name: FieldT<string>,
  readonly public: FieldT<boolean>,
  readonly type_id: FieldT<number>,
}>;
