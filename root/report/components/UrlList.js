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
import {defineLinkColumn} from '../../utility/tableColumns.js';

type Props<D: {+url: ?UrlT, ...}> = {
  +columnsAfter?: $ReadOnlyArray<ColumnOptionsNoValue<D>>,
  +columnsBefore?: $ReadOnlyArray<ColumnOptionsNoValue<D>>,
  +items: $ReadOnlyArray<D>,
  +pager: PagerT,
};

const UrlList = <D: {+url: ?UrlT, ...}>({
  columnsBefore,
  columnsAfter,
  items,
  pager,
}: Props<D>): React$Element<typeof PaginatedResults> => {
  const existingUrlItems = items.reduce((
    result: Array<D>,
    item,
  ) => {
    if (item.url != null) {
      result.push(item);
    }
    return result;
  }, []);

  const columns = React.useMemo(
    () => {
      const nameColumn = defineLinkColumn<D>({
        columnName: 'url',
        getContent: result => result.url?.name ?? '',
        getHref: result => result.url?.name ?? '',
        title: l('URL'),
      });
      const urlEntityColumn = defineLinkColumn<D>({
        columnName: 'url_entity',
        getContent: result => result.url?.gid ?? '',
        getHref: result => result.url?.gid ? '/url/' + result.url.gid : '',
        title: l('URL Entity'),
      });

      return [
        ...(columnsBefore ? [...columnsBefore] : []),
        nameColumn,
        urlEntityColumn,
        ...(columnsAfter ? [...columnsAfter] : []),
      ];
    },
    [columnsAfter, columnsBefore],
  );

  const table = useTable<D>({columns, data: existingUrlItems});

  return (
    <PaginatedResults pager={pager}>
      {table}
    </PaginatedResults>
  );
};

export default UrlList;
