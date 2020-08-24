/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const greyRegExp = new RegExp('^https?://(?:www\.)?decoda\.com/');

export default function isGreyedOut(
  url: string,
): boolean {
  return greyRegExp.test(url);
}
