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

component LabelsDisambiguationSameName(...{
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
        `This report lists labels that have their disambiguation set
         to be the same as their name.
         The disambiguation should be removed or, if it is needed, improved.`,
      )}
      entityType="label"
      filtered={filtered}
      generated={generated}
      title={l_reports('Labels with disambiguation the same as the name')}
      totalEntries={pager.total_entries}
    >
      <LabelList items={items} pager={pager} />
    </ReportLayout>
  );
}

export default LabelsDisambiguationSameName;
