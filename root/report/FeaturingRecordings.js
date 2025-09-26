/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import RecordingList from './components/RecordingList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportRecordingT} from './types.js';

component FeaturingRecordings(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportRecordingT>) {
  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={exp.l_reports(
        `This report shows recordings with “(feat. Artist)” 
         (or similar) in the title. For classical recordings, 
         consult the {CSG|classical style guidelines}. For 
         non-classical recordings, this is usually inherited from an
         older version of MusicBrainz and should be fixed  (both on 
         the recordings and on the tracks!). Consult the
         {featured_artists|page about featured artists} to know more.`,
        {
          CSG: '/doc/Style/Classical',
          featured_artists: '/doc/Style/Artist_Credits#Featured_artists',
        },
      )}
      entityType="recording"
      filtered={filtered}
      generated={generated}
      title={l_reports('Recordings with titles containing featuring artists')}
      totalEntries={pager.total_entries}
    >
      <RecordingList items={items} pager={pager} />
    </ReportLayout>
  );
}

export default FeaturingRecordings;
