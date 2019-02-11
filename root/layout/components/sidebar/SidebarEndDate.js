/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {l} from '../../../static/scripts/common/i18n';
import {bracketedText} from '../../../static/scripts/common/utility/bracketed';
import formatDate from '../../../static/scripts/common/utility/formatDate';
import isDateEmpty from '../../../static/scripts/common/utility/isDateEmpty';
import {displayAge} from '../../../utility/age';

import {SidebarProperty} from './SidebarProperties';

type Props = {|
  +age?: [number, number, number] | null,
  +entity:
    | AreaT
    | ArtistT
    | EventT
    | LabelT
    | PlaceT,
  +label: string,
|};

const SidebarEndDate = ({age, entity, label}: Props) => (
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
