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

import PaginatedResults from '../../components/PaginatedResults.js';
import Table from '../../components/Table.js';
import {
  defineArtistCreditColumn,
  defineEntityColumn,
  defineTextColumn,
} from '../../utility/tableColumns.js';

type Props<D: {+release_group: ?ReleaseGroupT, ...}> = {
  +columnsAfter?: $ReadOnlyArray<ColumnOptionsNoValue<D>>,
  +columnsBefore?: $ReadOnlyArray<ColumnOptionsNoValue<D>>,
  +items: $ReadOnlyArray<D>,
  +pager: PagerT,
};

const ReleaseGroupList = <D: {+release_group: ?ReleaseGroupT, ...}>({
  columnsBefore,
  columnsAfter,
  items,
  pager,
}: Props<D>): React.Element<typeof PaginatedResults> => {
  const existingReleaseGroupItems = items.reduce((result, item) => {
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
        title: l('Release Group'),
      });
      const artistCreditColumn =
        defineArtistCreditColumn<D>({
          columnName: 'artist',
          getArtistCredit:
            result => result.release_group?.artistCredit ?? null,
          title: l('Artist'),
        });
      const typeColumn = defineTextColumn<D>({
        columnName: 'type',
        getText: result => {
          const typeName = result.release_group?.l_type_name;
          return nonEmpty(typeName) ? typeName : l('Unknown');
        },
        title: l('Type'),
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

  return (
    <PaginatedResults pager={pager}>
      <Table columns={columns} data={existingReleaseGroupItems} />
    </PaginatedResults>
  );
};

export default ReleaseGroupList;
