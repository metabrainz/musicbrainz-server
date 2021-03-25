/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import LabelRelationshipList from './components/LabelRelationshipList';
import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportLabelRelationshipT} from './types';

const DeprecatedRelationshipLabels = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportLabelRelationshipT>):
React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report lists labels which have relationships using
       deprecated and grouping-only relationship types.`,
    )}
    entityType="label"
    filtered={filtered}
    generated={generated}
    title={l('Labels with deprecated relationships')}
    totalEntries={pager.total_entries}
  >
    <LabelRelationshipList items={items} pager={pager} />
  </ReportLayout>
);

export default DeprecatedRelationshipLabels;
