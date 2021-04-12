/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Table from '../Table';
import formatLabelCode from '../../utility/formatLabelCode';
import {
  defineCheckboxColumn,
  defineCollectionCommentsColumn,
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
  ...CollectionCommentsRoleT,
  +$c: CatalystContextT,
  +checkboxes?: string,
  +labels: $ReadOnlyArray<LabelT>,
  +mergeForm?: MergeFormT,
  +order?: string,
  +showCollectionComments?: boolean,
  +showRatings?: boolean,
  +sortable?: boolean,
};

const LabelList = ({
  $c,
  checkboxes,
  collectionComments,
  labels,
  mergeForm,
  order,
  showCollectionComments = false,
  showRatings = false,
  sortable,
}: Props): React.Element<typeof Table> => {
  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (nonEmpty(checkboxes) || mergeForm)
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
      const collectionCommentsColumn = showCollectionComments
        ? defineCollectionCommentsColumn({
          collectionComments: collectionComments,
        })
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
        ...(collectionCommentsColumn ? [collectionCommentsColumn] : []),
        ...(mergeForm && labels.length > 2 ? [removeFromMergeColumn] : []),
      ];
    },
    [
      $c.user,
      checkboxes,
      collectionComments,
      labels.length,
      mergeForm,
      order,
      showCollectionComments,
      showRatings,
      sortable,
    ],
  );

  return <Table columns={columns} data={labels} />;
};

export default LabelList;
