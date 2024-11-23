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
import manifest from '../../static/manifest.mjs';
import {defineNameAndCommentColumn}
  from '../../static/scripts/common/utility/tableColumns.js';
import {
  defineCheckboxColumn,
  defineNameColumn,
  defineTypeColumn,
  removeFromMergeColumn,
  seriesOrderingTypeColumn,
} from '../../utility/tableColumns.js';

component SeriesList(
  canEditCollectionComments?: boolean,
  checkboxes?: string,
  collectionComments?: {
    +[entityGid: string]: string,
  },
  collectionId?: number,
  mergeForm?: MergeFormT,
  order?: string,
  series: $ReadOnlyArray<SeriesT>,
  showCollectionComments: boolean = false,
  sortable?: boolean,
) {
  const $c = React.useContext(CatalystContext);

  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (nonEmpty(checkboxes) || mergeForm)
        ? defineCheckboxColumn({mergeForm, name: checkboxes})
        : null;
      const nameColumn = showCollectionComments && nonEmpty(collectionId) ? (
        defineNameAndCommentColumn<SeriesT>({
          canEditCollectionComments,
          collectionComments: showCollectionComments
            ? collectionComments
            : undefined,
          collectionId,
          order,
          sortable,
          title: lp('Series', 'singular'),
        })
      ) : (
        defineNameColumn<SeriesT>({
          order,
          sortable,
          title: lp('Series', 'singular'),
        })
      );
      const typeColumn = defineTypeColumn({
        order,
        sortable,
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
      {manifest('common/components/NameWithCommentCell', {async: 'async'})}
    </>
  );
}

export default SeriesList;
