/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const newLines = /[\r\n]/g;
const adjacentWhitespace = /\s+/g;

export default function cleanMsgid(msg: string): string {
  return (msg || '')
    .replace(newLines, ' ')
    .replace(adjacentWhitespace, ' ');
}
