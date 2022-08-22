/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseGroupList from './components/ReleaseGroupList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportReleaseGroupT} from './types.js';

const ReleaseGroupsWithoutVaCredit = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseGroupT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows release groups linked to the Various Artists
       entity without "Various Artists" as the credited name.`,
    )}
    entityType="release_group"
    filtered={filtered}
    generated={generated}
    title={l(
      'Release groups not credited to "Various Artists" but linked to VA',
    )}
    totalEntries={pager.total_entries}
  >
    <ReleaseGroupList items={items} pager={pager} />
  </ReportLayout>
);

export default ReleaseGroupsWithoutVaCredit;
