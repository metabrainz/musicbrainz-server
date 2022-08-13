/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context.mjs';
import {
  defineCheckboxColumn,
  defineNameColumn,
  defineTypeColumn,
  removeFromMergeColumn,
  seriesOrderingTypeColumn,
} from '../../utility/tableColumns.js';
import Table from '../Table.js';

type Props = {
  +checkboxes?: string,
  +mergeForm?: MergeFormT,
  +order?: string,
  +series: $ReadOnlyArray<SeriesT>,
  +sortable?: boolean,
};

const SeriesList = ({
  checkboxes,
  mergeForm,
  order,
  series,
  sortable,
}: Props): React.Element<typeof Table> => {
  const $c = React.useContext(CatalystContext);

  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (nonEmpty(checkboxes) || mergeForm)
        ? defineCheckboxColumn({mergeForm: mergeForm, name: checkboxes})
        : null;
      const nameColumn = defineNameColumn<SeriesT>({
        order: order,
        sortable: sortable,
        title: lp('Series', 'singular'),
      });
      const typeColumn = defineTypeColumn({
        order: order,
        sortable: sortable,
        typeContext: 'series_type',
      });

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        nameColumn,
        typeColumn,
        seriesOrderingTypeColumn,
        ...(mergeForm && series.length > 2 ? [removeFromMergeColumn] : []),
      ];
    },
    [$c.user, checkboxes, mergeForm, order, series, sortable],
  );

  return <Table columns={columns} data={series} />;
};

export default SeriesList;
