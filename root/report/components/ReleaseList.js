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
import Table from '../../components/Table.js';
import {
  defineArtistCreditColumn,
  defineEntityColumn,
} from '../../utility/tableColumns.js';

type Props<D: {+release: ?ReleaseT, ...}> = {
  +columnsAfter?: $ReadOnlyArray<ColumnOptionsNoValue<D>>,
  +columnsBefore?: $ReadOnlyArray<ColumnOptionsNoValue<D>>,
  +items: $ReadOnlyArray<D>,
  +pager: PagerT,
  +subPath?: string,
};

const ReleaseList = <D: {+release: ?ReleaseT, ...}>({
  columnsBefore,
  columnsAfter,
  items,
  pager,
  subPath,
}: Props<D>): React.Element<typeof PaginatedResults> => {
  const existingReleaseItems = items.reduce((result, item) => {
    if (item.release != null) {
      result.push(item);
    }
    return result;
  }, []);

  const columns = React.useMemo(
    () => {
      const releaseColumn = defineEntityColumn<D>({
        columnName: 'release',
        descriptive: false,
        getEntity: result => result.release ?? null,
        subPath: subPath,
        title: l('Release'),
      });
      const artistCreditColumn =
        defineArtistCreditColumn<D>({
          columnName: 'artist',
          getArtistCredit: result => result.release?.artistCredit ?? null,
          title: l('Artist'),
        });

      return [
        ...(columnsBefore ? [...columnsBefore] : []),
        releaseColumn,
        artistCreditColumn,
        ...(columnsAfter ? [...columnsAfter] : []),
      ];
    },
    [columnsAfter, columnsBefore, subPath],
  );

  return (
    <PaginatedResults pager={pager}>
      <Table columns={columns} data={existingReleaseItems} />
    </PaginatedResults>
  );
};

export default ReleaseList;
