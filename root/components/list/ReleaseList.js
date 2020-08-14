/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import useTable from '../../hooks/useTable';
import filterReleaseLabels
  from '../../static/scripts/common/utility/filterReleaseLabels';
import formatBarcode from '../../static/scripts/common/utility/formatBarcode';
import {
  defineArtistCreditColumn,
  defineCheckboxColumn,
  defineInstrumentUsageColumn,
  defineNameColumn,
  defineReleaseCatnosColumn,
  defineReleaseEventsColumn,
  defineReleaseLabelsColumn,
  defineSeriesNumberColumn,
  defineTextColumn,
  taggerColumn,
} from '../../utility/tableColumns';

type Props = {
  ...InstrumentCreditsAndRelTypesRoleT,
  ...SeriesItemNumbersRoleT,
  +$c: CatalystContextT,
  +checkboxes?: string,
  +filterLabel?: LabelT,
  +order?: string,
  +releases: $ReadOnlyArray<ReleaseT>,
  +showInstrumentCreditsAndRelTypes?: boolean,
  +sortable?: boolean,
};

const ReleaseList = ({
  $c,
  checkboxes,
  filterLabel,
  instrumentCreditsAndRelTypes,
  order,
  releases,
  seriesItemNumbers,
  showInstrumentCreditsAndRelTypes,
  sortable,
}: Props): React.Element<'table'> => {
  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && checkboxes
        ? defineCheckboxColumn({name: checkboxes})
        : null;
      const seriesNumberColumn = seriesItemNumbers
        ? defineSeriesNumberColumn({seriesItemNumbers: seriesItemNumbers})
        : null;
      const nameColumn = defineNameColumn<ReleaseT>({
        descriptive: false, // since ACs are in the next column
        order: order,
        showCaaPresence: true,
        sortable: sortable,
        title: l('Release'),
      });
      const artistCreditColumn = defineArtistCreditColumn<ReleaseT>({
        columnName: 'artist',
        getArtistCredit: entity => entity.artistCredit,
        order: order,
        sortable: sortable,
        title: l('Artist'),
      });
      const formatColumn = defineTextColumn<ReleaseT>({
        columnName: 'format',
        getText:
          entity => entity.combined_format_name || l('[missing media]'),
        order: order,
        sortable: sortable,
        title: l('Format'),
      });
      const tracksColumn = defineTextColumn<ReleaseT>({
        columnName: 'tracks',
        getText:
          entity => entity.combined_track_count || lp('-', 'missing data'),
        order: order,
        sortable: sortable,
        title: l('Tracks'),
      });
      const releaseEventsColumn = defineReleaseEventsColumn({
        order: order,
        sortable: sortable,
      });
      const labelsColumn = filterLabel
        ? null
        : defineReleaseLabelsColumn({
          order: order,
          sortable: sortable,
        });
      const catnosColumn = defineReleaseCatnosColumn({
        getLabels: entity => (entity.labels && filterLabel)
          ? filterReleaseLabels(entity.labels, filterLabel)
          : entity.labels,
        order: order,
        sortable: sortable,
      });
      const barcodeColumn = defineTextColumn<ReleaseT>({
        cellProps: {className: 'barcode-cell'},
        columnName: 'barcode',
        getText: entity => formatBarcode(entity.barcode),
        order: order,
        sortable: sortable,
        title: l('Barcode'),
      });
      const instrumentUsageColumn = showInstrumentCreditsAndRelTypes
        ? defineInstrumentUsageColumn({
          instrumentCreditsAndRelTypes: instrumentCreditsAndRelTypes,
        })
        : null;

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        ...(seriesNumberColumn ? [seriesNumberColumn] : []),
        nameColumn,
        artistCreditColumn,
        formatColumn,
        tracksColumn,
        releaseEventsColumn,
        ...(labelsColumn ? [labelsColumn] : []),
        catnosColumn,
        barcodeColumn,
        ...(instrumentUsageColumn ? [instrumentUsageColumn] : []),
        ...($c.session?.tport ? [taggerColumn] : []),
      ];
    },
    [
      $c.session,
      $c.user,
      checkboxes,
      filterLabel,
      instrumentCreditsAndRelTypes,
      order,
      seriesItemNumbers,
      showInstrumentCreditsAndRelTypes,
      sortable,
    ],
  );

  return useTable<ReleaseT>({
    columns,
    data: releases,
  });
};

export default ReleaseList;
