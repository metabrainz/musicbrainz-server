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
import * as manifest from '../../static/manifest.mjs';
import {
  defineArtistRolesColumn,
  defineEntityColumn,
  defineTextColumn,
} from '../../utility/tableColumns';

type Props<D: {+work: ?WorkT, ...}> = {
  +columnsAfter?: $ReadOnlyArray<ColumnOptionsNoValue<D>>,
  +columnsBefore?: $ReadOnlyArray<ColumnOptionsNoValue<D>>,
  +items: $ReadOnlyArray<D>,
  +pager: PagerT,
};

const WorkList = <D: {+work: ?WorkT, ...}>({
  columnsBefore,
  columnsAfter,
  items,
  pager,
}: Props<D>): React.Element<typeof PaginatedResults> => {
  const existingWorkItems = items.reduce((result, item) => {
    if (item.work != null) {
      result.push(item);
    }
    return result;
  }, []);

  const columns = React.useMemo(
    () => {
      const nameColumn = defineEntityColumn<D>({
        columnName: 'work',
        getEntity: result => result.work ?? null,
        title: l('Work'),
      });
      const writersColumn = defineArtistRolesColumn<D>({
        columnName: 'writers',
        getRoles: result => result.work?.writers ?? [],
        title: l('Writers'),
      });
      const typeColumn = defineTextColumn<D>({
        columnName: 'type',
        getText: result => {
          const typeName = result.work?.typeName;
          return (nonEmpty(typeName)
            ? lp_attributes(typeName, 'work_type')
            : l('Unknown')
          );
        },
        title: l('Type'),
      });

      return [
        ...(columnsBefore ? [...columnsBefore] : []),
        nameColumn,
        writersColumn,
        typeColumn,
        ...(columnsAfter ? [...columnsAfter] : []),
      ];
    },
    [columnsAfter, columnsBefore],
  );

  return (
    <PaginatedResults pager={pager}>
      <Table columns={columns} data={existingWorkItems} />
      {manifest.js('common/components/ArtistRoles', {async: 'async'})}
    </PaginatedResults>
  );
};

export default WorkList;
