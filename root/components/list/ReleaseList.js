/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context.mjs';
import useTable from '../../hooks/useTable.js';
import manifest from '../../static/manifest.mjs';
import filterReleaseLabels
  from '../../static/scripts/common/utility/filterReleaseLabels.js';
import formatBarcode
  from '../../static/scripts/common/utility/formatBarcode.js';
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
  removeFromMergeColumn,
  taggerColumn,
} from '../../utility/tableColumns.js';

component ReleaseList(
  checkboxes?: string,
  filterLabel?: LabelT,
  instrumentCreditsAndRelTypes?: InstrumentCreditsAndRelTypesT,
  mergeForm?: MergeReleasesFormT,
  order?: string,
  releases: $ReadOnlyArray<ReleaseT>,
  seriesItemNumbers?: $ReadOnlyArray<string>,
  showInstrumentCreditsAndRelTypes: boolean = false,
  showLanguages: boolean = false,
  showRatings: boolean = false,
  showStatus: boolean = false,
  showType: boolean = false,
  sortable?: boolean,
) {
  const $c = React.useContext(CatalystContext);

  const className = checkboxes === 'add-to-merge' ? 'mergeable-table' : '';

  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (nonEmpty(checkboxes) || mergeForm)
        ? defineCheckboxColumn({mergeForm, name: checkboxes})
        : null;
      const seriesNumberColumn = seriesItemNumbers
        ? defineSeriesNumberColumn({seriesItemNumbers})
        : null;
      const nameColumn = defineNameColumn<ReleaseT>({
        descriptive: false, // since ACs are in the next column
        order,
        showArtworkPresence: releases
          .some((release) => release.cover_art_presence === 'present'),
        sortable,
        title: l('Release'),
      });
      const artistCreditColumn = defineArtistCreditColumn<ReleaseT>({
        columnName: 'artist',
        getArtistCredit: entity => entity.artistCredit,
        order,
        sortable,
        title: l('Artist'),
      });
      const formatColumn = defineTextColumn<ReleaseT>({
        columnName: 'format',
        getText:
          entity => nonEmpty(entity.combined_format_name)
            ? entity.combined_format_name
            : l('[missing media]'),
        order,
        sortable,
        title: l('Format'),
      });
      const tracksColumn = defineTextColumn<ReleaseT>({
        columnName: 'tracks',
        getText:
          entity => nonEmpty(entity.combined_track_count)
            ? entity.combined_track_count
            : lp('-', 'missing data'),
        order,
        sortable,
        title: l('Tracks'),
      });
      const releaseEventsColumn = defineReleaseEventsColumn({
        order,
        sortable,
      });
      const labelsColumn = filterLabel
        ? null
        : defineReleaseLabelsColumn({
          order,
          sortable,
        });
      const catnosColumn = defineReleaseCatnosColumn({
        getLabels: (release: ReleaseT) => {
          const labels = release.labels;
          if (labels == null) {
            return [];
          }
          return filterLabel
            ? filterReleaseLabels(labels, filterLabel)
            : labels;
        },
        order,
        sortable,
      });
      const barcodeColumn = defineTextColumn<ReleaseT>({
        cellProps: {className: 'barcode-cell'},
        columnName: 'barcode',
        getText: entity => formatBarcode(entity.barcode),
        order,
        sortable,
        title: l('Barcode'),
      });
      const releaseLanguageColumn = showLanguages
        ? defineReleaseLanguageColumn<ReleaseT>({
          getEntity: entity => entity,
        })
        : null;
      const instrumentUsageColumn = showInstrumentCreditsAndRelTypes
        ? defineInstrumentUsageColumn({
          instrumentCreditsAndRelTypes,
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
          title: lp('Status', 'release'),
        })
        : null;
      const ratingsColumn = defineRatingsColumn<ReleaseT>({
        getEntity: entity => entity.releaseGroup ?? null,
      });

      return [
        checkboxColumn,
        seriesNumberColumn,
        nameColumn,
        artistCreditColumn,
        formatColumn,
        tracksColumn,
        releaseEventsColumn,
        labelsColumn,
        catnosColumn,
        barcodeColumn,
        releaseLanguageColumn,
        instrumentUsageColumn,
        typeColumn,
        statusColumn,
        ($c.session?.tport == null) ? null : taggerColumn,
        showRatings ? ratingsColumn : null,
        (mergeForm && releases.length > 2) ? removeFromMergeColumn : null,
      ].filter(Boolean);
    },
    [
      $c.session?.tport,
      $c.user,
      checkboxes,
      filterLabel,
      instrumentCreditsAndRelTypes,
      mergeForm,
      order,
      releases,
      seriesItemNumbers,
      showInstrumentCreditsAndRelTypes,
      showLanguages,
      showRatings,
      showStatus,
      showType,
      sortable,
    ],
  );

  const table = useTable<ReleaseT>({className, columns, data: releases});

  return (
    <>
      {table}
      {manifest('common/components/ReleaseEvents', {async: true})}
      {manifest('common/components/TaggerIcon', {async: true})}
    </>
  );
}

export default ReleaseList;
