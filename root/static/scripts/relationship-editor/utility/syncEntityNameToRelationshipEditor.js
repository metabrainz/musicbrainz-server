/*
 * @flow strict-local
 * Copyright (C) 2026 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {CowContext} from 'mutate-cow';

import {
  reducer as relationshipEditorReducer,
} from '../components/RelationshipEditor.js';
import type {RelationshipEditorStateT} from '../types.js';

type FormStateT = Readonly<{
  form: FormT<{readonly name: FieldT<string | null>, ...}>,
  relationshipEditor: RelationshipEditorStateT,
  ...
}>;

/*
 * Copies the entity name from an edit form into the relationship editor's
 * source entity. The relationship editor only uses this name for display in
 * the relationship dialogs (the source entity link, the credit options, and
 * edit preview).
 */
export default function syncEntityNameToRelationshipEditor(
  prevState: FormStateT,
  stateCtx: CowContext<FormStateT>,
): void {
  const newState = stateCtx.read();
  const newName = newState.form.field.name.value ?? '';
  if (newName !== (prevState.form.field.name.value ?? '')) {
    stateCtx.set(
      'relationshipEditor',
      relationshipEditorReducer(newState.relationshipEditor, {
        changes: {name: newName},
        entityType: prevState.relationshipEditor.entity.entityType,
        type: 'update-entity',
      }),
    );
  }
}
