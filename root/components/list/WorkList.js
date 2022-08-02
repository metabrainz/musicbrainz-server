/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context.mjs';
import * as manifest from '../../static/manifest.mjs';
import Table from '../Table';
import {
  defineArtistRolesColumn,
  defineCheckboxColumn,
  defineNameColumn,
  defineRatingsColumn,
  defineSeriesNumberColumn,
  defineTypeColumn,
  attributesColumn,
  iswcsColumn,
  removeFromMergeColumn,
  workArtistsColumn,
  workLanguagesColumn,
} from '../../utility/tableColumns';

type Props = {
  ...SeriesItemNumbersRoleT,
  +checkboxes?: string,
  +mergeForm?: MergeFormT,
  +order?: string,
  +showRatings?: boolean,
  +sortable?: boolean,
  +works: $ReadOnlyArray<WorkT>,
};

const WorkList = ({
  checkboxes,
  mergeForm,
  order,
  seriesItemNumbers,
  showRatings = false,
  sortable,
  works,
}: Props): React.Element<typeof React.Fragment> => {
  const $c = React.useContext(CatalystContext);

  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (nonEmpty(checkboxes) || mergeForm)
        ? defineCheckboxColumn({mergeForm: mergeForm, name: checkboxes})
        : null;
      const seriesNumberColumn = seriesItemNumbers
        ? defineSeriesNumberColumn({seriesItemNumbers: seriesItemNumbers})
        : null;
      const nameColumn = defineNameColumn<WorkT>({
        order: order,
        sortable: sortable,
        title: l('Work'),
      });
      const writersColumn = defineArtistRolesColumn<WorkT>({
        columnName: 'writers',
        getRoles: entity => entity.writers,
        title: l('Writers'),
      });
      const typeColumn = defineTypeColumn({
        order: order,
        sortable: sortable,
        typeContext: 'work_type',
      });
      const ratingsColumn = defineRatingsColumn<WorkT>({
        getEntity: entity => entity,
      });

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
        ...(mergeForm && works.length > 2 ? [removeFromMergeColumn] : []),
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

  return (
    <>
      <Table columns={columns} data={works} />
      {manifest.js('common/components/ArtistRoles', {async: 'async'})}
      {manifest.js('common/components/AttributeList', {async: 'async'})}
      {manifest.js('common/components/WorkArtists', {async: 'async'})}
    </>
  );
};

export default WorkList;
