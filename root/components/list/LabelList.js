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
import * as manifest from '../../static/manifest.mjs';
import {defineNameAndCommentColumn}
  from '../../static/scripts/common/utility/tableColumns.js';
import formatLabelCode from '../../utility/formatLabelCode.js';
import {
  defineBeginDateColumn,
  defineCheckboxColumn,
  defineEndDateColumn,
  defineEntityColumn,
  defineNameColumn,
  defineRatingsColumn,
  defineTextColumn,
  defineTypeColumn,
  removeFromMergeColumn,
} from '../../utility/tableColumns.js';

type Props = {
  ...CollectionCommentsRoleT,
  +checkboxes?: string,
  +labels: $ReadOnlyArray<LabelT>,
  +mergeForm?: MergeFormT,
  +order?: string,
  +showCollectionComments?: boolean,
  +showRatings?: boolean,
  +sortable?: boolean,
};

const LabelList = ({
  canEditCollectionComments,
  checkboxes,
  collectionComments,
  collectionId,
  labels,
  mergeForm,
  order,
  showCollectionComments = false,
  showRatings = false,
  sortable,
}: Props): React.MixedElement => {
  const $c = React.useContext(CatalystContext);

  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (nonEmpty(checkboxes) || mergeForm)
        ? defineCheckboxColumn({mergeForm: mergeForm, name: checkboxes})
        : null;
      const nameColumn = showCollectionComments && nonEmpty(collectionId) ? (
        defineNameAndCommentColumn<LabelT>({
          canEditCollectionComments: canEditCollectionComments,
          collectionComments: showCollectionComments
            ? collectionComments
            : undefined,
          collectionId: collectionId,
          order: order,
          sortable: sortable,
          title: l('Label'),
        })
      ) : (
        defineNameColumn<LabelT>({
          order: order,
          sortable: sortable,
          title: l('Label'),
        })
      );
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
      const ratingsColumn = defineRatingsColumn<LabelT>({
        getEntity: entity => entity,
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
      canEditCollectionComments,
      checkboxes,
      collectionComments,
      collectionId,
      labels.length,
      mergeForm,
      order,
      showCollectionComments,
      showRatings,
      sortable,
    ],
  );

  const table = useTable<LabelT>({columns, data: labels});

  return (
    <>
      {table}
      {manifest.js('common/components/NameWithCommentCell', {async: 'async'})}
    </>
  );
};

export default LabelList;
