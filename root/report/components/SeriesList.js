/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import type {ColumnOptionsNoValue} from 'react-table';

import PaginatedResults from '../../components/PaginatedResults.js';
import useTable from '../../hooks/useTable.js';
import {
  defineEntityColumn,
} from '../../utility/tableColumns.js';

type Props<D: {+series: ?SeriesT, ...}> = {
  +columnsAfter?: $ReadOnlyArray<ColumnOptionsNoValue<D>>,
  +columnsBefore?: $ReadOnlyArray<ColumnOptionsNoValue<D>>,
  +items: $ReadOnlyArray<D>,
  +pager: PagerT,
};

const SeriesList = <D: {+series: ?SeriesT, ...}>({
  columnsBefore,
  columnsAfter,
  items,
  pager,
}: Props<D>): React$Element<typeof PaginatedResults> => {
  const existingSeriesItems = items.reduce((
    result: Array<D>,
    item,
  ) => {
    if (item.series != null) {
      result.push(item);
    }
    return result;
  }, []);

  const columns = React.useMemo(
    () => {
      const nameColumn = defineEntityColumn<D>({
        columnName: 'series',
        getEntity: result => result.series ?? null,
        title: l('Series'),
      });

      return [
        ...(columnsBefore ? [...columnsBefore] : []),
        nameColumn,
        ...(columnsAfter ? [...columnsAfter] : []),
      ];
    },
    [columnsAfter, columnsBefore],
  );

  const table = useTable<D>({columns, data: existingSeriesItems});

  return (
    <PaginatedResults pager={pager}>
      {table}
    </PaginatedResults>
  );
};

export default SeriesList;
