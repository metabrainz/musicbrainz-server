/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Table from '../Table';
import {withCatalystContext} from '../../context';
import {
  defineCheckboxColumn,
  defineNameColumn,
  defineTypeColumn,
  instrumentDescriptionColumn,
} from '../../utility/tableColumns';

type Props = {
  +$c: CatalystContextT,
  +checkboxes?: string,
  +instruments: $ReadOnlyArray<InstrumentT>,
  +order?: string,
  +sortable?: boolean,
};

const InstrumentList = ({
  $c,
  checkboxes,
  instruments,
  order,
  sortable,
}: Props) => {
  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user_exists && checkboxes
        ? defineCheckboxColumn(checkboxes)
        : null;
      const nameColumn =
        defineNameColumn<InstrumentT>(l('Instrument'), order, sortable);
      const typeColumn = defineTypeColumn('instrument_type', order, sortable);

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        nameColumn,
        typeColumn,
        instrumentDescriptionColumn,
      ];
    },
    [$c.user_exists, checkboxes, order, sortable],
  );

  return <Table columns={columns} data={instruments} />;
};

export default withCatalystContext(InstrumentList);
