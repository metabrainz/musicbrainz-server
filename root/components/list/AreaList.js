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
import {
  defineCheckboxColumn,
  defineNameColumn,
  defineTypeColumn,
  removeFromMergeColumn,
} from '../../utility/tableColumns.js';

type Props = {
  ...CollectionCommentsRoleT,
  +areas: $ReadOnlyArray<AreaT>,
  +checkboxes?: string,
  +mergeForm?: MergeFormT,
  +order?: string,
  +showCollectionComments?: boolean,
  +sortable?: boolean,
};

const AreaList = ({
  areas,
  canEditCollectionComments,
  checkboxes,
  collectionComments,
  collectionId,
  mergeForm,
  order,
  showCollectionComments = false,
  sortable,
}: Props): React.MixedElement => {
  const $c = React.useContext(CatalystContext);

  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (nonEmpty(checkboxes) || mergeForm)
        ? defineCheckboxColumn({mergeForm: mergeForm, name: checkboxes})
        : null;
      const nameColumn = showCollectionComments && nonEmpty(collectionId) ? (
        defineNameAndCommentColumn<AreaT>({
          canEditCollectionComments: canEditCollectionComments,
          collectionComments: showCollectionComments
            ? collectionComments
            : undefined,
          collectionId: collectionId,
          order: order,
          sortable: sortable,
          title: l('Area'),
        })
      ) : (
        defineNameColumn<AreaT>({
          order: order,
          sortable: sortable,
          title: l('Area'),
        })
      );
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
    [
      $c.user,
      areas,
      canEditCollectionComments,
      checkboxes,
      collectionComments,
      collectionId,
      mergeForm,
      order,
      showCollectionComments,
      sortable,
    ],
  );

  const table = useTable<AreaT>({columns, data: areas});

  return (
    <>
      {table}
      {manifest.js('common/components/NameWithCommentCell', {async: 'async'})}
    </>
  );
};

export default AreaList;
