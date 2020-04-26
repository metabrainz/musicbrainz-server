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
  defineTextColumn,
  defineEntityColumn,
  defineBeginDateColumn,
  defineEndDateColumn,
  defineRemoveFromMergeColumn,
} from '../../utility/tableColumns';

type Props = {
  +$c: CatalystContextT,
  +checkboxes?: string,
  +mergeForm?: MergeFormT,
  +order?: string,
  +places: $ReadOnlyArray<PlaceT>,
  +sortable?: boolean,
};

const PlaceList = ({
  $c,
  checkboxes,
  mergeForm,
  order,
  places,
  sortable,
}: Props) => {
  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (checkboxes || mergeForm)
        ? defineCheckboxColumn(checkboxes, mergeForm)
        : null;
      const nameColumn =
        defineNameColumn<PlaceT>(
          l('Place'),
          order,
          sortable,
          false, // no descriptive linking (since we have an area column)
        );
      const typeColumn = defineTypeColumn('place_type', order, sortable);
      const addressColumn = defineTextColumn<PlaceT>(
        entity => entity.address,
        'address',
        l('Address'),
        order,
        sortable,
      );
      const areaColumn = defineEntityColumn<PlaceT>(
        entity => entity.area,
        'area',
        l('Area'),
      );
      const beginDateColumn = defineBeginDateColumn();
      const endDateColumn = defineEndDateColumn();
      const removeFromMergeColumn = mergeForm
        ? defineRemoveFromMergeColumn(places)
        : null;

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        nameColumn,
        typeColumn,
        addressColumn,
        areaColumn,
        beginDateColumn,
        endDateColumn,
        ...(removeFromMergeColumn ? [removeFromMergeColumn] : []),
      ];
    },
    [$c.user, checkboxes, mergeForm, order, places, sortable],
  );

  return <Table columns={columns} data={places} />;
};

export default withCatalystContext(PlaceList);
