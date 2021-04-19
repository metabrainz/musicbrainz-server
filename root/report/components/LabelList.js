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
} from '../../utility/tableColumns';
import type {ReportLabelT} from '../types';

type Props = {
  +items: $ReadOnlyArray<ReportLabelT>,
  +pager: PagerT,
};

const LabelList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => {
  const existingLabelItems = items.reduce((result, item) => {
    if (item.label != null) {
      result.push(item);
    }
    return result;
  }, []);

  const columns = React.useMemo(
    () => {
      const nameColumn = defineEntityColumn<ReportLabelT>({
        columnName: 'label',
        getEntity: result => result.label ?? null,
        title: l('Label'),
      });

      return [
        nameColumn,
      ];
    },
    [],
  );

  return (
    <PaginatedResults pager={pager}>
      <Table columns={columns} data={existingLabelItems} />
    </PaginatedResults>
  );
};

export default LabelList;
