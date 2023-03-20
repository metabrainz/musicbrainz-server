/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ReleaseList from './components/ReleaseList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportReleaseT} from './types.js';

const ReleasesConflictingDiscIds = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>): React$Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows releases that have conflicting disc IDs on the
       same medium with significant differences in duration. This usually
       means a disc ID was applied to the wrong medium or the wrong release.`,
    )}
    entityType="release"
    filtered={filtered}
    generated={generated}
    title={l('Releases with conflicting disc IDs')}
    totalEntries={pager.total_entries}
  >
    <ReleaseList items={items} pager={pager} subPath="discids" />
  </ReportLayout>
);

export default ReleasesConflictingDiscIds;
