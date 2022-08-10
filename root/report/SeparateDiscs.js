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

const SeparateDiscs = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows releases which have
       (disc n) or (bonus disc) in the title.`,
    )}
    entityType="release"
    extraInfo={exp.l(
      `For instructions on how to fix them, please see
       the documentation about {howto|how to merge releases}.`,
      {howto: '/doc/How_to_Merge_Releases'},
    )}
    filtered={filtered}
    generated={generated}
    title={l('Discs as separate releases')}
    totalEntries={pager.total_entries}
  >
    <ReleaseList items={items} pager={pager} />
  </ReportLayout>
);

export default SeparateDiscs;
