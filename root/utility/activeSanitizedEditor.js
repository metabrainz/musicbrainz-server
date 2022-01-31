/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// NOTE: Don't convert to an ES module; this is used by root/server.js.
/* eslint-disable import/no-commonjs */

function activeSanitizedEditor(
  editor /*: UnsanitizedEditorT */,
) /*: ActiveEditorT */ {
  return {
    entityType: 'editor',
    avatar: editor.avatar,
    has_confirmed_email_address: editor.has_confirmed_email_address,
    id: editor.id,
    name: editor.name,
    preferences: {
      datetime_format: editor.preferences.datetime_format,
      timezone: editor.preferences.timezone,
    },
    privileges: editor.privileges,
  };
}

module.exports = activeSanitizedEditor;
