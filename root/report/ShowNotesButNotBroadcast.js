/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ReleaseList from './components/ReleaseList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportReleaseT} from './types.js';

const ShowNotesButNotBroadcast = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>): React$Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={exp.l(
      `This report shows releases that have a {doc|show notes relationship},
       but are not in a release group of type Broadcast.
       Show notes are meant for podcasts and similar shows, and should
       not be used to link to some random notes about any sort of release,
       yet the relationship often gets used in that way. If that is the case,
       the relationship should be either switched to a better type or removed
       if nothing is a good fit. If the release is indeed a podcast, the
       release group type should be set to Broadcast.`,
      {doc: '/relationship/2d24d075-9943-4c4d-a659-8ce52e6e6b57'},
    )}
    entityType="release"
    filtered={filtered}
    generated={generated}
    title={l('Non-broadcast releases with linked show notes')}
    totalEntries={pager.total_entries}
  >
    <ReleaseList items={items} pager={pager} />
  </ReportLayout>
);

export default ShowNotesButNotBroadcast;
