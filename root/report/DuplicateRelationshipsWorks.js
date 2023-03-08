/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ReportLayout from './components/ReportLayout.js';
import WorkList from './components/WorkList.js';
import type {ReportDataT, ReportWorkT} from './types.js';

const DuplicateRelationshipsWorks = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportWorkT>): React$Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report lists works which have multiple relationships
       to the same entity using the same relationship type.
       This excludes recording-work relationships. See the recording
       version of this report for those.`,
    )}
    entityType="work"
    filtered={filtered}
    generated={generated}
    title={l('Works with possible duplicate relationships')}
    totalEntries={pager.total_entries}
  >
    <WorkList items={items} pager={pager} />
  </ReportLayout>
);

export default DuplicateRelationshipsWorks;
