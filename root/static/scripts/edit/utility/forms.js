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
  createInitialState as createExternalLinksEditorState,
  reducer as externalLinksEditorReducer,
} from '../../external-links-editor/state.js';
import type {
  LinksEditorActionT,
  LinksEditorStateT,
} from '../../external-links-editor/types.js';
import {
  loadOrCreateInitialState as loadOrCreateInitialRelationshipEditorState,
  reducer as relationshipEditorReducer,
} from '../../relationship-editor/components/RelationshipEditor.js';
import type {
  RelationshipEditorStateT,
} from '../../relationship-editor/types.js';
import type {
  RelationshipEditorActionT,
} from '../../relationship-editor/types/actions.js';

export type CommonEntityEditFormStateT = {
  readonly externalLinksEditor: LinksEditorStateT,
  readonly relationshipEditor: RelationshipEditorStateT,
};

/* eslint-disable ft-flow/sort-keys */
export type CommonEntityEditFormActionT =
  | {
      readonly type: 'update-external-links-editor',
      readonly action: LinksEditorActionT,
    }
  | {
      readonly type: 'update-relationship-editor',
      readonly action: RelationshipEditorActionT,
    };
/* eslint-enable ft-flow/sort-keys */

export function createCommonEntityEditFormState({$c, form}: {
  readonly $c: SanitizedCatalystContextT,
  readonly form: FormT<{...}>,
}): CommonEntityEditFormStateT {
  return {
    externalLinksEditor: createExternalLinksEditorState($c),
    relationshipEditor: loadOrCreateInitialRelationshipEditorState({
      formName: form.name,
      seededRelationships: $c.stash.seeded_relationships,
    }),
  };
}

export function runCommonEntityEditFormActions(
  stateCtx: CowContext<Readonly<{...CommonEntityEditFormStateT, ...}>>,
  action: CommonEntityEditFormActionT,
): void {
  match (action) {
    {type: 'update-external-links-editor', const action} => {
      stateCtx.set('externalLinksEditor', externalLinksEditorReducer(
        stateCtx.read().externalLinksEditor,
        action,
      ));
    }
    {type: 'update-relationship-editor', const action} => {
      stateCtx.set('relationshipEditor', relationshipEditorReducer(
        stateCtx.read().relationshipEditor,
        action,
      ));
    }
  }
}
