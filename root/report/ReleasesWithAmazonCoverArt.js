/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseList from './components/ReleaseList';
import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportReleaseT} from './types';

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
      `This report shows releases which have cover art from Amazon, but have
       no front cover in the Cover Art Archive. The use of Amazon art
       is going to be discontinued eventually, so these releases will lose
       their front cover unless one is added to the Cover Art Archive.`,
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
