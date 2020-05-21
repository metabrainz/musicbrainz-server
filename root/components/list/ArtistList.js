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
      const checkboxColumn = $c.user && (checkboxes || mergeForm)
        ? defineCheckboxColumn({mergeForm: mergeForm, name: checkboxes})
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
      const removeFromMergeColumn = mergeForm
        ? defineRemoveFromMergeColumn({toMerge: artists})
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
      $c.user,
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
