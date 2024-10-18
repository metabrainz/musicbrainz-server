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
  attributesColumn,
  defineArtistRolesColumn,
  defineCheckboxColumn,
  defineNameColumn,
  defineRatingsColumn,
  defineSeriesNumberColumn,
  defineTypeColumn,
  iswcsColumn,
  removeFromMergeColumn,
  workArtistsColumn,
  workLanguagesColumn,
} from '../../utility/tableColumns.js';

component WorkList(
  canEditCollectionComments?: boolean,
  checkboxes?: string,
  collectionComments?: {
    +[entityGid: string]: string,
  },
  collectionId?: number,
  mergeForm?: MergeFormT,
  order?: string,
  seriesItemNumbers?: $ReadOnlyArray<string>,
  showCollectionComments: boolean = false,
  showRatings: boolean = false,
  sortable?: boolean,
  works: $ReadOnlyArray<WorkT>,
) {
  const $c = React.useContext(CatalystContext);

  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (nonEmpty(checkboxes) || mergeForm)
        ? defineCheckboxColumn({mergeForm, name: checkboxes})
        : null;
      const seriesNumberColumn = seriesItemNumbers
        ? defineSeriesNumberColumn({seriesItemNumbers})
        : null;
      const nameColumn = showCollectionComments && nonEmpty(collectionId) ? (
        defineNameAndCommentColumn<WorkT>({
          canEditCollectionComments,
          collectionComments: showCollectionComments
            ? collectionComments
            : undefined,
          collectionId,
          order,
          sortable,
          title: l('Work'),
        })
      ) : (
        defineNameColumn<WorkT>({
          order,
          sortable,
          title: l('Work'),
        })
      );
      const writersColumn = defineArtistRolesColumn<WorkT>({
        columnName: 'writers',
        getRoles: entity => entity.writers,
        title: l('Writers'),
      });
      const typeColumn = defineTypeColumn({
        order,
        sortable,
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
      canEditCollectionComments,
      checkboxes,
      collectionComments,
      collectionId,
      mergeForm,
      order,
      seriesItemNumbers,
      showCollectionComments,
      showRatings,
      sortable,
      works,
    ],
  );

  const table = useTable<WorkT>({columns, data: works});

  return (
    <>
      {table}
      {manifest('common/components/ArtistRoles', {async: 'async'})}
      {manifest('common/components/AttributeList', {async: 'async'})}
      {manifest('common/components/IswcList', {async: 'async'})}
      {manifest('common/components/NameWithCommentCell', {async: 'async'})}
      {manifest('common/components/WorkArtists', {async: 'async'})}
    </>
  );
}

export default WorkList;
