/*
 * @flow strict-local
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {CatalystContext} from '../../context';
import Table from '../Table';
import {
  defineCheckboxColumn,
  defineNameColumn,
  defineTextColumn,
  defineTypeColumn,
  defineEntityColumn,
  defineBeginDateColumn,
  defineEndDateColumn,
  defineInstrumentUsageColumn,
  defineRatingsColumn,
  defineSeriesNumberColumn,
  removeFromMergeColumn,
} from '../../utility/tableColumns';

type Props = {
  ...InstrumentCreditsAndRelTypesRoleT,
  ...SeriesItemNumbersRoleT,
  +artists: $ReadOnlyArray<ArtistT>,
  +checkboxes?: string,
  +mergeForm?: MergeFormT,
  +order?: string,
  +showBeginEnd?: boolean,
  +showInstrumentCreditsAndRelTypes?: boolean,
  +showRatings?: boolean,
  +showSortName?: boolean,
  +sortable?: boolean,
};

const ArtistList = ({
  artists,
  checkboxes,
  instrumentCreditsAndRelTypes,
  mergeForm,
  order,
  seriesItemNumbers,
  showBeginEnd = false,
  showInstrumentCreditsAndRelTypes = false,
  showRatings = false,
  showSortName = false,
  sortable,
}: Props): React.Element<typeof Table> => {
  const $c = React.useContext(CatalystContext);

  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user && (nonEmpty(checkboxes) || mergeForm)
        ? defineCheckboxColumn({mergeForm: mergeForm, name: checkboxes})
        : null;
      const seriesNumberColumn = seriesItemNumbers
        ? defineSeriesNumberColumn({seriesItemNumbers: seriesItemNumbers})
        : null;
      const nameColumn = defineNameColumn<ArtistT>({
        order: order,
        sortable: sortable,
        title: l('Artist'),
      });
      const sortNameColumn = showSortName ? defineTextColumn<ArtistT>({
        columnName: 'sort_name',
        getText: entity => entity.sort_name,
        title: l('Sort Name'),
      }) : null;
      const typeColumn = defineTypeColumn({
        order: order,
        sortable: sortable,
        typeContext: 'artist_type',
      });
      const genderColumn = defineTextColumn<ArtistT>({
        columnName: 'gender',
        getText: entity => entity.gender
          ? lp_attributes(entity.gender.name, 'gender')
          : '',
        order: order,
        sortable: sortable,
        title: l('Gender'),
      });
      const areaColumn = defineEntityColumn<ArtistT>({
        columnName: 'area',
        getEntity: entity => entity.area,
        title: l('Area'),
      });
      const beginDateColumn = showBeginEnd
        ? defineBeginDateColumn({order: order, sortable: sortable})
        : null;
      const beginAreaColumn = showBeginEnd ? defineEntityColumn<ArtistT>({
        columnName: 'begin_area',
        getEntity: entity => entity.begin_area,
        order: order,
        sortable: sortable,
        title: l('Begin Area'),
      }) : null;
      const endDateColumn = showBeginEnd
        ? defineEndDateColumn({order: order, sortable: sortable})
        : null;
      const endAreaColumn = showBeginEnd ? defineEntityColumn<ArtistT>({
        columnName: 'end_area',
        getEntity: entity => entity.end_area,
        order: order,
        sortable: sortable,
        title: l('End Area'),
      }) : null;
      const instrumentUsageColumn = showInstrumentCreditsAndRelTypes
        ? defineInstrumentUsageColumn({
          instrumentCreditsAndRelTypes: instrumentCreditsAndRelTypes,
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
      checkboxes,
      instrumentCreditsAndRelTypes,
      mergeForm,
      order,
      seriesItemNumbers,
      showBeginEnd,
      showInstrumentCreditsAndRelTypes,
      showRatings,
      showSortName,
      sortable,
    ],
  );

  return <Table columns={columns} data={artists} />;
};

export default ArtistList;
