/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {withCatalystContext} from '../../../context';
import {l} from '../../../static/scripts/common/i18n';
import {l_attributes} from '../../../static/scripts/common/i18n/attributes';

import {SidebarProperty} from './SidebarProperties';

type Props = {|
  +$c: CatalystContextT,
  +entity: {...TypeRoleT<OptionTreeT>},
  +typeType: string,
|};

const SidebarType = ({$c, entity, typeType}: Props) => (
  entity.typeID ? (
    <SidebarProperty className="type" label={l('Type:')}>
      {l_attributes($c.linked_entities[typeType][entity.typeID].name)}
    </SidebarProperty>
  ) : null
);

export default withCatalystContext(SidebarType);
