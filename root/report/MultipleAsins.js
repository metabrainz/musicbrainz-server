/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ReleaseList from './components/ReleaseList';
import ReportLayout from './components/ReportLayout';
import type {ReportDataT, ReportReleaseT} from './types';

const MultipleAsins = ({
  $c,
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportReleaseT>): React.Element<typeof ReportLayout> => (
  <ReportLayout
    $c={$c}
    canBeFiltered={canBeFiltered}
    description={l(
      `This report shows releases that have more than one Amazon ASIN.
       In most cases ASINs should map to MusicBrainz releases 1:1, so
       only one of them will be correct. Just check which ones do not
       fit the release (because of format, different number of tracks,
       etc). If the release has a barcode, you can search Amazon for it
       and see which ASIN matches.`,
    )}
    entityType="release"
    filtered={filtered}
    generated={generated}
    title={l('Releases with multiple ASINs')}
    totalEntries={pager.total_entries}
  >
    <ReleaseList items={items} pager={pager} />
  </ReportLayout>
);

export default MultipleAsins;
