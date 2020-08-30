/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {AREA_TYPE_COUNTRY} from '../constants';

function localizeAreaName(area: AreaT): string {
  const areaType = area.typeID;
  if (areaType === AREA_TYPE_COUNTRY) {
    return l_countries(area.name);
  }
  return area.name;
}

export default localizeAreaName;
