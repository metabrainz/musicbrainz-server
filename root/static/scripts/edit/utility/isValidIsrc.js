/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const isrcPattern = /^[A-Z]{2}[A-Z0-9]{3}[0-9]{7}$/;

export default function isValidIsrc(isrc: string): boolean {
  const cleanedIsrc = isrc.replace(/[\s-]/g, '').toUpperCase();
  return isrcPattern.test(cleanedIsrc);
}
