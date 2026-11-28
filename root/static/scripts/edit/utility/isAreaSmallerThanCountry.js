/*
 * @flow strict
 * Copyright (C) 2026 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {AREA_TYPE_COUNTRY} from '../../common/constants.js';

/*
 * Whether an area picked for an artist or label is of a type other than
 * country, such as a city or a subdivision. An area without a type is not
 * flagged, since we can't tell what it is.
 */
export default function isAreaSmallerThanCountry(
  area: ?{readonly typeID?: number | null, ...},
): boolean {
  const typeId = area?.typeID;
  return typeId != null && typeId !== AREA_TYPE_COUNTRY;
}
