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
  defineLinkColumn,
  relTypeColumn,
} from '../../utility/tableColumns';
import type {ReportUrlRelationshipT} from '../types';

type Props = {
  +items: $ReadOnlyArray<ReportUrlRelationshipT>,
  +pager: PagerT,
};

const UrlRelationshipList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => {
  const existingUrlItems = items.reduce((result, item) => {
    if (item.url != null) {
      result.push(item);
    }
    return result;
  }, []);

  const columns = React.useMemo(
    () => {
      const nameColumn = defineLinkColumn<ReportUrlRelationshipT>({
        columnName: 'url',
        getContent: result => result.url?.name ?? '',
        getHref: result => result.url?.name ?? '',
        title: l('URL'),
      });
      const urlEntityColumn = defineLinkColumn<ReportUrlRelationshipT>({
        columnName: 'url_entity',
        getContent: result => result.url?.gid ?? '',
        getHref: result => result.url?.gid ? '/url/' + result.url.gid : '',
        title: l('URL Entity'),
      });

      return [
        relTypeColumn,
        nameColumn,
        urlEntityColumn,
      ];
    },
    [],
  );

  return (
    <PaginatedResults pager={pager}>
      <Table columns={columns} data={existingUrlItems} />
    </PaginatedResults>
  );
};

export default UrlRelationshipList;
