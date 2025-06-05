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

component PseudoReleasesWithCoverArt(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>) {
  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={exp.l(
        `This report shows pseudo-releases that have images in the Cover
         Art Archive. Pseudo-releases {style|should not have cover art},
         except temporarily until an official release has been added.`,
        {style: '/doc/Style/Specific_types_of_releases/Pseudo-Releases'},
      )}
      entityType="release"
      filtered={filtered}
      generated={generated}
      title={l('Pseudo-Releases that have cover art')}
      totalEntries={pager.total_entries}
    >
      <ReleaseList items={items} pager={pager} />
    </ReportLayout>
  );
}

export default PseudoReleasesWithCoverArt;
