/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import unformatTrackLength from '../../common/utility/unformatTrackLength.js';

export default function isInvalidLength(length: string): boolean {
  // If the unformatted length is false, then it's an unparseable date
  return Number.isNaN(unformatTrackLength(length));
}
