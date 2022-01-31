/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  ACCOUNT_ADMIN_FLAG,
  ADDING_NOTES_DISABLED_FLAG,
  AUTO_EDITOR_FLAG,
  BANNER_EDITOR_FLAG,
  BOT_FLAG,
  DONT_NAG_FLAG,
  EDITING_DISABLED_FLAG,
  LOCATION_EDITOR_FLAG,
  MBID_SUBMITTER_FLAG,
  RELATIONSHIP_EDITOR_FLAG,
  SPAMMER_FLAG,
  UNTRUSTED_FLAG,
  WIKI_TRANSCLUSION_FLAG,
} from '../../../../constants';

type EditorPropT = ?{+privileges: number, ...};

export function isAutoEditor(editor: EditorPropT): boolean {
  if (editor == null) {
    return false;
  }
  return (editor.privileges & AUTO_EDITOR_FLAG) > 0;
}

export function isBot(editor: EditorPropT): boolean {
  if (editor == null) {
    return false;
  }
  return (editor.privileges & BOT_FLAG) > 0;
}

export function isUntrusted(editor: EditorPropT): boolean {
  if (editor == null) {
    return false;
  }
  return (editor.privileges & UNTRUSTED_FLAG) > 0;
}

export function isNagFree(editor: EditorPropT): boolean {
  if (editor == null) {
    return false;
  }
  return (editor.privileges & DONT_NAG_FLAG) > 0;
}

export function isRelationshipEditor(editor: EditorPropT): boolean {
  if (editor == null) {
    return false;
  }
  return (editor.privileges & RELATIONSHIP_EDITOR_FLAG) > 0;
}

export function isWikiTranscluder(editor: EditorPropT): boolean {
  if (editor == null) {
    return false;
  }
  return (editor.privileges & WIKI_TRANSCLUSION_FLAG) > 0;
}

export function isMbidSubmitter(editor: EditorPropT): boolean {
  if (editor == null) {
    return false;
  }
  return (editor.privileges & MBID_SUBMITTER_FLAG) > 0;
}

export function isAccountAdmin(editor: EditorPropT): boolean {
  if (editor == null) {
    return false;
  }
  return (editor.privileges & ACCOUNT_ADMIN_FLAG) > 0;
}

export function isLocationEditor(editor: EditorPropT): boolean {
  if (editor == null) {
    return false;
  }
  return (editor.privileges & LOCATION_EDITOR_FLAG) > 0;
}

export function isBannerEditor(editor: EditorPropT): boolean {
  if (editor == null) {
    return false;
  }
  return (editor.privileges & BANNER_EDITOR_FLAG) > 0;
}

export function isEditingDisabled(editor: EditorPropT): boolean {
  if (editor == null) {
    return false;
  }
  return (editor.privileges & EDITING_DISABLED_FLAG) > 0;
}

export function isEditingEnabled(editor: EditorPropT): boolean {
  if (editor == null) {
    return false;
  }
  return (editor.privileges & EDITING_DISABLED_FLAG) === 0;
}

export function isAddingNotesDisabled(editor: EditorPropT): boolean {
  if (editor == null) {
    return false;
  }
  return (editor.privileges & ADDING_NOTES_DISABLED_FLAG) > 0;
}

export function isSpammer(editor: EditorPropT): boolean {
  if (editor == null) {
    return false;
  }
  return (editor.privileges & SPAMMER_FLAG) > 0;
}

export function isAdmin(editor: EditorPropT): boolean {
  return isAccountAdmin(editor) ||
         isBannerEditor(editor) ||
         isLocationEditor(editor) ||
         isRelationshipEditor(editor) ||
         isWikiTranscluder(editor);
}
