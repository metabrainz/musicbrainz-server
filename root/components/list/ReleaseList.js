/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context';
import * as manifest from '../../static/manifest.mjs';
import Table from '../Table';
import filterReleaseLabels
  from '../../static/scripts/common/utility/filterReleaseLabels';
import formatBarcode from '../../static/scripts/common/utility/formatBarcode';
import {
  defineArtistCreditColumn,
  defineCheckboxColumn,
  defineInstrumentUsageColumn,
  defineNameColumn,
  defineRatingsColumn,
  defineReleaseCatnosColumn,
  defineReleaseEventsColumn,
  defineReleaseLabelsColumn,
  defineReleaseLanguageColumn,
  defineSeriesNumberColumn,
  defineTextColumn,
  taggerColumn,
} from '../../utility/tableColumns';

type Props = {
  ...InstrumentCreditsAndRelTypesRoleT,
  ...SeriesItemNumbersRoleT,
  +checkboxes?: string,
  +filterLabel?: LabelT,
  +order?: string,
  +releases: $ReadOnlyArray<ReleaseT>,
  +showInstrumentCreditsAndRelTypes?: boolean,
  +showLanguages?: boolean,
  +showRatings?: boolean,
  +showStatus?: boolean,
  +showType?: boolean,
  +sortable?: boolean,
};

const ReleaseList = ({
  checkboxes,
  filterLabel,
  instrumentCreditsAndRelTypes,
  order,
  releases,
  seriesItemNumbers,
  showInstrumentCreditsAndRelTypes = false,
  showLanguages = false,
  showRatings = false,
  showStatus = false,
  showType = false,
  sortable,
}: Props): React.MixedElement => {
  const $c = React.useContext(CatalystContext);

  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && nonEmpty(checkboxes)
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
          entity => nonEmpty(entity.combined_format_name)
            ? entity.combined_format_name
            : l('[missing media]'),
        order: order,
        sortable: sortable,
        title: l('Format'),
      });
      const tracksColumn = defineTextColumn<ReleaseT>({
        columnName: 'tracks',
        getText:
          entity => nonEmpty(entity.combined_track_count)
            ? entity.combined_track_count
            : lp('-', 'missing data'),
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
        getLabels: entity => filterLabel
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
      const releaseLanguageColumn = showLanguages
        ? defineReleaseLanguageColumn<ReleaseT>({
          getEntity: entity => entity,
        })
        : null;
      const instrumentUsageColumn = showInstrumentCreditsAndRelTypes
        ? defineInstrumentUsageColumn({
          instrumentCreditsAndRelTypes: instrumentCreditsAndRelTypes,
        })
        : null;
      const typeColumn = showType
        ? defineTextColumn<ReleaseT>({
          columnName: 'primary-type',
          getText: entity => entity.releaseGroup?.l_type_name || '',
          title: l('Type'),
        })
        : null;
      const statusColumn = showStatus
        ? defineTextColumn<ReleaseT>({
          columnName: 'status',
          getText: entity => entity.status
            ? lp_attributes(entity.status.name, 'release_status')
            : '',
          title: l('Status'),
        })
        : null;
      const ratingsColumn = defineRatingsColumn<ReleaseT>({
        getEntity: entity => entity.releaseGroup ?? null,
      });

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
        ...(showLanguages ? [releaseLanguageColumn] : []),
        ...(instrumentUsageColumn ? [instrumentUsageColumn] : []),
        ...(typeColumn ? [typeColumn] : []),
        ...(statusColumn ? [statusColumn] : []),
        ...($c.session?.tport == null ? [] : [taggerColumn]),
        ...(showRatings ? [ratingsColumn] : []),
      ];
    },
    [
      $c.session?.tport,
      $c.user,
      checkboxes,
      filterLabel,
      instrumentCreditsAndRelTypes,
      order,
      seriesItemNumbers,
      showInstrumentCreditsAndRelTypes,
      showLanguages,
      showRatings,
      showStatus,
      showType,
      sortable,
    ],
  );

  return (
    <>
      <Table columns={columns} data={releases} />
      {manifest.js('common/components/ReleaseEvents', {async: 'async'})}
      {manifest.js('common/components/TaggerIcon', {async: 'async'})}
    </>
  );
};

export default ReleaseList;
