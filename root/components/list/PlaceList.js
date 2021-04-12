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
  +mergeForm?: MergeFormT,
  +order?: string,
  +places: $ReadOnlyArray<PlaceT>,
  +showCollectionComments?: boolean,
  +showRatings?: boolean,
  +sortable?: boolean,
};

const PlaceList = ({
  canEditCollectionComments,
  checkboxes,
  collectionComments,
  collectionId,
  mergeForm,
  order,
  places,
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
        defineNameAndCommentColumn<PlaceT>({
          canEditCollectionComments: canEditCollectionComments,
          collectionComments: showCollectionComments
            ? collectionComments
            : undefined,
          collectionId: collectionId,
          descriptive: false, // since area has its own column
          order: order,
          sortable: sortable,
          title: l('Place'),
        })
      ) : (
        defineNameColumn<PlaceT>({
          descriptive: false, // since area has its own column
          order: order,
          sortable: sortable,
          title: l('Place'),
        })
      );
      const typeColumn = defineTypeColumn({
        order: order,
        sortable: sortable,
        typeContext: 'place_type',
      });
      const addressColumn = defineTextColumn<PlaceT>({
        columnName: 'address',
        getText: entity => entity.address,
        order: order,
        sortable: sortable,
        title: l('Address'),
      });
      const areaColumn = defineEntityColumn<PlaceT>({
        columnName: 'area',
        getEntity: entity => entity.area,
        title: l('Area'),
      });
      const beginDateColumn = defineBeginDateColumn({});
      const endDateColumn = defineEndDateColumn({});
      const ratingsColumn = defineRatingsColumn<PlaceT>({
        getEntity: entity => entity,
      });

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        nameColumn,
        typeColumn,
        addressColumn,
        areaColumn,
        beginDateColumn,
        endDateColumn,
        ...(showRatings ? [ratingsColumn] : []),
        ...(mergeForm && places.length > 2 ? [removeFromMergeColumn] : []),
      ];
    },
    [
      $c.user,
      canEditCollectionComments,
      collectionId,
      checkboxes,
      mergeForm,
      order,
      places,
      showRatings,
      collectionComments,
      showCollectionComments,
      sortable,
    ],
  );

  const table = useTable<PlaceT>({columns, data: places});

  return (
    <>
      {table}
      {manifest.js('common/components/NameWithCommentCell', {async: 'async'})}
    </>
  );
};

export default PlaceList;
