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
} from '../../utility/tableColumns';
import type {ReportReleaseGroupT} from '../types';

type Props = {
  +items: $ReadOnlyArray<ReportReleaseGroupT>,
  +pager: PagerT,
};

const ReleaseGroupList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => {
  const existingReleaseGroupItems = items.reduce((result, item) => {
    if (item.release_group != null) {
      result.push(item);
    }
    return result;
  }, []);

  const columns = React.useMemo(
    () => {
      const releaseGroupColumn = defineEntityColumn<ReportReleaseGroupT>({
        columnName: 'release_group',
        descriptive: false,
        getEntity: result => result.release_group ?? null,
        title: l('Release Group'),
      });
      const artistCreditColumn =
        defineArtistCreditColumn<ReportReleaseGroupT>({
          columnName: 'artist',
          getArtistCredit:
            result => result.release_group?.artistCredit ?? null,
          title: l('Artist'),
        });
      const typeColumn = defineTextColumn<ReportReleaseGroupT>({
        columnName: 'type',
        getText: result => {
          const typeName = result.release_group?.l_type_name;
          return nonEmpty(typeName) ? typeName : l('Unknown');
        },
        title: l('Type'),
      });

      return [
        releaseGroupColumn,
        artistCreditColumn,
        typeColumn,
      ];
    },
    [],
  );

  return (
    <PaginatedResults pager={pager}>
      <Table columns={columns} data={existingReleaseGroupItems} />
    </PaginatedResults>
  );
};

export default ReleaseGroupList;
