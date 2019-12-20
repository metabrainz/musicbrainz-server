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
import formatLabelCode from '../../utility//formatLabelCode';
import {
  defineCheckboxColumn,
  defineNameColumn,
  defineTextColumn,
  defineTypeColumn,
  defineEntityColumn,
  defineBeginDateColumn,
  defineEndDateColumn,
  ratingsColumn,
} from '../../utility/tableColumns';

type Props = {
  +$c: CatalystContextT,
  +checkboxes?: string,
  +labels: $ReadOnlyArray<LabelT>,
  +order?: string,
  +showRatings?: boolean,
  +sortable?: boolean,
};

const LabelList = ({
  $c,
  checkboxes,
  labels,
  order,
  showRatings,
  sortable,
}: Props) => {
  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user_exists && checkboxes
        ? defineCheckboxColumn(checkboxes)
        : null;
      const nameColumn =
        defineNameColumn<LabelT>(l('Label'), order, sortable);
      const typeColumn = defineTypeColumn('label_type', order, sortable);
      const labelCodeColumn = defineTextColumn(
        entity => entity.label_code ? formatLabelCode(entity.label_code) : '',
        'label_code',
        l('Code'),
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
        labelCodeColumn,
        areaColumn,
        beginDateColumn,
        endDateColumn,
        ...(showRatings ? [ratingsColumn] : []),
      ];
    },
    [$c.user_exists, checkboxes, order, showRatings, sortable],
  );

  return <Table columns={columns} data={labels} />;
};

export default withCatalystContext(LabelList);
