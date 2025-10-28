/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import PaginatedResults from '../../components/PaginatedResults.js';
import {CatalystContext} from '../../context.mjs';
import useTable from '../../hooks/useTable.js';
import formatUserDate from '../../utility/formatUserDate.js';
import {
  defineEntityColumn,
  defineTextColumn,
} from '../../utility/tableColumns.js';
import type {ReportInstrumentT} from '../types.js';

component InstrumentList(
  items: $ReadOnlyArray<ReportInstrumentT>,
  pager: PagerT,
) {
  const $c = React.useContext(CatalystContext);
  const existingInstrumentItems = items.reduce((
    result: Array<ReportInstrumentT>,
    item,
  ) => {
    if (item.instrument != null) {
      result.push(item);
    }
    return result;
  }, []);

  const columns = React.useMemo(
    () => {
      const nameColumn = defineEntityColumn<ReportInstrumentT>({
        columnName: 'instrument',
        getEntity: result => result.instrument ?? null,
        title: l_mb_server('Instrument'),
      });
      const typeColumn = defineTextColumn<ReportInstrumentT>({
        columnName: 'type',
        getText: result => {
          const typeName = result.instrument?.typeName;
          return (nonEmpty(typeName)
            ? lp_attributes(typeName, 'instrument_type')
            : l_mb_server('Unclassified instrument')
          );
        },
        title: l_mb_server('Type'),
      });
      const editedColumn = defineTextColumn<ReportInstrumentT>({
        columnName: 'last-updated',
        getText: result => {
          const lastUpdated = result.instrument?.last_updated;
          return (nonEmpty(lastUpdated)
            ? formatUserDate($c, lastUpdated)
            : ''
          );
        },
        title: l_mb_server('Last updated'),
      });

      return [
        nameColumn,
        typeColumn,
        editedColumn,
      ];
    },
    [$c],
  );

  const table = useTable<ReportInstrumentT>({
    columns,
    data: existingInstrumentItems,
  });

  return (
    <PaginatedResults pager={pager}>
      {table}
    </PaginatedResults>
  );
}

export default InstrumentList;
