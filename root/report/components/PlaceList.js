/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import type {ColumnOptionsNoValue} from 'react-table';

import PaginatedResults from '../../components/PaginatedResults';
import Table from '../../components/Table';
import {
  defineEntityColumn,
} from '../../utility/tableColumns';
import type {ReportPlaceRelationshipT} from '../types';

type Props<D: {+place: ?PlaceT, ...}> = {
  +columnsAfter?: $ReadOnlyArray<ColumnOptionsNoValue<D>>,
  +columnsBefore?: $ReadOnlyArray<ColumnOptionsNoValue<D>>,
  +items: $ReadOnlyArray<D>,
  +pager: PagerT,
};

const PlaceList = <D: {+place: ?PlaceT, ...}>({
  columnsBefore,
  columnsAfter,
  items,
  pager,
}: Props<D>): React.Element<typeof PaginatedResults> => {
  const existingPlaceItems = items.reduce((result, item) => {
    if (item.place != null) {
      result.push(item);
    }
    return result;
  }, []);

  const columns = React.useMemo(
    () => {
      const nameColumn = defineEntityColumn<ReportPlaceRelationshipT>({
        columnName: 'place',
        getEntity: result => result.place ?? null,
        title: l('Place'),
      });

      return [
        ...(columnsBefore ? [...columnsBefore] : []),
        nameColumn,
        ...(columnsAfter ? [...columnsAfter] : []),
      ];
    },
    [columnsAfter, columnsBefore],
  );

  return (
    <PaginatedResults pager={pager}>
      <Table columns={columns} data={existingPlaceItems} />
    </PaginatedResults>
  );
};

export default PlaceList;
