/*
 * @flow strict
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const setlistLinePattern = /^([@#*] |\s*$)/;

export default function isValidSetlist(setlist: string): boolean {
  const lines = setlist.split(/\r?\n/);
  return lines.every((line) => setlistLinePattern.test(line));
}
