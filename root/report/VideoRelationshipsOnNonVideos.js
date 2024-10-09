/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import commaList from '../static/scripts/common/i18n/commaList.js';

import RecordingList from './components/RecordingList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportRecordingT} from './types.js';

const videoRelationships = [
  'animation',
  'artwork',
  'choreographer',
  'cinematographer',
  'design',
  'graphic design',
  'illustration',
  'video appearance',
  'video director',
];

component VideoRelationshipsOnNonVideos(...{
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
        `This report shows recordings not marked as video, but that use
         relationships meant only for video recordings ({relationship_list}).
         Either they should be marked as video, or the relationships should
         be moved to a related video recording.`,
        {
          relationship_list: commaList(
            videoRelationships.map(x => addQuotesText(l_relationships(x))),
          ),
        },
      )}
      entityType="recording"
      filtered={filtered}
      generated={generated}
      title={l_reports('Non-video recordings with video relationships')}
      totalEntries={pager.total_entries}
    >
      <RecordingList items={items} pager={pager} />
    </ReportLayout>
  );
}

export default VideoRelationshipsOnNonVideos;
