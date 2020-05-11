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
      const checkboxColumn = $c.user && (checkboxes || mergeForm)
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
      const removeFromMergeColumn = mergeForm
        ? defineRemoveFromMergeColumn({toMerge: series})
        : null;

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        nameColumn,
        typeColumn,
        seriesOrderingTypeColumn,
        ...(removeFromMergeColumn ? [removeFromMergeColumn] : []),
      ];
    },
    [$c.user, checkboxes, mergeForm, order, series, sortable],
  );

  return <Table columns={columns} data={series} />;
};

export default withCatalystContext(SeriesList);
