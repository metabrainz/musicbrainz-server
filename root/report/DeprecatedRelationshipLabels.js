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

import LabelList from './components/LabelList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportLabelRelationshipT} from './types.js';

component DeprecatedRelationshipLabels(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportLabelRelationshipT>) {
  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l_reports(
        `This report lists labels which have relationships using
         deprecated and grouping-only relationship types.`,
      )}
      entityType="label"
      filtered={filtered}
      generated={generated}
      title={l_reports('Labels with deprecated relationships')}
      totalEntries={pager.total_entries}
    >
      <LabelList
        columnsBefore={[relTypeColumn]}
        items={items}
        pager={pager}
      />
    </ReportLayout>
  );
}

export default DeprecatedRelationshipLabels;
