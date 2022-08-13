/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import linkedEntities
  from '../../../static/scripts/common/linkedEntities.mjs';

import {SidebarProperty} from './SidebarProperties.js';

type Props = {
  +entity: $ReadOnly<{...TypeRoleT<empty>, ...}>,
  +typeType: string,
};

const SidebarType = ({
  entity,
  typeType,
}: Props): React.MixedElement | null => (
  entity.typeID == null ? null : (
    <SidebarProperty className="type" label={l('Type:')}>
      {lp_attributes(
        linkedEntities[typeType][entity.typeID].name,
        typeType,
      )}
    </SidebarProperty>
  )
);

export default SidebarType;
