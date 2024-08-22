/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ReleaseList from './components/ReleaseList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportReleaseT} from './types.js';

component ReleasedTooEarlyDigital(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>) {
  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l_reports(
        `This report shows releases with at least one medium set to format
         “Digital Media” which were released before 1999, the launch date
         for the first digital music store supported by a major label.
         While digital releases did exist before this, and not everything
         older is automatically incorrect, a lot of releases that end up
         here are likely to be digital reissues of older content that have
         been incorrectly assigned the release date for the original,
         physical release.`,
      )}
      entityType="release"
      filtered={filtered}
      generated={generated}
      title={l_reports('Suspiciously early digital releases')}
      totalEntries={pager.total_entries}
    >
      <ReleaseList items={items} pager={pager} />
    </ReportLayout>
  );
}

export default ReleasedTooEarlyDigital;
