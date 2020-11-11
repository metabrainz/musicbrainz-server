/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseRelationshipList from './components/ReleaseRelationshipList';
import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportReleaseRelationshipT} from './types';

const DeprecatedRelationshipReleases = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseRelationshipT>):
React.Element<typeof ReportLayout> => (
  <ReportLayout
    $c={$c}
    canBeFiltered={canBeFiltered}
    description={l(
      `This report lists releases which have relationships using
       deprecated and grouping-only relationship types.`,
    )}
    entityType="release"
    filtered={filtered}
    generated={generated}
    title={l('Releases with deprecated relationships')}
    totalEntries={pager.total_entries}
  >
    <ReleaseRelationshipList items={items} pager={pager} />
  </ReportLayout>
);

export default DeprecatedRelationshipReleases;
