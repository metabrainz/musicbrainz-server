/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ReleaseList from './components/ReleaseList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportReleaseT} from './types.js';

component ReleasedTooEarly(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>) {
  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={exp.l_reports(
        `This report shows releases which have disc IDs even though they
         were released too early to have disc IDs, where one of the medium
         formats didn't exist at the time the release was released or
         where a disc ID is attached to a medium whose format does not
         have disc IDs. Fully digital releases are excluded; for those, see
         {digital_report|our digital-only report}.`,
        {digital_report: '/report/ReleasedTooEarlyDigital'},
      )}
      entityType="release"
      filtered={filtered}
      generated={generated}
      title={l_reports('Releases released too early')}
      totalEntries={pager.total_entries}
    >
      <ReleaseList items={items} pager={pager} />
    </ReportLayout>
  );
}

export default ReleasedTooEarly;
