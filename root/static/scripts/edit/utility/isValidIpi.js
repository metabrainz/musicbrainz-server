/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const ipiPattern = /^[0-9]{11}$/;
const dirtyIpiPattern = /^[0-9\s.]{5,}$/;
const nullsOnlyIpiPattern = /^0{11}$/;

export default function isValidIpi(ipi: string): boolean {
  if (!dirtyIpiPattern.test(ipi)) {
    return false;
  }
  const cleanedIpi = ipi.replace(/[\s.]/g, '').padStart(11, '0');
  if (nullsOnlyIpiPattern.test(cleanedIpi)) {
    return false;
  }
  return ipiPattern.test(cleanedIpi);
}
