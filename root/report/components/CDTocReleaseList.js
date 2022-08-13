/*
 * @flow strict-local
 * Copyright (C) 2021 Jerome Roy
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../../components/PaginatedResults.js';
import Table from '../../components/Table.js';
import {
  defineArtistCreditColumn,
  defineCDTocColumn,
  defineEntityColumn,
} from '../../utility/tableColumns.js';
import type {ReportCDTocReleaseT} from '../types.js';

type Props = {
  +items: $ReadOnlyArray<ReportCDTocReleaseT>,
  +pager: PagerT,
};

const CDTocReleaseList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => {
  const existingCDTocItems = items.reduce((result, item) => {
    if (item.cdtoc != null) {
      result.push(item);
    }
    return result;
  }, []);

  const columns = React.useMemo(
    () => {
      const cdTocColumn = defineCDTocColumn<ReportCDTocReleaseT>({
        getCDToc: result => result.cdtoc ?? null,
      });
      const releaseColumn = defineEntityColumn<ReportCDTocReleaseT>({
        columnName: 'release',
        descriptive: false,
        getEntity: result => result.release ?? null,
        title: l('Release'),
      });
      const artistCreditColumn =
        defineArtistCreditColumn<ReportCDTocReleaseT>({
          columnName: 'artist',
          getArtistCredit: result => result.release?.artistCredit ?? null,
          title: l('Artist'),
        });

      return [
        cdTocColumn,
        releaseColumn,
        artistCreditColumn,
      ];
    },
    [],
  );

  return (
    <PaginatedResults pager={pager}>
      <Table columns={columns} data={existingCDTocItems} />
    </PaginatedResults>
  );
};

export default CDTocReleaseList;
