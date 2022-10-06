/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import formatBarcode from '../static/scripts/common/utility/formatBarcode.js';
import {
  defineEntityColumn,
  defineTextColumn,
} from '../utility/tableColumns.js';

import ReleaseList from './components/ReleaseList.js';
import ReportLayout from './components/ReportLayout.js';
import type {ReportDataT} from './types.js';

type ReportRowT = {
  +barcode: string,
  +release: ?ReleaseT,
  +release_group: ?ReleaseGroupT,
  +release_group_id: number,
  +release_id: number,
  +row_number: number,
};

const ReleasesSameBarcode = ({
  canBeFiltered,
  filtered,
  generated,
  items,
  pager,
}: ReportDataT<ReportRowT>): React.Element<typeof ReportLayout> => {
  const barcodeColumn = defineTextColumn<ReportRowT>({
    cellProps: {className: 'barcode-cell'},
    columnName: 'barcode',
    getText: result => formatBarcode(result.barcode),
    title: l('Barcode'),
  });
  const releaseGroupColumn = defineEntityColumn<ReportRowT>({
    columnName: 'release_group',
    descriptive: false,
    getEntity: result => result.release_group ?? null,
    title: l('Release Group'),
  });

  return (
    <ReportLayout
      canBeFiltered={canBeFiltered}
      description={l(
        `This report shows non-bootleg releases which have
         the same barcode, yet are placed in different release groups.
         Chances are that the releases are duplicates or parts of a set,
         or at least that the release groups should be merged.`,
      )}
      entityType="release"
      filtered={filtered}
      generated={generated}
      title={l('Releases with the same barcode in different release groups')}
      totalEntries={pager.total_entries}
    >
      <ReleaseList
        columnsBefore={[barcodeColumn, releaseGroupColumn]}
        items={items}
        pager={pager}
      />
    </ReportLayout>
  );
};

export default ReleasesSameBarcode;
