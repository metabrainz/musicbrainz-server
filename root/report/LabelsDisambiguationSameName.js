/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import LabelList from './components/LabelList';
import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportLabelT} from './types';

const LabelsDisambiguationSameName = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportLabelT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    canBeFiltered={canBeFiltered}
    description={l(
      `This report lists labels that have their disambiguation set
       to be the same as their name.
       The disambiguation should be removed or, if it is needed, improved.`,
    )}
    entityType="label"
    filtered={filtered}
    generated={generated}
    title={l('Labels with disambiguation the same as the name')}
    totalEntries={pager.total_entries}
  >
    <LabelList items={items} pager={pager} />
  </ReportLayout>
);

export default LabelsDisambiguationSameName;
