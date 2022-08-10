/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {
  relTypeColumn,
} from '../utility/tableColumns.js';

import WorkList from './components/WorkList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportWorkRelationshipT} from './types.js';

const DeprecatedRelationshipWorks = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportWorkRelationshipT>):
React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report lists works which have relationships using
       deprecated and grouping-only relationship types.`,
    )}
    entityType="work"
    filtered={filtered}
    generated={generated}
    title={l('Works with deprecated relationships')}
    totalEntries={pager.total_entries}
  >
    <WorkList
      columnsBefore={[relTypeColumn]}
      items={items}
      pager={pager}
    />
  </ReportLayout>
);

export default DeprecatedRelationshipWorks;
