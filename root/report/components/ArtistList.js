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
  defineTextColumn,
} from '../../utility/tableColumns.js';

type Props<D: {+artist: ?ArtistT, ...}> = {
  +columnsAfter?: $ReadOnlyArray<ColumnOptionsNoValue<D>>,
  +columnsBefore?: $ReadOnlyArray<ColumnOptionsNoValue<D>>,
  +items: $ReadOnlyArray<D>,
  +pager: PagerT,
  +subPath?: string,
};

const ArtistList = <D: {+artist: ?ArtistT, ...}>({
  columnsBefore,
  columnsAfter,
  items,
  pager,
  subPath,
}: Props<D>): React$Element<typeof PaginatedResults> => {
  const existingArtistItems = items.reduce((
    result: Array<D>,
    item,
  ) => {
    if (item.artist != null) {
      result.push(item);
    }
    return result;
  }, []);

  const columns = React.useMemo(
    () => {
      const nameColumn = defineEntityColumn<D>({
        columnName: 'artist',
        getEntity: result => result.artist ?? null,
        subPath: subPath,
        title: l('Artist'),
      });
      const typeColumn = defineTextColumn<D>({
        columnName: 'type',
        getText: result => {
          const typeName = result.artist?.typeName;
          return (nonEmpty(typeName)
            ? lp_attributes(typeName, 'artist_type')
            : lp('Unknown', 'type')
          );
        },
        title: l('Type'),
      });

      return [
        ...(columnsBefore ? [...columnsBefore] : []),
        nameColumn,
        typeColumn,
        ...(columnsAfter ? [...columnsAfter] : []),
      ];
    },
    [columnsAfter, columnsBefore, subPath],
  );

  const table = useTable<D>({
    columns,
    data: existingArtistItems,
  });

  return (
    <PaginatedResults pager={pager}>
      {table}
    </PaginatedResults>
  );
};

export default ArtistList;
