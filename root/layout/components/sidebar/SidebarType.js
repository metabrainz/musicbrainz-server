/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import linkedEntities
  from '../../../static/scripts/common/linkedEntities.mjs';

import {SidebarProperty} from './SidebarProperties.js';

type EntityWithSidebarTypeT =
  | 'area_type'
  | 'artist_type'
  | 'event_type'
  | 'instrument_type'
  | 'label_type'
  | 'place_type'
  | 'series_type'
  | 'work_type';

component SidebarType(
  entity: $ReadOnly<{...TypeRoleT<empty>, ...}>,
  typeType: EntityWithSidebarTypeT,
) {
  const typeId = entity.typeID;
  return (
    typeId == null ? null : (
      <SidebarProperty className="type" label={addColonText(l('Type'))}>
        {lp_attributes(
          linkedEntities[typeType][typeId].name,
          typeType,
        )}
      </SidebarProperty>
    )
  );
}

export default SidebarType;
