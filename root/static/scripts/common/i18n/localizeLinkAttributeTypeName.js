/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {INSTRUMENT_ROOT_ID} from '../constants';

function localizeLinkAttributeTypeName(type: LinkAttrTypeT) {
  if (type.root_id === INSTRUMENT_ROOT_ID) {
    if (type.instrument_comment) {
      return lp_instruments(type.name, type.instrument_comment);
    }
    return l_instruments(type.name);
  }
  return l_relationships(type.name);
}

export default localizeLinkAttributeTypeName;
