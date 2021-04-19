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
  relTypeColumn,
} from '../../utility/tableColumns';
import type {ReportWorkRelationshipT} from '../types';

type Props = {
  +items: $ReadOnlyArray<ReportWorkRelationshipT>,
  +pager: PagerT,
};

const WorkRelationshipList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => {
  const existingWorkItems = items.reduce((result, item) => {
    if (item.work != null) {
      result.push(item);
    }
    return result;
  }, []);

  const columns = React.useMemo(
    () => {
      const nameColumn = defineEntityColumn<ReportWorkRelationshipT>({
        columnName: 'work',
        getEntity: result => result.work ?? null,
        title: l('Work'),
      });

      return [
        relTypeColumn,
        nameColumn,
      ];
    },
    [],
  );

  return (
    <PaginatedResults pager={pager}>
      <Table columns={columns} data={existingWorkItems} />
    </PaginatedResults>
  );
};

export default WorkRelationshipList;
