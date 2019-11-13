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
  editor /*: EditorT | SanitizedEditorT */,
) /*: SanitizedEditorT */ {
  return {
    entityType: 'editor',
    gravatar: editor.gravatar,
    id: editor.id,
    name: editor.name,
    preferences: {
      datetime_format: editor.preferences.datetime_format,
      timezone: editor.preferences.timezone,
    },
  };
}

module.exports = sanitizedEditor;
