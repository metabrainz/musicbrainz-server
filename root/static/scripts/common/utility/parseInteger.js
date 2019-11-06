/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const regexp = /^[0-9]+$/;

export default function parseInteger(num: string) {
  return regexp.test(num) ? parseInt(num, 10) : NaN;
}
