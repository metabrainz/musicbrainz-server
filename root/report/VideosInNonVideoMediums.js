/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import RecordingList from './components/RecordingList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportRecordingT} from './types.js';

const VideosInNonVideoMediums = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportRecordingT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows recordings marked as video, but that appear in
       at least one medium that does not support videos.`,
    )}
    entityType="recording"
    extraInfo={exp.l(
      `There are two main possibilities here: either the recording being
       marked as a video is correct, but the format is not (a CD should be a
       VCD, for example), or the recording is being used for both a video and 
       and audio-only recording, in which case the two should be split since
       video recordings should always be separate. If you split the
       recordings, consider whether it makes sense to link them with a
       {doc_link|music video relationship}.`,
      {doc_link: '/relationship/ce3de655-7451-44d1-9224-87eb948c205d'},
    )}
    filtered={filtered}
    generated={generated}
    title={l('Video recordings in non-video mediums')}
    totalEntries={pager.total_entries}
  >
    <RecordingList items={items} pager={pager} />
  </ReportLayout>
);

export default VideosInNonVideoMediums;
