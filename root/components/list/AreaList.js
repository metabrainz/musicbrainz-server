/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import React from 'react';

import Table from '../Table';
import {withCatalystContext} from '../../context';
import {
  defineCheckboxColumn,
  defineNameColumn,
  defineTypeColumn,
} from '../../utility/tableColumns';

type Props = {
  +$c: CatalystContextT,
  +areas: $ReadOnlyArray<AreaT>,
  +checkboxes?: string,
  +order?: string,
  +sortable?: boolean,
};

const AreaList = ({
  $c,
  areas,
  checkboxes,
  order,
  sortable,
}: Props) => {
  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user_exists && checkboxes
        ? defineCheckboxColumn(checkboxes)
        : null;
      const nameColumn =
        defineNameColumn<CoreEntityT>(l('Area'), order, sortable);
      const typeColumn = defineTypeColumn('area_type', order, sortable);

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        nameColumn,
        typeColumn,
      ];
    },
    [$c.user_exists, checkboxes, order, sortable],
  );

  return <Table columns={columns} data={areas} />;
};

export default withCatalystContext(AreaList);
