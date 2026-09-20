/*
 * @flow strict-local
 * Copyright (C) 2026 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {CowContext} from 'mutate-cow';
import mutate from 'mutate-cow';

import isBlank from '../../common/utility/isBlank.js';
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
import {
  type ActionT as FormRowNameWithGuessCaseActionT,
  runReducer as runFormRowNameWithGuessCaseReducer,
} from '../components/FormRowNameWithGuessCase.js';
import {
  type StateT as GuessCaseOptionsStateT,
  createInitialState as createGuessCaseOptionsState,
} from '../components/GuessCaseOptions.js';

export type CommonEntityEditFormStateT = {
  readonly externalLinksEditor: LinksEditorStateT,
  readonly guessCaseOptions: GuessCaseOptionsStateT,
  readonly isGuessCaseOptionsOpen: boolean,
  readonly relationshipEditor: RelationshipEditorStateT,
};

/* eslint-disable ft-flow/sort-keys */
export type CommonEntityEditFormActionT =
  | {
      readonly type: 'update-external-links-editor',
      readonly action: LinksEditorActionT,
    }
  | {
      readonly type: 'update-name',
      readonly action: FormRowNameWithGuessCaseActionT,
    }
  | {
      readonly type: 'update-relationship-editor',
      readonly action: RelationshipEditorActionT,
    };
/* eslint-enable ft-flow/sort-keys */

export function updateRequiredNameFieldErrors(
  nameFieldCtx: CowContext<FieldT<string | null>>,
): void {
  if (isBlank(nameFieldCtx.get('value').read())) {
    nameFieldCtx.set('has_errors', true);
    nameFieldCtx.set('pendingErrors', [
      l('Required field.'),
    ]);
  } else {
    nameFieldCtx.set('has_errors', false);
    nameFieldCtx.set('pendingErrors', []);
    nameFieldCtx.set('errors', []);
  }
}

function runNameAction(
  stateCtx: CowContext<Readonly<{
    ...CommonEntityEditFormStateT,
    form: FormT<{readonly name: FieldT<string | null>, ...}>,
    ...
  }>>,
  action: FormRowNameWithGuessCaseActionT,
): void {
  const state = stateCtx.read();
  const nameStateCtx = mutate({
    field: state.form.field.name,
    guessCaseOptions: state.guessCaseOptions,
    isGuessCaseOptionsOpen: state.isGuessCaseOptionsOpen,
  });
  runFormRowNameWithGuessCaseReducer(nameStateCtx, action);

  const nameState = nameStateCtx.final();
  stateCtx
    .update('form', 'field', 'name', (nameFieldCtx) => {
      nameFieldCtx.set(nameState.field);
      updateRequiredNameFieldErrors(nameFieldCtx);
    })
    .set('guessCaseOptions', nameState.guessCaseOptions)
    .set('isGuessCaseOptionsOpen', nameState.isGuessCaseOptionsOpen);

  if (action.type === 'set-name') {
    stateCtx.set('relationshipEditor', relationshipEditorReducer(
      state.relationshipEditor,
      {
        changes: {name: action.name},
        entityType: state.relationshipEditor.entity.entityType,
        type: 'update-entity',
      },
    ));
  }
}

export function createCommonEntityEditFormState({$c, form}: {
  readonly $c: SanitizedCatalystContextT,
  readonly form: FormT<{...}>,
}): CommonEntityEditFormStateT {
  return {
    externalLinksEditor: createExternalLinksEditorState($c),
    guessCaseOptions: createGuessCaseOptionsState(),
    isGuessCaseOptionsOpen: false,
    relationshipEditor: loadOrCreateInitialRelationshipEditorState({
      formName: form.name,
      seededRelationships: $c.stash.seeded_relationships,
    }),
  };
}

export function runCommonEntityEditFormActions(
  stateCtx: CowContext<Readonly<{
    ...CommonEntityEditFormStateT,
    form: FormT<{readonly name: FieldT<string | null>, ...}>,
    ...
  }>>,
  action: CommonEntityEditFormActionT,
): void {
  match (action) {
    {type: 'update-external-links-editor', const action} => {
      stateCtx.set('externalLinksEditor', externalLinksEditorReducer(
        stateCtx.read().externalLinksEditor,
        action,
      ));
    }
    {type: 'update-name', const action} => {
      runNameAction(stateCtx, action);
    }
    {type: 'update-relationship-editor', const action} => {
      stateCtx.set('relationshipEditor', relationshipEditorReducer(
        stateCtx.read().relationshipEditor,
        action,
      ));
    }
  }
}
