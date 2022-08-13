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
} from '../../utility/tableColumns.js';
import type {ReportRecordingT} from '../types.js';

type Props<D: {+recording: ?RecordingT, ...}> = {
  +columnsAfter?: $ReadOnlyArray<ColumnOptionsNoValue<D>>,
  +columnsBefore?: $ReadOnlyArray<ColumnOptionsNoValue<D>>,
  +items: $ReadOnlyArray<D>,
  +pager: PagerT,
};

const RecordingList = <D: {+recording: ?RecordingT, ...}>({
  columnsBefore,
  columnsAfter,
  items,
  pager,
}: Props<D>): React.Element<typeof PaginatedResults> => {
  const existingRecordingItems = items.reduce((result, item) => {
    if (item.recording != null) {
      result.push(item);
    }
    return result;
  }, []);

  const columns = React.useMemo(
    () => {
      const recordingColumn = defineEntityColumn<ReportRecordingT>({
        columnName: 'recording',
        descriptive: false,
        getEntity: result => result.recording ?? null,
        title: l('Recording'),
      });
      const artistCreditColumn =
        defineArtistCreditColumn<ReportRecordingT>({
          columnName: 'artist',
          getArtistCredit: result => result.recording?.artistCredit ?? null,
          title: l('Artist'),
        });

      return [
        ...(columnsBefore ? [...columnsBefore] : []),
        recordingColumn,
        artistCreditColumn,
        ...(columnsAfter ? [...columnsAfter] : []),
      ];
    },
    [columnsAfter, columnsBefore],
  );

  return (
    <PaginatedResults pager={pager}>
      <Table columns={columns} data={existingRecordingItems} />
    </PaginatedResults>
  );
};

export default RecordingList;
