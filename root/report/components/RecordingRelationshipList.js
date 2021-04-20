/*
 * @flow strict-local
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../../components/PaginatedResults';
import Table from '../../components/Table';
import {
  defineArtistCreditColumn,
  defineEntityColumn,
  defineTextColumn,
  relTypeColumn,
} from '../../utility/tableColumns';
import type {ReportRecordingRelationshipT} from '../types';

type Props = {
  +items: $ReadOnlyArray<ReportRecordingRelationshipT>,
  +pager: PagerT,
  +showDates?: boolean,
};

const RecordingRelationshipList = ({
  items,
  pager,
  showDates = false,
}: Props): React.Element<typeof PaginatedResults> => {
  const existingRecordingItems = items.reduce((result, item) => {
    if (item.recording != null) {
      result.push(item);
    }
    return result;
  }, []);

  const columns = React.useMemo(
    () => {
      const beginDateColumn = showDates
        ? (
          defineTextColumn<ReportRecordingRelationshipT>({
            columnName: 'begin_date',
            getText: result => result.begin?.toString() ?? '',
            title: l('Begin date'),
          })
        ) : null;
      const endDateColumn = showDates
        ? (
          defineTextColumn<ReportRecordingRelationshipT>({
            columnName: 'end_date',
            getText: result => result.end?.toString() ?? '',
            title: l('End date'),
          })
        ) : null;
      const recordingColumn =
        defineEntityColumn<ReportRecordingRelationshipT>({
          columnName: 'recording',
          descriptive: false,
          getEntity: result => result.recording ?? null,
          title: l('Recording'),
        });
      const artistCreditColumn =
        defineArtistCreditColumn<ReportRecordingRelationshipT>({
          columnName: 'artist',
          getArtistCredit: result => result.recording?.artistCredit ?? null,
          title: l('Artist'),
        });

      return [
        ...(beginDateColumn ? [beginDateColumn] : []),
        ...(endDateColumn ? [endDateColumn] : []),
        relTypeColumn,
        recordingColumn,
        artistCreditColumn,
      ];
    },
    [showDates],
  );

  return (
    <PaginatedResults pager={pager}>
      <Table columns={columns} data={existingRecordingItems} />
    </PaginatedResults>
  );
};

export default RecordingRelationshipList;
