/*
 * @flow strict-local
 * Copyright (C) 2021 Jerome Roy
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import CDTocReleaseList from './components/CDTocReleaseList';
import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportCDTocReleaseT} from './types';

const CDTocNotApplied = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportCDTocReleaseT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows disc IDs attached to a release but obviously not
       applied because at last one track duration is unknown on the release.
       The report is also restricted to mediums where only one disc ID is
       attached, so it is highly likely that the disc ID can be applied
       without any worries. Do make sure though that no existing durations
       clash with the disc ID, or that any clashes are clear mistakes.`,
    )}
    entityType="discId"
    filtered={filtered}
    generated={generated}
    title={l('Disc IDs attached but not applied')}
    totalEntries={pager.total_entries}
  >
    <CDTocReleaseList items={items} pager={pager} />
  </ReportLayout>
);

export default CDTocNotApplied;
