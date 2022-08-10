/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseList from './components/ReleaseList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportReleaseT} from './types.js';

const SuperfluousDataTracks = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={exp.l(
      `This report lists releases without any disc IDs that probably
       contain data tracks (like videos) at the end of a medium, but have
       no tracks marked as data tracks. A data track should be marked as
       such if it is the last track of the CD and contains audio or video.
       Otherwise, it should just be removed. See the
       {data_track_guidelines|data track guidelines}.`,
      {
        data_track_guidelines:
          '/doc/Style/Unknown_and_untitled/' +
          'Special_purpose_track_title#Data_tracks',
      },
    )}
    entityType="release"
    filtered={filtered}
    generated={generated}
    title={l('Releases with superfluous data tracks')}
    totalEntries={pager.total_entries}
  >
    <ReleaseList items={items} pager={pager} />
  </ReportLayout>
);

export default SuperfluousDataTracks;
