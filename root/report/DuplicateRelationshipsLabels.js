/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import LabelList from './components/LabelList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportLabelT} from './types.js';

component DuplicateRelationshipsLabels(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportLabelT>) {
  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l_reports(
        `This report lists labels which have multiple relationships
         to the same entity using the same relationship type.`,
      )}
      entityType="label"
      filtered={filtered}
      generated={generated}
      title={l_reports('Labels with possible duplicate relationships')}
      totalEntries={pager.total_entries}
    >
      <LabelList items={items} pager={pager} />
    </ReportLayout>
  );
}

export default DuplicateRelationshipsLabels;
