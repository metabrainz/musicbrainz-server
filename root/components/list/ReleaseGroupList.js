/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import {groupBy} from 'lodash';

import Table from '../Table';
import {withCatalystContext} from '../../context';
import releaseGroupType from '../../utility/releaseGroupType';
import parseDate from '../../static/scripts/common/utility/parseDate';
import {
  defineArtistCreditColumn,
  defineCheckboxColumn,
  defineNameColumn,
  defineSeriesNumberColumn,
  defineRemoveFromMergeColumn,
  defineTextColumn,
  defineCountColumn,
  ratingsColumn,
} from '../../utility/tableColumns';

type ReleaseGroupListTableProps = {
  ...SeriesItemNumbersRoleT,
  +$c: CatalystContextT,
  +checkboxes?: string,
  +mergeForm?: MergeFormT,
  +order?: string,
  +releaseGroups: $ReadOnlyArray<ReleaseGroupT>,
  +showRatings?: boolean,
  +showType?: boolean,
  +sortable?: boolean,
};

type ReleaseGroupListProps = {
  ...SeriesItemNumbersRoleT,
  +checkboxes?: string,
  +mergeForm?: MergeFormT,
  +order?: string,
  +releaseGroups: $ReadOnlyArray<ReleaseGroupT>,
  +showRatings?: boolean,
  +sortable?: boolean,
};

export const ReleaseGroupListTable = withCatalystContext(({
  $c,
  checkboxes,
  mergeForm,
  order,
  releaseGroups,
  seriesItemNumbers,
  showRatings,
  showType = true,
  sortable,
}: ReleaseGroupListTableProps) => {
  function getFirstReleaseYear(entity: ReleaseGroupT) {
    if (!entity.firstReleaseDate) {
      return '—';
    }

    return parseDate(entity.firstReleaseDate).year?.toString() ?? '—';
  }

  const columns = React.useMemo(
    () => {
      const checkboxColumn = $c.user_exists && (checkboxes || mergeForm)
        ? defineCheckboxColumn(checkboxes, mergeForm)
        : null;
      const seriesNumberColumn = seriesItemNumbers
        ? defineSeriesNumberColumn(seriesItemNumbers)
        : null;
      const yearColumn = defineTextColumn<ReleaseGroupT>(
        entity => getFirstReleaseYear(entity),
        'year',
        l('Year'),
        order,
        sortable,
        {className: 'c'},
        {className: 'year c'},
      );
      const nameColumn =
        defineNameColumn<ReleaseGroupT>(
          l('Title'),
          order,
          sortable,
          false, // no descriptive linking (since ACs are in the next column)
        );
      const artistCreditColumn = defineArtistCreditColumn<ReleaseGroupT>(
        entity => entity.artistCredit,
        'artist',
        l('Artist'),
      );
      const typeColumn = defineTextColumn<ReleaseGroupT>(
        entity => entity.l_type_name || '',
        'primary-type',
        l('Type'),
        order,
        sortable,
      );
      const releaseNumberColumn = defineCountColumn<ReleaseGroupT>(
        entity => entity.release_count,
        'release_count',
        l('Releases'),
      );
      const removeFromMergeColumn = mergeForm
        ? defineRemoveFromMergeColumn(releaseGroups)
        : null;

      return [
        ...(checkboxColumn ? [checkboxColumn] : []),
        ...(seriesNumberColumn ? [seriesNumberColumn] : []),
        yearColumn,
        nameColumn,
        artistCreditColumn,
        ...(showType ? [typeColumn] : []),
        ...(showRatings ? [ratingsColumn] : []),
        releaseNumberColumn,
        ...(removeFromMergeColumn ? [removeFromMergeColumn] : []),
      ];
    },
    [
      $c.user_exists,
      checkboxes,
      mergeForm,
      order,
      releaseGroups,
      seriesItemNumbers,
      showRatings,
      showType,
      sortable,
    ],
  );

  return (
    <Table
      className="release-group-list"
      columns={columns}
      data={releaseGroups}
    />
  );
});

const ReleaseGroupList = ({
  checkboxes,
  mergeForm,
  order,
  releaseGroups,
  seriesItemNumbers,
  showRatings,
  sortable,
}: ReleaseGroupListProps) => {
  const groupedReleaseGroups = groupBy(releaseGroups, 'typeName');
  return (
    Object.keys(groupedReleaseGroups).map<React$Node>((type) => {
      const releaseGroupsOfType = groupedReleaseGroups[type];
      return (
        <React.Fragment key={type}>
          <h3>
            {type === 'null'
              ? l('Unspecified type')
              : releaseGroupType(releaseGroupsOfType[0])
            }
          </h3>
          <ReleaseGroupListTable
            checkboxes={checkboxes}
            mergeForm={mergeForm}
            order={order}
            releaseGroups={releaseGroupsOfType}
            seriesItemNumbers={seriesItemNumbers}
            showRatings={showRatings}
            showType={false}
            sortable={sortable}
          />
        </React.Fragment>
      );
    })
  );
};

export default ReleaseGroupList;
