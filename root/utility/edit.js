/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import get from 'lodash/get';

import {
  EDIT_EXPIRE_ACCEPT,
  EDIT_EXPIRE_REJECT,
  EDIT_STATUS_OPEN,
  EDIT_STATUS_APPLIED,
  EDIT_STATUS_FAILEDVOTE,
  EDIT_STATUS_FAILEDDEP,
  EDIT_STATUS_ERROR,
  EDIT_STATUS_FAILEDPREREQ,
  EDIT_STATUS_NOVOTES,
  EDIT_STATUS_TOBEDELETED,
  EDIT_STATUS_DELETED,
} from '../constants';

import {
  EDIT_RELATIONSHIP_DELETE,
  EDIT_SERIES_EDIT,
} from '../static/scripts/common/constants/editTypes';

const EXPIRE_ACTIONS = {
  [EDIT_EXPIRE_ACCEPT]:   N_l('Accept upon closing'),
  [EDIT_EXPIRE_REJECT]:   N_l('Reject upon closing'),
};

const STATUS_NAMES = {
  [EDIT_STATUS_OPEN]:           N_l('Open'),
  [EDIT_STATUS_APPLIED]:        N_l('Applied'),
  [EDIT_STATUS_FAILEDVOTE]:     N_l('Failed vote'),
  [EDIT_STATUS_FAILEDDEP]:      N_l('Failed dependency'),
  [EDIT_STATUS_ERROR]:          N_l('Error'),
  [EDIT_STATUS_FAILEDPREREQ]:   N_l('Failed prerequisite'),
  [EDIT_STATUS_NOVOTES]:        N_l('No votes'),
  [EDIT_STATUS_DELETED]:        N_l('Cancelled'),
};

export function getEditExpireAction(edit: EditT) {
  return EXPIRE_ACTIONS[edit.conditions.expire_action]();
}

export function getEditStatusName(edit: EditT) {
  return STATUS_NAMES[edit.status]();
}

export function getEditStatusDescription(edit: EditT) {
  switch (edit.status) {
    case EDIT_STATUS_OPEN:
      return l('This edit is open and awaiting votes before it can be applied.');
    case EDIT_STATUS_APPLIED:
      return l('This edit has been successfully applied.');
    case EDIT_STATUS_FAILEDVOTE:
      return l('This edit failed because there were insufficient "yes" votes.');
    case EDIT_STATUS_FAILEDDEP:
      return l('This edit failed either because an entity it was modifying no longer exists, or the entity can not be modified in this manner anymore.');
    case EDIT_STATUS_ERROR:
      return l('This edit failed due to an internal error and may need to be entered again.');
    case EDIT_STATUS_FAILEDPREREQ:
      return l('This edit failed because the data it was changing was modified after this edit was created. This may happen when the same edit is entered in twice; one will pass but the other will fail.');
    case EDIT_STATUS_NOVOTES:
      return l('This edit failed because it affected high quality data and did not receive any votes.');
    case EDIT_STATUS_TOBEDELETED:
      return l('This edit was recently cancelled.');
    case EDIT_STATUS_DELETED:
      return l('This edit was cancelled.');
    default:
      return '';
  }
}

export function getVotesForEditor(
  edit: EditT,
  editor: EditorT,
): $ReadOnlyArray<VoteT> {
  return edit.votes.filter(v => v.editor_id === editor.id);
}

export function editorMayAddNote(edit: EditT, editor: ?EditorT): boolean {
  return editor != null && !!editor.email_confirmation_date &&
    (editor.id === edit.editor_id || !editor.is_limited);
}

export function editorMayApprove(edit: EditT, editor: ?EditorT): boolean {
  const conditions = edit.conditions;

  const minimalRequirements = (
    editor != null &&
    edit.status === EDIT_STATUS_OPEN &&
    editor.is_auto_editor &&
    !editor.is_editing_disabled
  );

  if (!minimalRequirements) {
    return false;
  }

  switch (edit.edit_type) {
    case EDIT_RELATIONSHIP_DELETE:
      const linkType = get(edit, 'data.relationship.link.type');

      if (linkType && typeof linkType === 'object') {
        // MBS-8332
        return (
          linkType.entity0_type === 'url' ||
          linkType.entity1_type === 'url'
        );
      }
      break;

    case EDIT_SERIES_EDIT:
      const oldOrderingType = get(edit, 'data.old.ordering_type_id', 0);
      const newOrderingType = get(edit, 'data.new.ordering_type_id', 0);
      if (oldOrderingType != newOrderingType) {
        return false;
      }
      break;
  }

  return conditions.auto_edit;
}

export function editorMayCancel(edit: EditT, editor: ?EditorT): boolean {
  return editor != null &&
    (edit.status === EDIT_STATUS_OPEN && edit.editor_id === editor.id);
}

export function editorMayVote(edit: EditT, editor: ?EditorT): boolean {
  return (
    editor != null &&
    edit.status === EDIT_STATUS_OPEN &&
    editor.id !== edit.editor_id &&
    !editor.is_limited &&
    !editor.is_bot &&
    !editor.is_editing_disabled
  );
}

export function getLatestVoteForEditor(
  edit: EditT,
  editor: EditorT,
): VoteT | null {
  const votes = getVotesForEditor(edit, editor);
  return votes.length ? votes[votes.length - 1] : null;
}
