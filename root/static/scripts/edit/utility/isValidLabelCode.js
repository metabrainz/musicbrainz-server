/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export default function isValidLabelCode(labelCode: StrOrNum): boolean {
  let code = labelCode;

  if (typeof code === 'string') {
    code = Number.parseInt(code, 10);
  }

  if (Number.isNaN(code)) {
    return false;
  }

  return code > 0 && code < 1000000;
}
