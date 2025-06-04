/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const invisibleCharsPattern =
  /[\u200b\u00AD\u3164\uFFA0\u115F\u1160\u2800\p{Cc}\p{Cf}\p{Mn}]/ug;

// Keep in sync with is_valid_edit_note in Server::Validation
export default function isInvalidEditNote(editNote: string): boolean {
  if (empty(editNote)) {
    // This is missing, not invalid
    return false;
  }

  /*
   * We don't want line format characters and other invisible characters
   * to stop an edit note from being "empty"
   */
  const editNoteNoInvisibleChars = editNote.replace(
    invisibleCharsPattern,
    '',
  );
  return (
    // If it's empty now but not earlier, it was all invisible characters
    empty(editNoteNoInvisibleChars) ||
    /^[\p{White_Space}\p{Punctuation}]+$/u.test(editNoteNoInvisibleChars) ||
    /^\p{ASCII}$/u.test(editNoteNoInvisibleChars)
  );
}
