/*
 * @flow strict
 * Copyright (C) 2026 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const timePattern = /^([01][0-9]|2[0-3]):[0-5][0-9]$/;

export default function isValidTime(time: string): boolean {
  return empty(time) || timePattern.test(time.trim());
}
