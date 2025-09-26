/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import LabelList from './components/LabelList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportLabelT} from './types.js';

component LabelsWithMismatchedPrimaryAliases(...{
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
        `This report lists labels that have at least one alias marked as
         primary for a locale, but have no primary aliases that match their
         name. In general, the main name for a label should always be
         its primary alias in the language of the name.`,
      )}
      entityType="label"
      filtered={filtered}
      generated={generated}
      title={l_reports('Labels with mismatched primary aliases')}
      totalEntries={pager.total_entries}
    >
      <LabelList items={items} pager={pager} />
    </ReportLayout>
  );
}

export default LabelsWithMismatchedPrimaryAliases;
