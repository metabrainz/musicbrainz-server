/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  EDIT_EXPIRE_ACCEPT,
  EDIT_EXPIRE_REJECT,
  EDIT_STATUS_APPLIED,
  EDIT_STATUS_DELETED,
  EDIT_STATUS_ERROR,
  EDIT_STATUS_FAILEDDEP,
  EDIT_STATUS_FAILEDPREREQ,
  EDIT_STATUS_FAILEDVOTE,
  EDIT_STATUS_NOVOTES,
  EDIT_STATUS_OPEN,
} from '../constants.js';
import {
  EDIT_RELATIONSHIP_DELETE,
  EDIT_SERIES_EDIT,
} from '../static/scripts/common/constants/editTypes.js';
import {
  isAddingNotesDisabled,
  isAutoEditor,
  isBeginner,
  isBot,
  isVotingEnabled,
} from '../static/scripts/common/utility/privileges.js';
import {kebabCase} from '../static/scripts/common/utility/strings.js';

const EXPIRE_ACTIONS = {
  [EDIT_EXPIRE_ACCEPT]:   N_l('Accept upon closing'),
  [EDIT_EXPIRE_REJECT]:   N_l('Reject upon closing'),
};

const STATUS_NAMES = {
  [EDIT_STATUS_APPLIED]:        N_lp('Applied', 'edit status'),
  [EDIT_STATUS_DELETED]:        N_lp('Cancelled', 'edit status'),
  [EDIT_STATUS_ERROR]:          N_lp('Error', 'edit status'),
  [EDIT_STATUS_FAILEDDEP]:      N_lp('Failed dependency', 'edit status'),
  [EDIT_STATUS_FAILEDPREREQ]:   N_lp('Failed prerequisite', 'edit status'),
  [EDIT_STATUS_FAILEDVOTE]:     N_lp('Failed vote', 'edit status'),
  [EDIT_STATUS_NOVOTES]:        N_lp('No votes', 'edit status'),
  [EDIT_STATUS_OPEN]:           N_lp('Open', 'adjective, edit status'),
};

export function getEditExpireAction(edit: GenericEditWithIdT): string {
  return EXPIRE_ACTIONS[edit.conditions.expire_action]();
}

export function getEditStatusName(edit: GenericEditWithIdT): string {
  return STATUS_NAMES[edit.status]();
}

export function getEditStatusDescription(edit: GenericEditWithIdT): string {
  return match (edit) {
    {status: EDIT_STATUS_OPEN, ...} => l('This edit is open for voting.'),
    {status: EDIT_STATUS_APPLIED, ...} => l(
      'This edit has been successfully applied.',
    ),
    {status: EDIT_STATUS_FAILEDVOTE, ...} => l(
      'This edit failed because there were insufficient "yes" votes.',
    ),
    {status: EDIT_STATUS_FAILEDDEP, ...} => l(
      `This edit failed either because an entity it was modifying no longer 
       exists, or the entity can not be modified in this manner anymore.`,
    ),
    {status: EDIT_STATUS_ERROR, ...} => l(
      `This edit failed due to an internal error and may need 
       to be entered again.`,
    ),
    {status: EDIT_STATUS_FAILEDPREREQ, ...} => l(
      `This edit failed because the data it was changing was modified 
       after this edit was entered. This may happen when the same edit 
       is entered in twice; one will pass but the other will fail.`,
    ),
    {status: EDIT_STATUS_NOVOTES, ...} => l(
      `This edit failed because it affected high quality data 
       and did not receive any votes.`,
    ),
    {status: EDIT_STATUS_DELETED, ...} => l('This edit was cancelled.'),
  };
}

export function getEditHeaderClass(edit: GenericEditWithIdT): string {
  return 'edit-header ' +
         getEditStatusClass(edit) + ' ' +
         'edit-' + edit.edit_kind + ' ' +
         kebabCase(edit.edit_name);
}

export function getEditStatusClass(edit: GenericEditWithIdT): string {
  return match (edit) {
    {status: EDIT_STATUS_OPEN, ...} => 'open',
    {status: EDIT_STATUS_APPLIED, ...} => 'applied',
    {status: EDIT_STATUS_FAILEDVOTE, ...} => 'failed',
    {status: EDIT_STATUS_DELETED, ...} => 'cancelled',
    _ => 'edit-error',
  };
}

export function getVotesForEditor(
  edit: GenericEditWithIdT,
  editor: UnsanitizedEditorT,
): $ReadOnlyArray<VoteT> {
  return edit.votes.filter(v => v.editor_id === editor.id);
}

export function editorMayAddNote(
  edit: GenericEditWithIdT,
  editor: ?UnsanitizedEditorT,
): boolean {
  return editor != null && nonEmpty(editor.email_confirmation_date) &&
    !isAddingNotesDisabled(editor);
}

export function editorMayApprove(
  edit: GenericEditWithIdT,
  editor: ?UnsanitizedEditorT,
): boolean {
  const conditions = edit.conditions;

  const minimalRequirements = (
    editor != null &&
    edit.status === EDIT_STATUS_OPEN &&
    isAutoEditor(editor) &&
    isVotingEnabled(editor)
  );

  if (!minimalRequirements) {
    return false;
  }

  match (edit) {
    {edit_type: EDIT_RELATIONSHIP_DELETE, ...} as edit => {
      const linkType = edit.data.relationship?.link?.type;

      if (linkType && typeof linkType === 'object') {
        // MBS-8332
        return (
          linkType.entity0_type === 'url' ||
          linkType.entity1_type === 'url'
        );
      }
      return conditions.auto_edit;
    }
    {edit_type: EDIT_SERIES_EDIT, ...} as edit => {
      const oldOrderingType = (edit.data.old?.ordering_type_id) ?? 0;
      const newOrderingType = (edit.data.new?.ordering_type_id) ?? 0;
      // Intentional != since some edit data store numbers as strings
      // eslint-disable-next-line eqeqeq
      if (oldOrderingType != newOrderingType) {
        return false;
      }
      return conditions.auto_edit;
    }
    _ => {
      return conditions.auto_edit;
    }
  }
}

export function editorMayCancel(
  edit: GenericEditWithIdT,
  editor: ?UnsanitizedEditorT,
): boolean {
  return editor != null &&
    (edit.status === EDIT_STATUS_OPEN && edit.editor_id === editor.id);
}

export function editorMayVote(
  editor: ?UnsanitizedEditorT,
): boolean {
  return (
    editor != null &&
    !isBeginner(editor) &&
    nonEmpty(editor.email_confirmation_date) &&
    !isBot(editor) &&
    isVotingEnabled(editor)
  );
}

export function editorMayVoteOnEdit(
  edit: GenericEditWithIdT,
  editor: ?UnsanitizedEditorT,
): boolean {
  return (
    editor != null &&
    editorMayVote(editor) &&
    edit.status === EDIT_STATUS_OPEN &&
    editor.id !== edit.editor_id
  );
}

export function getLatestVoteForEditor(
  edit: GenericEditWithIdT,
  editor: UnsanitizedEditorT,
): VoteT | null {
  const votes = getVotesForEditor(edit, editor);
  return votes.length ? votes[votes.length - 1] : null;
}
