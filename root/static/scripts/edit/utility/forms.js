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
  hasErrorsOnNewOrChangedLinks,
} from '../../external-links-editor/validation.js';
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

import isInvalidEditNote from './isInvalidEditNote.js';
import {hasSubfieldErrors} from './subfieldErrors.js';

export type CommonEntityEditFormStateT = {
  readonly externalLinksEditor: LinksEditorStateT,
  readonly guessCaseOptions: GuessCaseOptionsStateT,
  readonly isGuessCaseOptionsOpen: boolean,
  readonly relationshipEditor: RelationshipEditorStateT,
};

/* eslint-disable ft-flow/sort-keys */
export type CommonEntityEditFormActionT =
  | {
      readonly type: 'update-edit-note',
      readonly editNote: string,
    }
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

export function getEditFormErrors(state: Readonly<{
  ...CommonEntityEditFormStateT,
  form: FormOrAnyFieldT,
  ...
}>): {
  readonly hasErrors: boolean,
  readonly hasVisibleErrors: boolean,
} {
  const hasLinkErrors =
    hasErrorsOnNewOrChangedLinks(state.externalLinksEditor.links);
  return {
    hasErrors:
      hasSubfieldErrors(state.form, /* includePending = */ true) ||
      hasLinkErrors,
    hasVisibleErrors:
      hasSubfieldErrors(state.form, /* includePending = */ false) ||
      hasLinkErrors,
  };
}

export function updateEditNoteFieldErrors(
  editNoteFieldCtx: CowContext<FieldT<string>>,
  requiredEditNoteMessage?: string | null,
): void {
  const editNote = editNoteFieldCtx.get('value').read();
  if (isInvalidEditNote(editNote)) {
    editNoteFieldCtx.set('has_errors', true);
    editNoteFieldCtx.set('pendingErrors', [
      l(`Your edit note seems to have no actual content.
         Please provide a note that will be helpful to
         your fellow editors!`),
    ]);
  } else if (nonEmpty(requiredEditNoteMessage) && empty(editNote)) {
    editNoteFieldCtx.set('has_errors', true);
    editNoteFieldCtx.set('pendingErrors', [requiredEditNoteMessage]);
  } else {
    editNoteFieldCtx.set('has_errors', false);
    editNoteFieldCtx.set('pendingErrors', []);
    editNoteFieldCtx.set('errors', []);
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
    form: FormT<{
      readonly edit_note: FieldT<string>,
      readonly name: FieldT<string | null>,
      ...
    }>,
    requiredEditNoteMessage?: string | null,
    ...
  }>>,
  action: CommonEntityEditFormActionT,
): void {
  match (action) {
    {type: 'update-edit-note', const editNote} => {
      const {requiredEditNoteMessage} = stateCtx.read();
      stateCtx.update('form', 'field', 'edit_note', (editNoteFieldCtx) => {
        editNoteFieldCtx.set('value', editNote);
        updateEditNoteFieldErrors(editNoteFieldCtx, requiredEditNoteMessage);
      });
    }
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
