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
  defineRemoveFromMergeColumn,
  defineTypeColumn,
} from '../../utility/tableColumns';

type Props = {
  +$c: CatalystContextT,
  +areas: $ReadOnlyArray<AreaT>,
  +checkboxes?: string,
  +mergeForm?: MergeFormT,
  +order?: string,
  +sortable?: boolean,
};

const AreaList = ({
  $c,
  areas,
  checkboxes,
  mergeForm,
  order,
  sortable,
}: Props) => {
  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user_exists && (checkboxes || mergeForm)
        ? defineCheckboxColumn(checkboxes, mergeForm)
        : null;
      const nameColumn =
        defineNameColumn<AreaT>(l('Area'), order, sortable);
      const typeColumn = defineTypeColumn('area_type', order, sortable);
      const removeFromMergeColumn = mergeForm
        ? defineRemoveFromMergeColumn(areas)
        : null;

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        nameColumn,
        typeColumn,
        ...(removeFromMergeColumn ? [removeFromMergeColumn] : []),
      ];
    },
    [$c.user_exists, areas, checkboxes, mergeForm, order, sortable],
  );

  return <Table columns={columns} data={areas} />;
};

export default withCatalystContext(AreaList);
