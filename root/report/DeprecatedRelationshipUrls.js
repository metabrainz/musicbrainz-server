/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import UrlRelationshipList from './components/UrlRelationshipList';
import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportUrlRelationshipT} from './types';

const DeprecatedRelationshipUrls = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportUrlRelationshipT>):
React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report lists URLs which have relationships using
       deprecated and grouping-only relationship types.`,
    )}
    entityType="url"
    filtered={filtered}
    generated={generated}
    title={l('URLs with deprecated relationships')}
    totalEntries={pager.total_entries}
  >
    <UrlRelationshipList items={items} pager={pager} />
  </ReportLayout>
);

export default DeprecatedRelationshipUrls;
