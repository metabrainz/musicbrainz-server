/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import useTable from '../../hooks/useTable';
import formatLabelCode from '../../utility/formatLabelCode';
import {
  defineCheckboxColumn,
  defineNameColumn,
  defineTextColumn,
  defineTypeColumn,
  defineEntityColumn,
  defineBeginDateColumn,
  defineEndDateColumn,
  ratingsColumn,
  removeFromMergeColumn,
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
}: Props): React.Element<'table'> => {
  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (checkboxes || mergeForm)
        ? defineCheckboxColumn({mergeForm: mergeForm, name: checkboxes})
        : null;
      const nameColumn = defineNameColumn<LabelT>({
        order: order,
        sortable: sortable,
        title: l('Label'),
      });
      const typeColumn = defineTypeColumn({
        order: order,
        sortable: sortable,
        typeContext: 'label_type',
      });
      const labelCodeColumn = defineTextColumn<LabelT>({
        columnName: 'label_code',
        getText: entity => entity.label_code
          ? formatLabelCode(entity.label_code)
          : '',
        order: order,
        sortable: sortable,
        title: l('Code'),
      });
      const areaColumn = defineEntityColumn<LabelT>({
        columnName: 'area',
        getEntity: entity => entity.area,
        order: order,
        sortable: sortable,
        title: l('Area'),
      });
      const beginDateColumn = defineBeginDateColumn({
        order: order,
        sortable: sortable,
      });
      const endDateColumn = defineEndDateColumn({
        order: order,
        sortable: sortable,
      });

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        nameColumn,
        typeColumn,
        labelCodeColumn,
        areaColumn,
        beginDateColumn,
        endDateColumn,
        ...(showRatings ? [ratingsColumn] : []),
        ...(mergeForm && labels.length > 2 ? [removeFromMergeColumn] : []),
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

  return useTable<LabelT>({
    columns,
    data: labels,
  });
};

export default LabelList;
