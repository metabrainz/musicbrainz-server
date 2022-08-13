/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseList from './components/ReleaseList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportReleaseT} from './types.js';

const MediumsWithOrderInTitle = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={exp.l(
      `This report lists releases where at least one medium has a title
       that seems to just be indicating its position (such a first medium
       with the title “Disc 1”). These should usually be removed, as per
       {release_style|the release guidelines}.`,
      {release_style: '/doc/Style/Release#Medium_title'},
    )}
    entityType="release"
    filtered={filtered}
    generated={generated}
    title={l('Releases with mediums named after their position')}
    totalEntries={pager.total_entries}
  >
    <ReleaseList items={items} pager={pager} />
  </ReportLayout>
);

export default MediumsWithOrderInTitle;
