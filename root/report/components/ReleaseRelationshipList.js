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
  relTypeColumn,
} from '../../utility/tableColumns';
import type {ReportReleaseRelationshipT} from '../types';

type Props = {
  +items: $ReadOnlyArray<ReportReleaseRelationshipT>,
  +pager: PagerT,
};

const ReleaseRelationshipList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => {
  const existingReleaseItems = items.reduce((result, item) => {
    if (item.release != null) {
      result.push(item);
    }
    return result;
  }, []);

  const columns = React.useMemo(
    () => {
      const releaseColumn = defineEntityColumn<ReportReleaseRelationshipT>({
        columnName: 'release',
        descriptive: false,
        getEntity: result => result.release ?? null,
        title: l('Release'),
      });
      const artistCreditColumn =
        defineArtistCreditColumn<ReportReleaseRelationshipT>({
          columnName: 'artist',
          getArtistCredit: result => result.release?.artistCredit ?? null,
          title: l('Artist'),
        });

      return [
        relTypeColumn,
        releaseColumn,
        artistCreditColumn,
      ];
    },
    [],
  );

  return (
    <PaginatedResults pager={pager}>
      <Table columns={columns} data={existingReleaseItems} />
    </PaginatedResults>
  );
};

export default ReleaseRelationshipList;
