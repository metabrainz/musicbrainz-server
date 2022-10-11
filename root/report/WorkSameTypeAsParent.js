/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReportLayout from './components/ReportLayout.js';
import WorkList from './components/WorkList.js';
import type {ReportDataT, ReportWorkT} from './types.js';

const WorkSameTypeAsParent = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportWorkT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={exp.l(
      `This report shows works with at least one parent work that has the same
       work type as them (such as a work marked as a sonata which is part of
       another sonata). In most cases, that means these works should have
       a different type or (most likely) no type at all, as per
       {work_style_doc|the work guidelines}. Sometimes the parent work
       type might be the one that needs to be changed.`,
      {work_style_doc: '/doc/Style/Work'},
    )}
    entityType="work"
    filtered={filtered}
    generated={generated}
    title={l('Works with the same type as their parent')}
    totalEntries={pager.total_entries}
  >
    <WorkList items={items} pager={pager} />
  </ReportLayout>
);

export default WorkSameTypeAsParent;
