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
import {
  defineCheckboxColumn,
  defineNameColumn,
  defineRemoveFromMergeColumn,
  defineTypeColumn,
  seriesOrderingTypeColumn,
} from '../../utility/tableColumns';

type Props = {
  +$c: CatalystContextT,
  +checkboxes?: string,
  +mergeForm?: MergeFormT,
  +order?: string,
  +series: $ReadOnlyArray<SeriesT>,
  +sortable?: boolean,
};

const SeriesList = ({
  $c,
  checkboxes,
  mergeForm,
  order,
  series,
  sortable,
}: Props) => {
  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user_exists && (checkboxes || mergeForm)
        ? defineCheckboxColumn(checkboxes, mergeForm)
        : null;
      const nameColumn = defineNameColumn<SeriesT>(
        lp('Series', 'singular'),
        order,
        sortable,
      );
      const typeColumn = defineTypeColumn('series_type', order, sortable);
      const removeFromMergeColumn = mergeForm
        ? defineRemoveFromMergeColumn(series)
        : null;

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        nameColumn,
        typeColumn,
        seriesOrderingTypeColumn,
        ...(removeFromMergeColumn ? [removeFromMergeColumn] : []),
      ];
    },
    [$c.user_exists, checkboxes, mergeForm, order, series, sortable],
  );

  return <Table columns={columns} data={series} />;
};

export default withCatalystContext(SeriesList);
