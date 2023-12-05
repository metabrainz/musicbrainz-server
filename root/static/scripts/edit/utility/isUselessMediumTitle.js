/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export default function isUselessMediumTitle(title: string): boolean {
  return /^(Cassette|CD|Dis[ck]|DVD|SACD|Vinyl)\s*\d+/i.test(title);
}
