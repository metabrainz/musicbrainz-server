/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {
  relTypeColumn,
} from '../utility/tableColumns.js';

import ReleaseGroupList from './components/ReleaseGroupList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportReleaseGroupRelationshipT} from './types.js';

const DeprecatedRelationshipReleaseGroups = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseGroupRelationshipT>):
React$Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report lists release groups which have relationships using
       deprecated and grouping-only relationship types.`,
    )}
    entityType="release_group"
    filtered={filtered}
    generated={generated}
    title={l('Release groups with deprecated relationships')}
    totalEntries={pager.total_entries}
  >
    <ReleaseGroupList
      columnsBefore={[relTypeColumn]}
      items={items}
      pager={pager}
    />
  </ReportLayout>
);

export default DeprecatedRelationshipReleaseGroups;
