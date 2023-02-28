/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {INSTRUMENT_ROOT_ID} from '../../common/constants.js';

function localizeLinkAttributeTypeName(type: LinkAttrTypeT): string {
  if (type.root_id === INSTRUMENT_ROOT_ID && type.id !== INSTRUMENT_ROOT_ID) {
    if (nonEmpty(type.instrument_comment)) {
      return lp_instruments(type.name, type.instrument_comment);
    }
    return l_instruments(type.name);
  }
  return l_relationships(type.name);
}

export default localizeLinkAttributeTypeName;
