/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import cleanMsgid from './cleanMsgid.js';

export const l_admin: (string) => string =
  cleanMsgid;

export function ln_admin(skey: string, pkey: string, val: number): string {
  return val > 1 ? cleanMsgid(pkey) : cleanMsgid(skey);
}
