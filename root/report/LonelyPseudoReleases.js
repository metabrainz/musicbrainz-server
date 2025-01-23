/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ReleaseList from './components/ReleaseList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportReleaseT} from './types.js';

component LonelyPseudoReleases(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>) {
  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l(
        `This report shows releases with status “Pseudo-Release” that are
         in release groups that contain only pseudo-releases.
         This should never be fully correct; either the release is not really
         a pseudo-release (being, for example, a badly indicated bootleg),
         or the official release is missing and needs to be added.`,
      )}
      entityType="release"
      filtered={filtered}
      generated={generated}
      title={l(
        'Pseudo-releases in release groups that contain only pseudo-releases',
      )}
      totalEntries={pager.total_entries}
    >
      <ReleaseList items={items} pager={pager} />
    </ReportLayout>
  );
}

export default LonelyPseudoReleases;
