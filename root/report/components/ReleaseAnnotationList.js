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
import useAnnotationColumns from '../hooks/useAnnotationColumns';
import type {ReportReleaseAnnotationT} from '../types';

type Props = {
  +items: $ReadOnlyArray<ReportReleaseAnnotationT>,
  +pager: PagerT,
};

const ReleaseAnnotationList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => {
  const existingReleaseItems = items.reduce((result, item) => {
    if (item.release != null) {
      result.push(item);
    }
    return result;
  }, []);
  const annotationColumns = useAnnotationColumns();

  const columns = React.useMemo(
    () => {
      const releaseColumn = defineEntityColumn<ReportReleaseAnnotationT>({
        columnName: 'release',
        descriptive: false,
        getEntity: result => result.release ?? null,
        title: l('Release'),
      });
      const artistCreditColumn =
        defineArtistCreditColumn<ReportReleaseAnnotationT>({
          columnName: 'artist',
          getArtistCredit: result => result.release?.artistCredit ?? null,
          title: l('Artist'),
        });

      return [
        releaseColumn,
        artistCreditColumn,
        ...annotationColumns,
      ];
    },
    [annotationColumns],
  );

  return (
    <PaginatedResults pager={pager}>
      <Table columns={columns} data={existingReleaseItems} />
    </PaginatedResults>
  );
};

export default ReleaseAnnotationList;
