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
  seriesOrderingTypeColumn,
} from '../../utility/tableColumns';

type Props = {
  ...CollectionCommentsRoleT,
  +$c: CatalystContextT,
  +checkboxes?: string,
  +mergeForm?: MergeFormT,
  +order?: string,
  +series: $ReadOnlyArray<SeriesT>,
  +showCollectionComments?: boolean,
  +sortable?: boolean,
};

const SeriesList = ({
  $c,
  checkboxes,
  collectionComments,
  mergeForm,
  order,
  series,
  showCollectionComments = false,
  sortable,
}: Props): React.Element<typeof Table> => {
  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (nonEmpty(checkboxes) || mergeForm)
        ? defineCheckboxColumn({mergeForm: mergeForm, name: checkboxes})
        : null;
      const nameColumn = defineNameColumn<SeriesT>({
        order: order,
        sortable: sortable,
        title: lp('Series', 'singular'),
      });
      const typeColumn = defineTypeColumn({
        order: order,
        sortable: sortable,
        typeContext: 'series_type',
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
        seriesOrderingTypeColumn,
        ...(collectionCommentsColumn ? [collectionCommentsColumn] : []),
        ...(mergeForm && series.length > 2 ? [removeFromMergeColumn] : []),
      ];
    },
    [
      $c.user,
      checkboxes,
      collectionComments,
      mergeForm,
      order,
      series.length,
      showCollectionComments,
      sortable,
    ],
  );

  return <Table columns={columns} data={series} />;
};

export default SeriesList;
