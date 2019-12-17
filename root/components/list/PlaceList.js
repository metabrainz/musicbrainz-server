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
  defineTextColumn,
  defineEntityColumn,
  defineBeginDateColumn,
  defineEndDateColumn,
} from '../../utility/tableColumns';

type Props = {
  +$c: CatalystContextT,
  +checkboxes?: string,
  +order?: string,
  +places: $ReadOnlyArray<PlaceT>,
  +sortable?: boolean,
};

const PlaceList = ({
  $c,
  checkboxes,
  order,
  places,
  sortable,
}: Props) => {
  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user_exists && checkboxes
        ? defineCheckboxColumn(checkboxes)
        : null;
      const nameColumn =
        defineNameColumn<PlaceT>(l('Place'), order, sortable);
      const typeColumn = defineTypeColumn('place_type', order, sortable);
      const addressColumn = defineTextColumn(
        entity => entity.address,
        'address',
        l('Address'),
        order,
        sortable,
      );
      const areaColumn = defineEntityColumn(
        entity => entity.area,
        'area',
        l('Area'),
        order,
        sortable,
      );
      const beginDateColumn = defineBeginDateColumn(order, sortable);
      const endDateColumn = defineEndDateColumn(order, sortable);

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        nameColumn,
        typeColumn,
        addressColumn,
        areaColumn,
        beginDateColumn,
        endDateColumn,
      ];
    },
    [$c.user_exists, checkboxes, order, sortable],
  );

  return <Table columns={columns} data={places} />;
};

export default withCatalystContext(PlaceList);
