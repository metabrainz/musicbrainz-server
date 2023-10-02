/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseList from './components/ReleaseList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportReleaseT} from './types.js';

const LowQualityReleases = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows releases that have been marked as low quality.
       If you have some time, you can review them and try to improve the data
       as much as possible before changing their quality back to Normal
       (or even to High, if you add all the possible data!). If a release
       has already been improved but the quality wasn’t changed accordingly,
       just enter a data quality change to remove it from this report.`,
    )}
    entityType="release"
    filtered={filtered}
    generated={generated}
    title={l('Releases marked as low quality')}
    totalEntries={pager.total_entries}
  >
    <ReleaseList items={items} pager={pager} />
  </ReportLayout>
);

export default LowQualityReleases;
