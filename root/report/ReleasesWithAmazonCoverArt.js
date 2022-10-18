/*
 * @flow strict
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

const ReleasesWithAmazonCoverArt = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows releases which have cover art on Amazon, but have
       no front cover in the Cover Art Archive. The use of Amazon art has been
       discontinued since the 16th of May 2022, so these releases have no
       front cover anymore until one is added to the Cover Art Archive.`,
    )}
    entityType="release"
    filtered={filtered}
    generated={generated}
    title={l(
      `Releases that have Amazon cover art
       but no Cover Art Archive front cover`,
    )}
    totalEntries={pager.total_entries}
  >
    <ReleaseList items={items} pager={pager} />
  </ReportLayout>
);

export default ReleasesWithAmazonCoverArt;
