/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// NOTE: Don't convert to an ES module; this is used by root/server.js.
/* eslint-disable import/no-commonjs */

function sanitizedEditor(
  editor /*: EditorT | SanitizedEditorT */
) /*: SanitizedEditorT */ {
  return {
    entityType: 'editor',
    gravatar: editor.gravatar,
    id: editor.id,
    is_account_admin: editor.is_account_admin,
    is_admin: editor.is_admin,
    is_banner_editor: editor.is_banner_editor,
    is_location_editor: editor.is_location_editor,
    is_relationship_editor: editor.is_relationship_editor,
    is_wiki_transcluder: editor.is_wiki_transcluder,
    name: editor.name,
    preferences: {
      datetime_format: editor.preferences.datetime_format,
      timezone: editor.preferences.timezone,
    },
  };
}

module.exports = sanitizedEditor;
