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

component TracksNamedWithSequence(...{
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
        `This report aims to identify releases where track names include
         their own track number, such as "1) Some Name" (instead of just
         "Some Name"). Notice that sometimes this is justified and correct,
         don't automatically assume it is a mistake! If you confirm it
         is a mistake, please correct it.`,
      )}
      entityType="release"
      filtered={filtered}
      generated={generated}
      title={l_reports(
        'Releases where track names start with their track number',
      )}
      totalEntries={pager.total_entries}
    >
      <ReleaseList items={items} pager={pager} />
    </ReportLayout>
  );
}

export default TracksNamedWithSequence;
