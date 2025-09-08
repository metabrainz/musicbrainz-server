/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import RecordingList from './components/RecordingList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportRecordingT} from './types.js';

component RecordingsWithDuplicateWorks(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportRecordingT>) {
  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l(
        `This report lists recordings which are linked several times
         to the same work or to works of the same name. While this can
         be correct, in most cases either the relationships or the works
         will be duplicated.`,
      )}
      entityType="recording"
      filtered={filtered}
      generated={generated}
      title={l('Recordings with possible duplicate works')}
      totalEntries={pager.total_entries}
    >
      <RecordingList items={items} pager={pager} />
    </ReportLayout>
  );
}

export default RecordingsWithDuplicateWorks;
