/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context.mjs';
import useTable from '../../hooks/useTable.js';
import {
  defineCheckboxColumn,
  defineNameColumn,
  defineTypeColumn,
  removeFromMergeColumn,
} from '../../utility/tableColumns.js';

type Props = {
  +areas: $ReadOnlyArray<AreaT>,
  +checkboxes?: string,
  +mergeForm?: MergeFormT,
  +order?: string,
  +sortable?: boolean,
};

const AreaList = ({
  areas,
  checkboxes,
  mergeForm,
  order,
  sortable,
}: Props): React$Element<'table'> => {
  const $c = React.useContext(CatalystContext);

  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (nonEmpty(checkboxes) || mergeForm)
        ? defineCheckboxColumn({mergeForm: mergeForm, name: checkboxes})
        : null;
      const nameColumn = defineNameColumn<AreaT>({
        order: order,
        sortable: sortable,
        title: l('Area'),
      });
      const typeColumn = defineTypeColumn({
        order: order,
        sortable: sortable,
        typeContext: 'area_type',
      });

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        nameColumn,
        typeColumn,
        ...(mergeForm && areas.length > 2 ? [removeFromMergeColumn] : []),
      ];
    },
    [$c.user, areas, checkboxes, mergeForm, order, sortable],
  );

  return useTable<AreaT>({columns, data: areas});
};

export default AreaList;
