/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {bracketedText}
  from '../../../static/scripts/common/utility/bracketed';
import formatDate from '../../../static/scripts/common/utility/formatDate';
import isDateEmpty from '../../../static/scripts/common/utility/isDateEmpty';
import {displayAgeAgo} from '../../../utility/age';

import {SidebarProperty} from './SidebarProperties';

type Props = {
  +age?: [number, number, number] | null,
  +entity: $ReadOnly<{...DatePeriodRoleT, ...}>,
  +label: string,
};

const SidebarBeginDate = ({age, entity, label}: Props) => (
  isDateEmpty(entity.begin_date) ? (
    null
  ) : (
    <SidebarProperty className="begin-date" label={label}>
      {formatDate(entity.begin_date)}
      {(age && isDateEmpty(entity.end_date))
        ? ' ' + bracketedText(displayAgeAgo(age))
        : null}
    </SidebarProperty>
  )
);

export default SidebarBeginDate;
