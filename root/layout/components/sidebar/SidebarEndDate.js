/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {bracketedText}
  from '../../../static/scripts/common/utility/bracketed.js';
import formatDate from '../../../static/scripts/common/utility/formatDate.js';
import isDateEmpty
  from '../../../static/scripts/common/utility/isDateEmpty.js';
import {displayAge} from '../../../utility/age.js';

import {SidebarProperty} from './SidebarProperties.js';

type Props = {
  +age?: [number, number, number] | null,
  +entity:
    | AreaT
    | ArtistT
    | EventT
    | LabelT
    | PlaceT,
  +label: string,
};

const SidebarEndDate = ({
  age,
  entity,
  label,
}: Props): React.MixedElement | null => (
  isDateEmpty(entity.end_date) ? (
    entity.ended ? (
      <SidebarProperty className="end-date" label={label}>
        {l('[unknown]')}
      </SidebarProperty>
    ) : null
  ) : (
    <SidebarProperty className="end-date" label={label}>
      {formatDate(entity.end_date)}
      {age ? (
        ' ' + bracketedText(
          displayAge(
            age,
            entity.entityType === 'artist' && entity.typeID === 1,
          ),
        )
      ) : null}
    </SidebarProperty>
  )
);

export default SidebarEndDate;
