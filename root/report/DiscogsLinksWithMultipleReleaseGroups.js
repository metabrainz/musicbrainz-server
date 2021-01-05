/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseGroupUrlList from './components/ReleaseGroupUrlList';
import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportReleaseGroupUrlT} from './types';

const DiscogsLinksWithMultipleReleaseGroups = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseGroupUrlT>):
React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows Discogs URLs which are linked
       to multiple release groups.`,
    )}
    entityType="release_group"
    filtered={filtered}
    generated={generated}
    title={l('Discogs URLs linked to multiple release groups')}
    totalEntries={pager.total_entries}
  >
    <ReleaseGroupUrlList items={items} pager={pager} />
  </ReportLayout>
);

export default DiscogsLinksWithMultipleReleaseGroups;
