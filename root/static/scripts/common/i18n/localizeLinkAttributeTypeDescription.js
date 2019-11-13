/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {INSTRUMENT_ROOT_ID} from '../constants';

function localizeLinkAttributeTypeDescription(type: LinkAttrTypeT) {
  if (!type.description) {
    return '';
  }
  if (type.root_id === INSTRUMENT_ROOT_ID) {
    return l_instrument_descriptions(type.description);
  }
  return l_relationships(type.description);
}

export default localizeLinkAttributeTypeDescription;
