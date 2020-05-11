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
import formatLabelCode from '../../utility/formatLabelCode';
import {
  defineCheckboxColumn,
  defineNameColumn,
  defineTextColumn,
  defineTypeColumn,
  defineEntityColumn,
  defineBeginDateColumn,
  defineEndDateColumn,
  defineRemoveFromMergeColumn,
  ratingsColumn,
} from '../../utility/tableColumns';

type Props = {
  +$c: CatalystContextT,
  +checkboxes?: string,
  +labels: $ReadOnlyArray<LabelT>,
  +mergeForm?: MergeFormT,
  +order?: string,
  +showRatings?: boolean,
  +sortable?: boolean,
};

const LabelList = ({
  $c,
  checkboxes,
  labels,
  mergeForm,
  order,
  showRatings,
  sortable,
}: Props) => {
  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (checkboxes || mergeForm)
        ? defineCheckboxColumn(checkboxes, mergeForm)
        : null;
      const nameColumn =
        defineNameColumn<LabelT>(l('Label'), order, sortable);
      const typeColumn = defineTypeColumn('label_type', order, sortable);
      const labelCodeColumn = defineTextColumn<LabelT>(
        entity => entity.label_code ? formatLabelCode(entity.label_code) : '',
        'label_code',
        l('Code'),
        order,
        sortable,
      );
      const areaColumn = defineEntityColumn<LabelT>(
        entity => entity.area,
        'area',
        l('Area'),
        order,
        sortable,
      );
      const beginDateColumn = defineBeginDateColumn(order, sortable);
      const endDateColumn = defineEndDateColumn(order, sortable);
      const removeFromMergeColumn = mergeForm
        ? defineRemoveFromMergeColumn(labels)
        : null;

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        nameColumn,
        typeColumn,
        labelCodeColumn,
        areaColumn,
        beginDateColumn,
        endDateColumn,
        ...(showRatings ? [ratingsColumn] : []),
        ...(removeFromMergeColumn ? [removeFromMergeColumn] : []),
      ];
    },
    [
      $c.user,
      checkboxes,
      labels,
      mergeForm,
      order,
      showRatings,
      sortable,
    ],
  );

  return <Table columns={columns} data={labels} />;
};

export default withCatalystContext(LabelList);
