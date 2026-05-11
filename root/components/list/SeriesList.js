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
import {
  defineCheckboxColumn,
  defineCountColumn,
  defineNameColumn,
  defineSeriesNumberColumn,
  defineTypeColumn,
  removeFromMergeColumn,
  seriesOrderingTypeColumn,
} from '../../utility/tableColumns.js';

component SeriesList(
  checkboxes?: string,
  mergeForm?: MergeFormT,
  order?: string,
  series: $ReadOnlyArray<SeriesT>,
  seriesItemNumbers?: $ReadOnlyArray<string>,
  sortable?: boolean,
) {
  const $c = React.useContext(CatalystContext);

  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (nonEmpty(checkboxes) || mergeForm)
        ? defineCheckboxColumn({mergeForm, name: checkboxes})
        : null;
      const nameColumn = defineNameColumn<SeriesT>({
        order,
        sortable,
        title: lp('Series', 'singular'),
      });
      const seriesNumberColumn = seriesItemNumbers
        ? defineSeriesNumberColumn({seriesItemNumbers})
        : null;
      const typeColumn = defineTypeColumn({
        order,
        sortable,
        typeContext: 'series_type',
      });
      const sizeColumn = defineCountColumn<SeriesT>({
        columnName: 'size',
        getCount: series => series.entity_count,
        title: l('Number of entities'),
      });

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        ...(seriesNumberColumn ? [seriesNumberColumn] : []),
        nameColumn,
        typeColumn,
        seriesOrderingTypeColumn,
        sizeColumn,
        ...(mergeForm && series.length > 2 ? [removeFromMergeColumn] : []),
      ];
    },
    [
      $c.user,
      checkboxes,
      mergeForm,
      order,
      series,
      seriesItemNumbers,
      sortable,
    ],
  );

  return useTable<SeriesT>({columns, data: series});
}

export default SeriesList;
