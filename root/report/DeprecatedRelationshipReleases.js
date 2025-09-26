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

import ReleaseList from './components/ReleaseList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportReleaseRelationshipT} from './types.js';

component DeprecatedRelationshipReleases(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseRelationshipT>) {
  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l_reports(
        `This report lists releases which have relationships using
         deprecated and grouping-only relationship types.`,
      )}
      entityType="release"
      filtered={filtered}
      generated={generated}
      title={l_reports('Releases with deprecated relationships')}
      totalEntries={pager.total_entries}
    >
      <ReleaseList
        columnsBefore={[relTypeColumn]}
        items={items}
        pager={pager}
      />
    </ReportLayout>
  );
}

export default DeprecatedRelationshipReleases;
