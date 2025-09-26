/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ReleaseGroupList from './components/ReleaseGroupList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportReleaseGroupT} from './types.js';

component DuplicateRelationshipsReleaseGroups(...{
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseGroupT>) {
  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l_reports(
        `This report lists release groups which have multiple relationships
         to the same entity using the same relationship type.`,
      )}
      entityType="release_group"
      filtered={filtered}
      generated={generated}
      title={l_reports(
        'Release groups with possible duplicate relationships',
      )}
      totalEntries={pager.total_entries}
    >
      <ReleaseGroupList items={items} pager={pager} />
    </ReportLayout>
  );
}

export default DuplicateRelationshipsReleaseGroups;
