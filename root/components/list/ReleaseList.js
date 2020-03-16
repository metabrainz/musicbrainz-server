/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Table from '../Table';
import {withCatalystContext} from '../../context';
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
  ratingsColumn,
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
  +showRatings?: boolean,
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
  showRatings,
  sortable,
}: Props) => {
  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user_exists && checkboxes
        ? defineCheckboxColumn(checkboxes)
        : null;
      const seriesNumberColumn = seriesItemNumbers
        ? defineSeriesNumberColumn(seriesItemNumbers)
        : null;
      const nameColumn =
        defineNameColumn<ReleaseT>(
          l('Release'),
          order,
          sortable,
          false, // no descriptive linking (since ACs are in the next column)
        );
      const artistCreditColumn = defineArtistCreditColumn(
        entity => entity.artistCredit,
        'artist',
        l('Artist'),
        order,
        sortable,
      );
      const formatColumn = defineTextColumn(
        entity => entity.combined_format_name || l('[missing media]'),
        'format',
        l('Format'),
        order,
        sortable,
      );
      const tracksColumn = defineTextColumn(
        entity => entity.combined_track_count || lp('-', 'missing data'),
        'tracks',
        l('Tracks'),
        order,
        sortable,
      );
      const releaseEventsColumn = defineReleaseEventsColumn(
        order,
        sortable,
      );
      const labelsColumn = filterLabel
        ? null
        : defineReleaseLabelsColumn(
          order,
          sortable,
        );
      const catnosColumn = defineReleaseCatnosColumn(
        entity => filterLabel
          ? filterReleaseLabels(entity.labels, filterLabel)
          : entity.labels,
        order,
        sortable,
      );
      const barcodeColumn = defineTextColumn(
        entity => formatBarcode(entity.barcode),
        'barcode',
        l('Barcode'),
        order,
        sortable,
        'barcode-cell',
      );
      const instrumentUsageColumn = showInstrumentCreditsAndRelTypes
        ? defineInstrumentUsageColumn(instrumentCreditsAndRelTypes)
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
        ...(showRatings ? [ratingsColumn] : []),
      ];
    },
    [
      $c.session,
      $c.user_exists,
      checkboxes,
      filterLabel,
      instrumentCreditsAndRelTypes,
      order,
      seriesItemNumbers,
      showInstrumentCreditsAndRelTypes,
      showRatings,
      sortable,
    ],
  );

  return <Table columns={columns} data={releases} />;
};

export default withCatalystContext(ReleaseList);
