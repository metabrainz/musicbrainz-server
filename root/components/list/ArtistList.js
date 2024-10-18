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
  defineBeginDateColumn,
  defineCheckboxColumn,
  defineEndDateColumn,
  defineEntityColumn,
  defineInstrumentUsageColumn,
  defineNameColumn,
  defineRatingsColumn,
  defineSeriesNumberColumn,
  defineTextColumn,
  defineTypeColumn,
  removeFromMergeColumn,
} from '../../utility/tableColumns.js';

component ArtistList(
  artists: $ReadOnlyArray<ArtistT>,
  canEditCollectionComments?: boolean,
  checkboxes?: string,
  collectionComments?: {
    +[entityGid: string]: string,
  },
  collectionId?: number,
  instrumentCreditsAndRelTypes?: InstrumentCreditsAndRelTypesT,
  mergeForm?: MergeFormT,
  order?: string,
  seriesItemNumbers?: $ReadOnlyArray<string>,
  showBeginEnd: boolean = false,
  showCollectionComments: boolean = false,
  showInstrumentCreditsAndRelTypes: boolean = false,
  showRatings: boolean = false,
  showSortName: boolean = false,
  sortable?: boolean,
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
        defineNameAndCommentColumn<ArtistT>({
          canEditCollectionComments,
          collectionComments: showCollectionComments
            ? collectionComments
            : undefined,
          collectionId,
          order,
          sortable,
          title: l('Artist'),
        })
      ) : (
        defineNameColumn<ArtistT>({
          order,
          sortable,
          title: l('Artist'),
        })
      );
      const sortNameColumn = showSortName ? defineTextColumn<ArtistT>({
        columnName: 'sort_name',
        getText: entity => entity.sort_name,
        title: l('Sort name'),
      }) : null;
      const typeColumn = defineTypeColumn({
        order,
        sortable,
        typeContext: 'artist_type',
      });
      const genderColumn = defineTextColumn<ArtistT>({
        columnName: 'gender',
        getText: entity => entity.gender
          ? lp_attributes(entity.gender.name, 'gender')
          : '',
        order,
        sortable,
        title: l('Gender'),
      });
      const areaColumn = defineEntityColumn<ArtistT>({
        columnName: 'area',
        getEntity: entity => entity.area,
        title: l('Area'),
      });
      const beginDateColumn = showBeginEnd
        ? defineBeginDateColumn({order, sortable})
        : null;
      const beginAreaColumn = showBeginEnd ? defineEntityColumn<ArtistT>({
        columnName: 'begin_area',
        getEntity: entity => entity.begin_area,
        order,
        sortable,
        title: l('Begin area'),
      }) : null;
      const endDateColumn = showBeginEnd
        ? defineEndDateColumn({order, sortable})
        : null;
      const endAreaColumn = showBeginEnd ? defineEntityColumn<ArtistT>({
        columnName: 'end_area',
        getEntity: entity => entity.end_area,
        order,
        sortable,
        title: l('End area'),
      }) : null;
      const instrumentUsageColumn = showInstrumentCreditsAndRelTypes
        ? defineInstrumentUsageColumn({
          instrumentCreditsAndRelTypes,
        })
        : null;
      const ratingsColumn = defineRatingsColumn<ArtistT>({
        getEntity: entity => entity,
      });

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        ...(seriesNumberColumn ? [seriesNumberColumn] : []),
        nameColumn,
        ...(sortNameColumn ? [sortNameColumn] : []),
        typeColumn,
        genderColumn,
        areaColumn,
        ...(beginDateColumn ? [beginDateColumn] : []),
        ...(beginAreaColumn ? [beginAreaColumn] : []),
        ...(endDateColumn ? [endDateColumn] : []),
        ...(endAreaColumn ? [endAreaColumn] : []),
        ...(showRatings ? [ratingsColumn] : []),
        ...(instrumentUsageColumn ? [instrumentUsageColumn] : []),
        ...(mergeForm && artists.length > 2 ? [removeFromMergeColumn] : []),
      ];
    },
    [
      $c.user,
      artists,
      canEditCollectionComments,
      checkboxes,
      collectionComments,
      collectionId,
      instrumentCreditsAndRelTypes,
      mergeForm,
      order,
      seriesItemNumbers,
      showBeginEnd,
      showCollectionComments,
      showInstrumentCreditsAndRelTypes,
      showRatings,
      showSortName,
      sortable,
    ],
  );

  const table = useTable<ArtistT>({columns, data: artists});

  return (
    <>
      {table}
      {manifest('common/components/NameWithCommentCell', {async: 'async'})}
    </>
  );
}

export default ArtistList;
