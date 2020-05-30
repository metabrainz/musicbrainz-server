/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

const quadruplets = /([0-9A-Z]{4})/g;

export default function formatIsni(isni: string): string {
  return isni.replace(quadruplets, '$1 ').trim();
}
