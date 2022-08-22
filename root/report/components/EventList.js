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
import * as manifest from '../../static/manifest.mjs';
import {
  defineArtistRolesColumn,
  defineDatePeriodColumn,
  defineEntityColumn,
  defineLocationColumn,
  defineTextColumn,
} from '../../utility/tableColumns.js';
import type {ReportEventT} from '../types.js';

type Props<D: {+event: ?EventT, ...}> = {
  +columnsAfter?: $ReadOnlyArray<ColumnOptionsNoValue<D>>,
  +columnsBefore?: $ReadOnlyArray<ColumnOptionsNoValue<D>>,
  +items: $ReadOnlyArray<D>,
  +pager: PagerT,
};

const EventList = <D: {+event: ?EventT, ...}>({
  columnsBefore,
  columnsAfter,
  items,
  pager,
}: Props<D>): React.Element<typeof PaginatedResults> => {
  const existingEventItems = items.reduce((result, item) => {
    if (item.event != null) {
      result.push(item);
    }
    return result;
  }, []);

  const columns = React.useMemo(
    () => {
      const nameColumn = defineEntityColumn<ReportEventT>({
        columnName: 'event',
        descriptive: false, // since dates have their own column
        getEntity: result => result.event ?? null,
        title: l('Event'),
      });
      const typeColumn = defineTextColumn<ReportEventT>({
        columnName: 'type',
        getText: result => {
          const typeName = result.event?.typeName;
          return (nonEmpty(typeName)
            ? lp_attributes(typeName, 'event_type')
            : ''
          );
        },
        title: l('Type'),
      });
      const artistsColumn = defineArtistRolesColumn<ReportEventT>({
        columnName: 'performers',
        getRoles: result => result.event?.performers ?? [],
        title: l('Artists'),
      });
      const locationColumn = defineLocationColumn<ReportEventT>({
        getEntity: result => result.event ?? null,
      });
      const timeColumn = defineTextColumn<ReportEventT>({
        columnName: 'time',
        getText: result => result.event?.time ?? '',
        title: l('Time'),
      });
      const dateColumn = defineDatePeriodColumn<ReportEventT>({
        getEntity: result => result.event ?? null,
      });

      return [
        ...(columnsBefore ? [...columnsBefore] : []),
        nameColumn,
        typeColumn,
        artistsColumn,
        locationColumn,
        dateColumn,
        timeColumn,
        ...(columnsAfter ? [...columnsAfter] : []),
      ];
    },
    [columnsAfter, columnsBefore],
  );

  return (
    <PaginatedResults pager={pager}>
      <Table columns={columns} data={existingEventItems} />
      {manifest.js('common/components/ArtistRoles', {async: 'async'})}
    </PaginatedResults>
  );
};

export default EventList;
