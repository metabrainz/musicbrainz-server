/*
 * @flow strict
 * Copyright (C) 2020 Jerome Roy
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../../components/PaginatedResults.js';
import Table from '../../components/Table.js';
import formatTrackLength
  from '../../static/scripts/common/utility/formatTrackLength.js';
import {
  defineCDTocColumn,
  defineTextColumn,
} from '../../utility/tableColumns.js';
import type {ReportCDTocT} from '../types.js';

type Props = {
  +items: $ReadOnlyArray<ReportCDTocT>,
  +pager: PagerT,
};

const CDTocList = ({
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
      const cdTocColumn = defineCDTocColumn<ReportCDTocT>({
        getCDToc: result => result.cdtoc ?? null,
      });
      const formatColumn = defineTextColumn<ReportCDTocT>({
        columnName: 'format',
        getText: result => result.format,
        title: l('Format'),
      });
      const lengthColumn = defineTextColumn<ReportCDTocT>({
        columnName: 'length',
        getText: result => formatTrackLength(1000 * result.length),
        title: l('Length'),
      });

      return [
        cdTocColumn,
        formatColumn,
        lengthColumn,
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

export default CDTocList;
