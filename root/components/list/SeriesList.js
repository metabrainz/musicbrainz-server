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
  defineTypeColumn,
  seriesOrderingTypeColumn,
} from '../../utility/tableColumns';

type Props = {
  +$c: CatalystContextT,
  +checkboxes?: string,
  +order?: string,
  +series: $ReadOnlyArray<SeriesT>,
  +sortable?: boolean,
};

const SeriesList = ({
  $c,
  checkboxes,
  order,
  series,
  sortable,
}: Props) => {
  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user_exists && checkboxes
        ? defineCheckboxColumn(checkboxes)
        : null;
      const nameColumn = defineNameColumn<SeriesT>(
        lp('Series', 'singular'),
        order,
        sortable,
      );
      const typeColumn = defineTypeColumn('series_type', order, sortable);

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        nameColumn,
        typeColumn,
        seriesOrderingTypeColumn,
      ];
    },
    [$c.user_exists, checkboxes, order, sortable],
  );

  return <Table columns={columns} data={series} />;
};

export default withCatalystContext(SeriesList);
