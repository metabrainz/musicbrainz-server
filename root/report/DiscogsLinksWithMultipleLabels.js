/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import LabelUrlList from './components/LabelUrlList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT, ReportLabelUrlT} from './types.js';

const DiscogsLinksWithMultipleLabels = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportLabelUrlT>):
React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows Discogs URLs which are linked to multiple labels.`,
    )}
    entityType="label"
    filtered={filtered}
    generated={generated}
    title={l('Discogs URLs linked to multiple labels')}
    totalEntries={pager.total_entries}
  >
    <LabelUrlList items={items} pager={pager} />
  </ReportLayout>
);

export default DiscogsLinksWithMultipleLabels;
