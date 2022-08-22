/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {
  defineEntityColumn,
} from '../utility/tableColumns.js';

import ReleaseList from './components/ReleaseList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportReleaseReleaseGroupT} from './types.js';

const ReleaseRgDifferentName = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseReleaseGroupT>):
React.Element<typeof ReportLayout> => {
  const releaseGroupColumn = defineEntityColumn<ReportReleaseReleaseGroupT>({
    columnName: 'release_group',
    descriptive: false,
    getEntity: result => result.release_group ?? null,
    title: l('Release Group'),
  });

  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l(
        `This report shows releases which are the only ones in their release
         group, yet have a different name than the group. This might mean
         one of the two needs to be renamed to match the other.`,
      )}
      entityType="release"
      filtered={filtered}
      generated={generated}
      title={l('Releases with a different name than their release group')}
      totalEntries={pager.total_entries}
    >
      <ReleaseList
        columnsBefore={[releaseGroupColumn]}
        items={items}
        pager={pager}
      />
    </ReportLayout>
  );
};

export default ReleaseRgDifferentName;
