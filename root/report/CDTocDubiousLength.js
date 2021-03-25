/*
 * @flow strict-local
 * Copyright (C) 2020 Jerome Roy
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import CDTocList from './components/CDTocList';
import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportCDTocT} from './types';

const CDTocDubiousLength = ({
  canBeFiltered,
  generated,
  filtered,
  items,
  pager,
}: ReportDataT<ReportCDTocT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows disc IDs indicating a total duration much longer
       than what a standard CD allows (at least 88 minutes for a CD, or 30
       minutes for a mini-CD). This usually means a disc ID was created for
       the wrong format (SACD) or with a buggy tool.`,
    )}
    entityType="discId"
    filtered={filtered}
    generated={generated}
    title={l('Disc IDs with dubious duration')}
    totalEntries={pager.total_entries}
  >
    <CDTocList items={items} pager={pager} />
  </ReportLayout>
);

export default CDTocDubiousLength;
