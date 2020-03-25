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
  defineCheckboxColumn,
  defineNameColumn,
  defineTextColumn,
  defineTypeColumn,
  defineEntityColumn,
  defineBeginDateColumn,
  defineEndDateColumn,
  defineInstrumentUsageColumn,
  defineRemoveFromMergeColumn,
  ratingsColumn,
} from '../../utility/tableColumns';

type Props = {
  ...InstrumentCreditsAndRelTypesRoleT,
  +$c: CatalystContextT,
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
  $c,
  artists,
  checkboxes,
  instrumentCreditsAndRelTypes,
  mergeForm,
  order,
  showBeginEnd,
  showInstrumentCreditsAndRelTypes,
  showRatings,
  showSortName,
  sortable,
}: Props) => {
  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user_exists && (checkboxes || mergeForm)
        ? defineCheckboxColumn(checkboxes, mergeForm)
        : null;
      const nameColumn = defineNameColumn<ArtistT>(
        l('Artist'),
        order,
        sortable,
      );
      const sortNameColumn = showSortName ? defineTextColumn(
        entity => entity.sort_name,
        'sort_name',
        l('Sort Name'),
      ) : null;
      const typeColumn = defineTypeColumn('artist_type', order, sortable);
      const genderColumn = defineTextColumn(
        entity => entity.gender
          ? lp_attributes(entity.gender.name, 'gender')
          : '',
        'gender',
        l('Gender'),
        order,
        sortable,
      );
      const areaColumn = defineEntityColumn(
        entity => entity.area,
        'area',
        l('Area'),
        order,
        sortable,
      );
      const beginDateColumn = showBeginEnd
        ? defineBeginDateColumn()
        : null;
      const beginAreaColumn = showBeginEnd ? defineEntityColumn(
        entity => entity.begin_area,
        'begin_area',
        l('Begin Area'),
      ) : null;
      const endDateColumn = showBeginEnd
        ? defineEndDateColumn()
        : null;
      const endAreaColumn = showBeginEnd ? defineEntityColumn(
        entity => entity.end_area,
        'end_area',
        l('End Area'),
      ) : null;
      const instrumentUsageColumn = showInstrumentCreditsAndRelTypes
        ? defineInstrumentUsageColumn(instrumentCreditsAndRelTypes)
        : null;
      const removeFromMergeColumn = mergeForm
        ? defineRemoveFromMergeColumn(artists)
        : null;

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
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
        ...(removeFromMergeColumn ? [removeFromMergeColumn] : []),
      ];
    },
    [
      $c.user_exists,
      artists,
      checkboxes,
      instrumentCreditsAndRelTypes,
      mergeForm,
      order,
      showBeginEnd,
      showInstrumentCreditsAndRelTypes,
      showRatings,
      showSortName,
      sortable,
    ],
  );

  return <Table columns={columns} data={artists} />;
};

export default withCatalystContext(ArtistList);
