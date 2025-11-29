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
  defineArtistCreditColumn,
  defineEntityColumn,
  defineTextColumn,
} from '../../utility/tableColumns.js';

component ReleaseGroupList<D: {+release_group: ?ReleaseGroupT, ...}>(
  columnsAfter?: $ReadOnlyArray<ColumnOptionsNoValue<D>>,
  columnsBefore?: $ReadOnlyArray<ColumnOptionsNoValue<D>>,
  items: $ReadOnlyArray<D>,
  pager: PagerT,
) {
  const existingReleaseGroupItems = items.reduce((
    result: Array<D>,
    item,
  ) => {
    if (item.release_group != null) {
      result.push(item);
    }
    return result;
  }, []);

  const columns = React.useMemo(
    () => {
      const releaseColumn = defineEntityColumn<D>({
        columnName: 'release_group',
        descriptive: false,
        getEntity: result => result.release_group ?? null,
        title: l_mb_server('Release group'),
      });
      const artistCreditColumn =
        defineArtistCreditColumn<D>({
          columnName: 'artist',
          getArtistCredit:
            result => result.release_group?.artistCredit ?? null,
          title: l_mb_server('Artist'),
        });
      const typeColumn = defineTextColumn<D>({
        columnName: 'type',
        getText: result => {
          const typeName = result.release_group?.l_type_name;
          return nonEmpty(typeName)
            ? typeName
            : lp_mb_server('Unknown', 'type');
        },
        title: l_mb_server('Type'),
      });

      return [
        ...(columnsBefore ? [...columnsBefore] : []),
        releaseColumn,
        artistCreditColumn,
        typeColumn,
        ...(columnsAfter ? [...columnsAfter] : []),
      ];
    },
    [columnsAfter, columnsBefore],
  );

  const table = useTable<D>({columns, data: existingReleaseGroupItems});

  return (
    <PaginatedResults pager={pager}>
      {table}
    </PaginatedResults>
  );
}

export default ReleaseGroupList;
