/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import LabelUrlList from './components/LabelUrlList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportLabelUrlT} from './types.js';

component DiscogsLinksWithMultipleLabels(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportLabelUrlT>) {
  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l_reports(
        `This report shows Discogs URLs which are linked to multiple labels.`,
      )}
      entityType="label"
      filtered={filtered}
      generated={generated}
      title={l_reports('Discogs URLs linked to multiple labels')}
      totalEntries={pager.total_entries}
    >
      <LabelUrlList items={items} pager={pager} />
    </ReportLayout>
  );
}

export default DiscogsLinksWithMultipleLabels;
