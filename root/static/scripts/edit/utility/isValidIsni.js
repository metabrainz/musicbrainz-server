/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const isniPattern = /^[0-9]{15}[0-9X]$/;

export default function isValidIsni(isni: string): boolean {
  const cleanedIsni = isni.replace(/[\s.-]/g, '');
  return isniPattern.test(cleanedIsni);
}
