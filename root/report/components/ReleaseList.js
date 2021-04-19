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
  defineReleaseLanguageColumn,
} from '../../utility/tableColumns';
import type {ReportReleaseT} from '../types';

type Props = {
  +items: $ReadOnlyArray<ReportReleaseT>,
  +pager: PagerT,
  +showLanguageAndScript?: boolean,
  +subPath?: string,
};

const ReleaseList = ({
  items,
  pager,
  showLanguageAndScript = false,
  subPath,
}: Props): React.Element<typeof PaginatedResults> => {
  const existingReleaseItems = items.reduce((result, item) => {
    if (item.release != null) {
      result.push(item);
    }
    return result;
  }, []);

  const columns = React.useMemo(
    () => {
      const releaseColumn = defineEntityColumn<ReportReleaseT>({
        columnName: 'release',
        descriptive: false,
        getEntity: result => result.release ?? null,
        subPath: subPath,
        title: l('Release'),
      });
      const artistCreditColumn =
        defineArtistCreditColumn<ReportReleaseT>({
          columnName: 'artist',
          getArtistCredit: result => result.release?.artistCredit ?? null,
          title: l('Artist'),
        });
      const releaseLanguageColumn = showLanguageAndScript
        ? defineReleaseLanguageColumn<ReportReleaseT>({
          getEntity: result => result.release ?? null,
        })
        : null;

      return [
        releaseColumn,
        artistCreditColumn,
        ...(showLanguageAndScript ? [releaseLanguageColumn] : []),
      ];
    },
    [showLanguageAndScript, subPath],
  );

  return (
    <PaginatedResults pager={pager}>
      <Table columns={columns} data={existingReleaseItems} />
    </PaginatedResults>
  );
};

export default ReleaseList;
