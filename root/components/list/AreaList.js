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
import {
  defineCheckboxColumn,
  defineCollectionCommentsColumn,
  defineNameColumn,
  defineTypeColumn,
  removeFromMergeColumn,
} from '../../utility/tableColumns';

type Props = {
  ...CollectionCommentsRoleT,
  +$c: CatalystContextT,
  +areas: $ReadOnlyArray<AreaT>,
  +checkboxes?: string,
  +mergeForm?: MergeFormT,
  +order?: string,
  +showCollectionComments?: boolean,
  +sortable?: boolean,
};

const AreaList = ({
  $c,
  areas,
  checkboxes,
  collectionComments,
  mergeForm,
  order,
  showCollectionComments = false,
  sortable,
}: Props): React.Element<typeof Table> => {
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
      const collectionCommentsColumn = showCollectionComments
        ? defineCollectionCommentsColumn({
          collectionComments: collectionComments,
        })
        : null;

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        nameColumn,
        typeColumn,
        ...(collectionCommentsColumn ? [collectionCommentsColumn] : []),
        ...(mergeForm && areas.length > 2 ? [removeFromMergeColumn] : []),
      ];
    },
    [
      $c.user,
      areas,
      checkboxes,
      collectionComments,
      mergeForm,
      order,
      showCollectionComments,
      sortable,
    ],
  );

  return <Table columns={columns} data={areas} />;
};

export default AreaList;
