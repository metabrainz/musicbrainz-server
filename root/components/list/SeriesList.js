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
  seriesOrderingTypeColumn,
} from '../../utility/tableColumns.js';

type Props = {
  ...CollectionCommentsRoleT,
  +checkboxes?: string,
  +mergeForm?: MergeFormT,
  +order?: string,
  +series: $ReadOnlyArray<SeriesT>,
  +showCollectionComments?: boolean,
  +sortable?: boolean,
};

const SeriesList = ({
  canEditCollectionComments,
  checkboxes,
  collectionComments,
  collectionId,
  mergeForm,
  order,
  series,
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
        defineNameAndCommentColumn<SeriesT>({
          canEditCollectionComments: canEditCollectionComments,
          collectionComments: showCollectionComments
            ? collectionComments
            : undefined,
          collectionId: collectionId,
          order: order,
          sortable: sortable,
          title: lp('Series', 'singular'),
        })
      ) : (
        defineNameColumn<SeriesT>({
          order: order,
          sortable: sortable,
          title: lp('Series', 'singular'),
        })
      );
      const typeColumn = defineTypeColumn({
        order: order,
        sortable: sortable,
        typeContext: 'series_type',
      });

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        nameColumn,
        typeColumn,
        seriesOrderingTypeColumn,
        ...(mergeForm && series.length > 2 ? [removeFromMergeColumn] : []),
      ];
    },
    [
      $c.user,
      canEditCollectionComments,
      checkboxes,
      collectionComments,
      collectionId,
      mergeForm,
      order,
      series.length,
      showCollectionComments,
      sortable,
    ],
  );

  const table = useTable<SeriesT>({columns, data: series});

  return (
    <>
      {table}
      {manifest.js('common/components/NameWithCommentCell', {async: 'async'})}
    </>
  );
};

export default SeriesList;
