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
  defineEntityColumn,
  defineTextColumn,
} from '../../utility/tableColumns';
import type {ReportArtistT} from '../types';

type Props = {
  +items: $ReadOnlyArray<ReportArtistT>,
  +pager: PagerT,
};

const ArtistReportList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => {
  const existingArtistItems = items.reduce((result, item) => {
    if (item.artist != null) {
      result.push(item);
    }
    return result;
  }, []);

  const columns = React.useMemo(
    () => {
      const nameColumn = defineEntityColumn<ReportArtistT>({
        columnName: 'artist',
        getEntity: result => result.artist ?? null,
        title: l('Artist'),
      });
      const typeColumn = defineTextColumn<ReportArtistT>({
        columnName: 'type',
        getText: result => {
          const typeName = result.artist?.typeName;
          return (nonEmpty(typeName)
            ? lp_attributes(typeName, 'artist_type')
            : l('Unknown')
          );
        },
        title: l('Type'),
      });

      return [
        nameColumn,
        typeColumn,
      ];
    },
    [],
  );

  return (
    <PaginatedResults pager={pager}>
      <Table columns={columns} data={existingArtistItems} />
    </PaginatedResults>
  );
};

export default ArtistReportList;
