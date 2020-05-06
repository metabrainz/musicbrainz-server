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
import {
  defineArtistRolesColumn,
  defineCheckboxColumn,
  defineNameColumn,
  defineRemoveFromMergeColumn,
  defineSeriesNumberColumn,
  defineTypeColumn,
  attributesColumn,
  iswcsColumn,
  ratingsColumn,
  workArtistsColumn,
  workLanguagesColumn,
} from '../../utility/tableColumns';

type Props = {
  ...SeriesItemNumbersRoleT,
  +$c: CatalystContextT,
  +checkboxes?: string,
  +mergeForm?: MergeFormT,
  +order?: string,
  +showRatings?: boolean,
  +sortable?: boolean,
  +works: $ReadOnlyArray<WorkT>,
};

const WorkList = ({
  $c,
  checkboxes,
  mergeForm,
  order,
  seriesItemNumbers,
  showRatings,
  sortable,
  works,
}: Props) => {
  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (checkboxes || mergeForm)
        ? defineCheckboxColumn(checkboxes, mergeForm)
        : null;
      const seriesNumberColumn = seriesItemNumbers
        ? defineSeriesNumberColumn(seriesItemNumbers)
        : null;
      const nameColumn = defineNameColumn<WorkT>(
        l('Work'),
        order,
        sortable,
      );
      const writersColumn = defineArtistRolesColumn<WorkT>(
        entity => entity.writers,
        'writers',
        l('Writers'),
      );
      const typeColumn = defineTypeColumn('work_type', order, sortable);
      const removeFromMergeColumn = mergeForm
        ? defineRemoveFromMergeColumn(works)
        : null;

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        ...(seriesNumberColumn ? [seriesNumberColumn] : []),
        nameColumn,
        writersColumn,
        workArtistsColumn,
        iswcsColumn,
        typeColumn,
        workLanguagesColumn,
        attributesColumn,
        ...(showRatings ? [ratingsColumn] : []),
        ...(removeFromMergeColumn ? [removeFromMergeColumn] : []),
      ];
    },
    [
      $c.user,
      checkboxes,
      mergeForm,
      order,
      seriesItemNumbers,
      showRatings,
      sortable,
      works,
    ],
  );

  return <Table columns={columns} data={works} />;
};

export default withCatalystContext(WorkList);
