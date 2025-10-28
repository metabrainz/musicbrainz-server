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
import UrlList from './components/UrlList.js';
import type {ReportDataT, ReportUrlRelationshipT} from './types.js';

component DeprecatedRelationshipUrls(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportUrlRelationshipT>) {
  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l_reports(
        `This report lists URLs which have relationships using
         deprecated and grouping-only relationship types.`,
      )}
      entityType="url"
      filtered={filtered}
      generated={generated}
      title={l_reports('URLs with deprecated relationships')}
      totalEntries={pager.total_entries}
    >
      <UrlList
        columnsBefore={[relTypeColumn]}
        items={items}
        pager={pager}
      />
    </ReportLayout>
  );
}

export default DeprecatedRelationshipUrls;
