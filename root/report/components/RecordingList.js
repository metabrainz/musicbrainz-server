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
} from '../../utility/tableColumns';
import type {ReportRecordingT} from '../types';

type Props = {
  +items: $ReadOnlyArray<ReportRecordingT>,
  +pager: PagerT,
};

const RecordingList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => {
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
        recordingColumn,
        artistCreditColumn,
      ];
    },
    [],
  );

  return (
    <PaginatedResults pager={pager}>
      <Table columns={columns} data={existingRecordingItems} />
    </PaginatedResults>
  );
};

export default RecordingList;
