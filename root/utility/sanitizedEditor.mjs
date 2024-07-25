/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// If you update this, also update $PUBLIC_PRIVILEGE_FLAGS in Constants.pm
const publicFlags = 1 | // AUTO_EDITOR_FLAG
                    2 | // BOT_FLAG
                    8 | // RELATIONSHIP_EDITOR_FLAG
                    32 | // WIKI_TRANSCLUSION_FLAG
                    128 | // ACCOUNT_ADMIN_FLAG
                    256 | // LOCATION_EDITOR_FLAG
                    512 | // BANNER_EDITOR_FLAG
                    8192; // BEGINNER_FLAG

function sanitizePrivileges(privileges: number): number {
  return (privileges & publicFlags);
}

export default function sanitizedEditor(
  editor: UnsanitizedEditorT | EditorT,
): EditorT {
  /*
   * If you return more data here, please
   *  - ensure it doesn't constitute private/non-public info
   *  - add new keys to `sanitizedEditorProps` in
   *    root/utility/hydrate.js
   */
  return {
    avatar: editor.avatar,
    deleted: editor.deleted,
    entityType: 'editor',
    id: editor.id,
    name: editor.name,
    privileges: sanitizePrivileges(editor.privileges),
  };
}
