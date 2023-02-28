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
import Table from '../../components/Table.js';
import {CatalystContext} from '../../context.mjs';
import formatUserDate from '../../utility/formatUserDate.js';
import {
  defineEntityColumn,
  defineTextColumn,
} from '../../utility/tableColumns.js';
import type {ReportInstrumentT} from '../types.js';

type Props = {
  +items: $ReadOnlyArray<ReportInstrumentT>,
  +pager: PagerT,
};

const InstrumentList = ({
  items,
  pager,
}: Props): React.Element<typeof PaginatedResults> => {
  const $c = React.useContext(CatalystContext);
  const existingInstrumentItems = items.reduce((result, item) => {
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
        title: l('Instrument'),
      });
      const typeColumn = defineTextColumn<ReportInstrumentT>({
        columnName: 'type',
        getText: result => {
          const typeName = result.instrument?.typeName;
          return (nonEmpty(typeName)
            ? lp_attributes(typeName, 'instrument_type')
            : l('Unclassified instrument')
          );
        },
        title: l('Type'),
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
        title: l('Last updated'),
      });

      return [
        nameColumn,
        typeColumn,
        editedColumn,
      ];
    },
    [$c],
  );

  return (
    <PaginatedResults pager={pager}>
      <Table columns={columns} data={existingInstrumentItems} />
    </PaginatedResults>
  );
};

export default InstrumentList;
