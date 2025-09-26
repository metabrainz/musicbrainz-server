/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  relTypeColumn,
} from '../utility/tableColumns.js';

import ReportLayout from './components/ReportLayout.js';
import WorkList from './components/WorkList.js';
import type {ReportDataT, ReportWorkRelationshipT} from './types.js';

component DeprecatedRelationshipWorks(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportWorkRelationshipT>) {
  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l_reports(
        `This report lists works which have relationships using
         deprecated and grouping-only relationship types.`,
      )}
      entityType="work"
      filtered={filtered}
      generated={generated}
      title={l_reports('Works with deprecated relationships')}
      totalEntries={pager.total_entries}
    >
      <WorkList
        columnsBefore={[relTypeColumn]}
        items={items}
        pager={pager}
      />
    </ReportLayout>
  );
}

export default DeprecatedRelationshipWorks;
