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
import useTable from '../../hooks/useTable.js';
import formatTrackLength
  from '../../static/scripts/common/utility/formatTrackLength.js';
import {
  defineCDTocColumn,
  defineTextColumn,
} from '../../utility/tableColumns.js';
import type {ReportCDTocT} from '../types.js';

component CDTocList(
  items: $ReadOnlyArray<ReportCDTocT>,
  pager: PagerT,
) {
  const existingCDTocItems = items.reduce((
    result: Array<ReportCDTocT>,
    item,
  ) => {
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
        title: l_mb_server('Format'),
      });
      const lengthColumn = defineTextColumn<ReportCDTocT>({
        columnName: 'length',
        getText: result => formatTrackLength(1000 * result.length),
        title: l_mb_server('Length'),
      });

      return [
        cdTocColumn,
        formatColumn,
        lengthColumn,
      ];
    },
    [],
  );

  const table = useTable<ReportCDTocT>({
    columns,
    data: existingCDTocItems,
  });

  return (
    <PaginatedResults pager={pager}>
      {table}
    </PaginatedResults>
  );
}

export default CDTocList;
